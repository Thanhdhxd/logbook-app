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

    console.log('\n📋 Lấy công việc hôm nay:');
    console.log('  - Ngày thứ:', currentDay);
    console.log('  - Season ID:', seasonId);
    console.log('  - Season ObjectId:', seasonObjectId);

    // 🔒 Bước 1: Lấy danh sách tasks đã bị ẩn (bỏ qua)
    const hiddenTasks = await HiddenTask.find({
        season: seasonObjectId
    }).select('taskName reason hiddenDate').lean();
    
    const hiddenTaskNames = new Set(hiddenTasks.map(ht => ht.taskName));

    // 🔒 Bước 2: Lấy danh sách tasks đã hoàn thành (chỉ lấy trong 7 ngày gần đây)
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);
    
    const completedLogs = await LogEntry.find({
        season: seasonObjectId,
        status: 'DONE',
        completedAt: { $gte: sevenDaysAgo }
    }).select('taskName').lean();
    
    const completedTaskNames = new Set(completedLogs.map(log => log.taskName));

    // ❌ BỎ QUA: Không lấy tasks từ template nữa
    // Người dùng sẽ tự tạo nhật ký thủ công

    // 📝 Bước 3: Lấy manual logs (tasks tự tạo) gần đây - CHỈ 7 NGÀY
    const manualLogs = await LogEntry.find({
        season: seasonObjectId,
        logType: 'manual',
        completedAt: {
            $exists: true,
            $ne: null,
            $gte: sevenDaysAgo
        }
    }).select('taskName notes usedMaterials completedAt location').sort({ completedAt: -1 }).lean();

    // Bước 4.1: Gộp manual logs theo taskName (lấy log MỚI NHẤT của mỗi task)
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

    console.log(`📦 Sau khi gộp: ${manualLogsMap.size} tasks unique`);

    // Bước 4.2: Lọc bỏ tasks đã ẩn (CHỈ HIỂN THỊ nếu log được tạo SAU khi ẩn)
    const finalManualLogs = new Map();
    manualLogsMap.forEach((log, taskName) => {
        if (hiddenTaskNames.has(taskName)) {
            // Tìm thời gian ẩn task
            const hiddenTask = hiddenTasks.find(ht => ht.taskName === taskName);
            const hiddenDate = hiddenTask ? new Date(hiddenTask.hiddenDate) : null;
            
            // QUAN TRỌNG: Dùng _id.getTimestamp() để lấy thời gian tạo document THẬT
            // Đây là thời gian server tạo record, không thể giả mạo
            const logCreatedAt = log._id.getTimestamp();
            
            // Chỉ hiển thị nếu log được TẠO SAU khi ẩn
            if (hiddenDate && logCreatedAt > hiddenDate) {
                console.log(`  ✅ Task "${taskName}" được tạo SAU khi ẩn (${logCreatedAt.toISOString()} > ${hiddenDate.toISOString()}) → Hiển thị`);
                finalManualLogs.set(taskName, log);
            } else {
                console.log(`  ⏭️ Task "${taskName}" được tạo TRƯỚC khi ẩn (${logCreatedAt.toISOString()} <= ${hiddenDate.toISOString()}) → Ẩn`);
            }
        } else {
            // Task chưa bị ẩn bao giờ → Hiển thị
            console.log(`  ✅ Task "${taskName}" chưa bị ẩn → Hiển thị`);
            finalManualLogs.set(taskName, log);
        }
    });

    // Thêm manual logs vào danh sách tasks
    finalManualLogs.forEach((log, taskName) => {
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
    
    console.log('\n🚫 POST /hide-task');
    console.log('  - seasonId:', seasonId);
    console.log('  - taskName:', taskName);
    console.log('  - reason:', reason);

    // Validation
    if (!seasonId || !taskName || !reason) {
        console.log('❌ Thiếu thông tin bắt buộc');
        return errorResponse(res, 'Thiếu thông tin bắt buộc', 400);
    }

    if (!['DONE', 'SKIPPED'].includes(reason)) {
        console.log('❌ Lý do không hợp lệ:', reason);
        return errorResponse(res, 'Lý do không hợp lệ', 400);
    }

    // Convert seasonId sang ObjectId nếu cần
    const seasonObjectId = mongoose.Types.ObjectId.isValid(seasonId) 
        ? new mongoose.Types.ObjectId(seasonId) 
        : seasonId;

    // ✅ Sử dụng findOneAndUpdate với upsert để tránh duplicate
    try {
        const hiddenTask = await HiddenTask.findOneAndUpdate(
            {
                season: seasonObjectId,
                taskName: taskName
            },
            {
                season: seasonObjectId,
                taskName: taskName,
                reason: reason,
                hiddenDate: new Date()
            },
            {
                upsert: true,  // Tạo mới nếu chưa tồn tại
                new: true,     // Trả về document sau khi update
                setDefaultsOnInsert: true
            }
        );

        console.log('✅ Đã ẩn task thành công:', hiddenTask._id);

        return successResponse(
            res,
            { hidden: true, hiddenTaskId: hiddenTask._id },
            'Đã ẩn task thành công',
            201
        );
    } catch (error) {
        console.error('❌ Lỗi khi ẩn task:', error);
        return errorResponse(res, 'Lỗi khi ẩn task: ' + error.message, 500);
    }
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