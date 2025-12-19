// routes/seasonRoutes.js
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const FarmSeason = require('../models/FarmSeason');
const PlanTemplate = require('../models/PlanTemplate');
const LogEntry = require('../models/LogEntry');
const HiddenTask = require('../models/HiddenTask');
const { getDaysSinceStart } = require('../utils/dateUtils');
const { isAuth } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { asyncHandler } = require('../middleware/errorHandler');
const { MESSAGES, TASK_STATUS } = require('../config/constants');

/**
 * POST /api/seasons
 * Chức năng: Bắt đầu một mùa vụ mới với tự động matching template
 */
router.post('/', asyncHandler(async (req, res) => {
    const { seasonName, farmArea, startDate } = req.body;
    
    // Validation
    if (!seasonName || !farmArea || !startDate) {
        return errorResponse(res, MESSAGES.ERROR.MISSING_FIELDS, 400);
    }
    
    // Lấy hoặc tạo user demo
    const User = require('../models/User');
    let user = await User.findOne();
    if (!user) {
        user = await User.create({
            name: 'Demo User',
            email: 'demo@example.com',
            password: 'demo123'
        });
    }
    
    // 🤖 TỰ ĐỘNG TÌM TEMPLATE phù hợp dựa vào seasonName
    let matchedTemplate = null;
    const allTemplates = await PlanTemplate.find();
    
    // Thử match cropType có trong seasonName
    for (const template of allTemplates) {
        const cropType = template.cropType;
        if (cropType && seasonName.includes(cropType)) {
            matchedTemplate = template._id;
            console.log(`✅ Tự động áp dụng kế hoạch: ${template.templateName} (${cropType})`);
            break;
        }
    }
    
    if (!matchedTemplate) {
        console.log('⚠️ Không tìm thấy kế hoạch phù hợp, tạo mùa vụ không có template');
    }
    
    const newSeason = new FarmSeason({
        seasonName,
        farmArea,
        planTemplate: matchedTemplate,
        startDate: new Date(startDate),
        user: user._id
    });

    const savedSeason = await newSeason.save();
    
    return successResponse(
        res, 
        { season: savedSeason }, 
        MESSAGES.SUCCESS.SEASON_CREATED, 
        201
    );
}));

/**
 * GET /api/seasons/daily/:seasonId
 * Chức năng: Lấy danh sách công việc cần làm hôm nay
 */
router.get('/daily/:seasonId', asyncHandler(async (req, res) => {
    const { seasonId } = req.params;
    
    console.log('\n📍 GET /api/seasons/daily/:seasonId');
    console.log('  - Requested seasonId:', seasonId);

    // 1. Lấy thông tin mùa vụ và Template
    const season = await FarmSeason.findById(seasonId).populate('planTemplate');
    if (!season) {
        return errorResponse(res, 'Không tìm thấy mùa vụ', 404);
    }

    const currentDay = getDaysSinceStart(season.startDate);
    const seasonObjectId = mongoose.Types.ObjectId.isValid(seasonId) 
        ? new mongoose.Types.ObjectId(seasonId)
        : seasonId;
    let dailyTasks = [];
    let currentStage = null;

    // ✅ KHÔNG TỰ ĐỘNG LẤY TASKS TỪ TEMPLATE
    // Phần "Công việc hôm nay" là cho người dùng tự tạo công việc thủ công
    console.log('📝 Công việc hôm nay - Chỉ hiển thị nhật ký thủ công');

    // Lấy manual logs (nhật ký thủ công) gần đây
    // Lấy tất cả manual logs trong 30 ngày gần nhất
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const manualLogs = await LogEntry.find({
        season: seasonObjectId,
        logType: 'manual',
        completedAt: {
            $exists: true,
            $ne: null,
            $gte: thirtyDaysAgo
        }
    }).select('taskName notes usedMaterials completedAt location').sort({ completedAt: -1 });
    
    console.log('🔍 Manual Logs Query:');
    console.log('  - Found manual logs:', manualLogs.length);

    // Gộp manual logs theo taskName (để tránh trùng lặp)
    const manualLogsMap = new Map();
    manualLogs.forEach(log => {
        const taskName = log.taskName;
        if (!manualLogsMap.has(taskName)) {
            manualLogsMap.set(taskName, log);
        } else {
            // Nếu đã có, chỉ giữ log mới nhất
            const existing = manualLogsMap.get(taskName);
            if (new Date(log.completedAt) > new Date(existing.completedAt)) {
                manualLogsMap.set(taskName, log);
            }
        }
    });

    // CHỈ hiển thị manual logs (công việc tự tạo)
    manualLogsMap.forEach((log, taskName) => {
        dailyTasks.push({
            taskId: log._id.toString(),
            taskName: log.taskName,
            suggestedMaterials: [],
            usedMaterials: log.usedMaterials || [],
            frequency: 'Nhật ký thủ công',
            area: log.location || season.farmArea,
            status: 'DONE',
            notes: log.notes,
            completedAt: log.completedAt ? log.completedAt.toISOString() : null
        });
    });

    return successResponse(res, {
        currentDay,
        currentStage,
        farmArea: season.farmArea,
        tasks: dailyTasks
    }, `Công việc cần làm cho Ngày ${currentDay} của mùa vụ`);
}));

/**
 * GET /api/seasons/user
 * Chức năng: Lấy danh sách tất cả các mùa vụ của người dùng
 */
router.get('/user', asyncHandler(async (req, res) => {
    // Lấy tất cả seasons (tạm thời cho demo)
    const seasons = await FarmSeason.find({ 
        isActive: true 
    }).select('_id seasonName farmArea startDate');

    if (seasons.length === 0) {
        return errorResponse(res, 'Chưa có mùa vụ nào', 404);
    }

    return successResponse(res, { seasons }, MESSAGES.SUCCESS.DATA_RETRIEVED);
}));

/**
 * POST /api/seasons/hide-task
 * Chức năng: Ẩn task (bỏ qua hoặc hoàn thành) vĩnh viễn
 */
router.post('/hide-task', asyncHandler(async (req, res) => {
    const { seasonId, taskName, reason } = req.body;
    
    // Lấy user đầu tiên
    const User = require('../models/User');
    const user = await User.findOne();
    const userId = user ? user._id : null;

    // Validation
    if (!seasonId || !taskName || !reason) {
        return errorResponse(res, 'Thiếu thông tin bắt buộc', 400);
    }

    if (!['DONE', 'SKIPPED'].includes(reason)) {
        return errorResponse(res, 'Lý do không hợp lệ', 400);
    }

    // Convert seasonId sang ObjectId nếu cần
    const seasonObjectId = mongoose.Types.ObjectId.isValid(seasonId) 
        ? new mongoose.Types.ObjectId(seasonId) 
        : seasonId;

    // Kiểm tra xem đã tồn tại chưa
    const existing = await HiddenTask.findOne({
        season: seasonObjectId,
        taskName: taskName
    });

    if (existing) {
        return successResponse(
            res,
            { hidden: true },
            'Task đã được ẩn trước đó',
            200
        );
    }

    // Tạo mới
    const hiddenTask = new HiddenTask({
        season: seasonObjectId,
        taskName: taskName,
        user: userId,
        reason: reason
    });

    await hiddenTask.save();

    return successResponse(
        res,
        { hidden: true },
        'Đã ẩn task thành công',
        201
    );
}));

/**
 * DELETE /api/seasons/:seasonId
 * Chức năng: Xóa một mùa vụ
 */
router.delete('/:seasonId', asyncHandler(async (req, res) => {
    const { seasonId } = req.params;

    // Validate ObjectId
    if (!mongoose.Types.ObjectId.isValid(seasonId)) {
        return errorResponse(res, 'Season ID không hợp lệ', 400);
    }

    const seasonObjectId = new mongoose.Types.ObjectId(seasonId);

    // Tìm mùa vụ
    const season = await FarmSeason.findOne({
        _id: seasonObjectId
    });

    if (!season) {
        return errorResponse(res, 'Không tìm thấy mùa vụ', 404);
    }

    // Xóa tất cả dữ liệu liên quan
    await Promise.all([
        FarmSeason.deleteOne({ _id: seasonObjectId }),
        LogEntry.deleteMany({ season: seasonObjectId }),
        HiddenTask.deleteMany({ season: seasonObjectId })
    ]);

    return successResponse(
        res,
        { deleted: true },
        'Đã xóa mùa vụ thành công',
        200
    );
}));

module.exports = router;