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
 * Chức năng: Lấy danh sách công việc cần làm hôm nay (đã fix logic ẩn task)
 */
router.get('/daily/:seasonId', asyncHandler(async (req, res) => {
    const { seasonId } = req.params;
    
    // 1. Kiểm tra Season và Convert ID chuẩn
    if (!mongoose.Types.ObjectId.isValid(seasonId)) {
        return errorResponse(res, 'ID mùa vụ không hợp lệ', 400);
    }
    const seasonObjectId = new mongoose.Types.ObjectId(seasonId);

    const season = await FarmSeason.findById(seasonObjectId).populate('planTemplate');
    if (!season) {
        return errorResponse(res, 'Không tìm thấy mùa vụ', 404);
    }

    const currentDay = getDaysSinceStart(season.startDate);
    let dailyTasks = [];

    // 2. Lấy danh sách các task đã bị ẩn (Bỏ qua hoặc Hoàn thành)
    // Chúng ta lấy trước để lọc ngay khi duyệt log
    const hiddenTasks = await HiddenTask.find({ season: seasonObjectId });
    // Chuyển thành Set và trim() để so sánh chính xác tuyệt đối
    const hiddenTaskNames = new Set(hiddenTasks.map(ht => ht.taskName.trim()));

    // 3. Lấy manual logs trong 30 ngày qua
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
    }).sort({ completedAt: -1 });

    // 4. Gộp logs và LỌC BỎ task đã ẩn
    const manualLogsMap = new Map();

    manualLogs.forEach(log => {
        const normalizedName = log.taskName.trim();
        
        // CHỈ xử lý nếu task này CHƯA nằm trong danh sách ẩn
        if (!hiddenTaskNames.has(normalizedName)) {
            if (!manualLogsMap.has(normalizedName)) {
                manualLogsMap.set(normalizedName, log);
            } else {
                // Giữ lại log mới nhất
                const existing = manualLogsMap.get(normalizedName);
                if (new Date(log.completedAt) > new Date(existing.completedAt)) {
                    manualLogsMap.set(normalizedName, log);
                }
            }
        }
    });

    // 5. Build danh sách trả về
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
        farmArea: season.farmArea,
        tasks: dailyTasks
    }, `Công việc hiện tại của mùa vụ`);
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