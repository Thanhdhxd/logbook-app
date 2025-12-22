// routes/seasonRoutes.js
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const FarmSeason = require('../models/FarmSeason');
const PlanTemplate = require('../models/PlanTemplate');
const LogEntry = require('../models/LogEntry');
const HiddenTask = require('../models/HiddenTask'); // Import model HiddenTask
const { getDaysSinceStart } = require('../utils/dateUtils');
const { isAuth } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { asyncHandler } = require('../middleware/errorHandler');
const { MESSAGES } = require('../config/constants');

/**
 * POST /api/seasons
 * Chức năng: Bắt đầu một mùa vụ mới
 */
router.post('/', asyncHandler(async (req, res) => {
    const { seasonName, farmArea, startDate } = req.body;
    
    if (!seasonName || !farmArea || !startDate) {
        return errorResponse(res, MESSAGES.ERROR.MISSING_FIELDS, 400);
    }
    
    // Lấy user demo
    const User = require('../models/User');
    let user = await User.findOne();
    if (!user) {
        user = await User.create({
            name: 'Demo User',
            email: 'demo@example.com',
            password: 'demo123'
        });
    }
    
    // Tự động tìm Template phù hợp
    let matchedTemplate = null;
    const allTemplates = await PlanTemplate.find();
    
    for (const template of allTemplates) {
        const cropType = template.cropType;
        if (cropType && seasonName.includes(cropType)) {
            matchedTemplate = template._id;
            break;
        }
    }
    
    const newSeason = new FarmSeason({
        seasonName,
        farmArea,
        planTemplate: matchedTemplate,
        startDate: new Date(startDate),
        user: user._id
    });

    const savedSeason = await newSeason.save();
    
    return successResponse(res, { season: savedSeason }, MESSAGES.SUCCESS.SEASON_CREATED, 201);
}));

/**
 * GET /api/seasons/daily/:seasonId
 * Chức năng: Lấy danh sách công việc cần làm hôm nay (Đã Fix lỗi hiển thị task ẩn)
 */
router.get('/daily/:seasonId', asyncHandler(async (req, res) => {
    const { seasonId } = req.params;
    
    // 1. Kiểm tra ID hợp lệ và lấy thông tin mùa vụ
    if (!mongoose.Types.ObjectId.isValid(seasonId)) {
        return errorResponse(res, 'Season ID không hợp lệ', 400);
    }
    const seasonObjectId = new mongoose.Types.ObjectId(seasonId);

    const season = await FarmSeason.findById(seasonObjectId).populate('planTemplate');
    if (!season) {
        return errorResponse(res, 'Không tìm thấy mùa vụ', 404);
    }

    // 2. [QUAN TRỌNG] Lấy danh sách các task đã bị ẩn (SKIPPED hoặc DONE vĩnh viễn)
    const hiddenTasks = await HiddenTask.find({ 
        season: seasonObjectId 
    }).distinct('taskName'); // Trả về mảng tên các task: ['Bón phân', 'Làm đất']

    console.log(`🔍 Hidden tasks for season ${seasonId}:`, hiddenTasks);

    const currentDay = getDaysSinceStart(season.startDate);
    let dailyTasks = [];
    let currentStageName = "Chưa xác định";

    // 3. LẤY TASKS TỪ KẾ HOẠCH MẪU (SCHEDULED)
    if (season.planTemplate && season.planTemplate.stages) {
        season.planTemplate.stages.forEach(stage => {
            // Kiểm tra xem hôm nay có thuộc giai đoạn này không
            if (currentDay >= stage.startDay && currentDay <= stage.endDay) {
                currentStageName = stage.stageName;

                stage.tasks.forEach(templateTask => {
                    // [FIX LOGIC]: Kiểm tra tên task có nằm trong danh sách ẩn không
                    // Sử dụng trim() để tránh lỗi do khoảng trắng thừa
                    if (hiddenTasks.includes(templateTask.taskName.trim())) {
                        // Nếu đã ẩn -> Bỏ qua, không thêm vào danh sách hiển thị
                        return; 
                    }

                    dailyTasks.push({
                        type: 'scheduled',
                        taskName: templateTask.taskName,
                        frequency: templateTask.frequency,
                        suggestedMaterials: templateTask.suggestedMaterials || [],
                        status: 'TODO',
                        isTemplate: true
                    });
                });
            }
        });
    }

    // 4. LẤY NHẬT KÝ ĐÃ GHI HÔM NAY (Để cập nhật trạng thái DONE/SKIPPED cho task hiển thị)
    const startOfToday = new Date(); startOfToday.setHours(0,0,0,0);
    const endOfToday = new Date(); endOfToday.setHours(23,59,59,999);

    const logsToday = await LogEntry.find({
        season: seasonObjectId,
        logDate: { $gte: startOfToday, $lte: endOfToday }
    });

    // 5. MERGE DỮ LIỆU
    dailyTasks = dailyTasks.map(planTask => {
        const matchedLog = logsToday.find(l => l.taskName === planTask.taskName);
        if (matchedLog) {
            return {
                ...planTask,
                status: matchedLog.status,
                logId: matchedLog._id,
                completedAt: matchedLog.logDate
            };
        }
        return planTask;
    });

    // Thêm các task 'manual' (làm ngoài kế hoạch) vào danh sách
    // Lưu ý: Phần này không check hiddenTasks để đảm bảo task thủ công bạn vừa tạo (dù trùng tên task ẩn) vẫn hiện lên
    logsToday.forEach(log => {
        const isPlanned = dailyTasks.some(t => t.taskName === log.taskName);
        if (!isPlanned) {
            dailyTasks.push({
                type: 'manual',
                taskName: log.taskName,
                status: log.status,
                usedMaterials: log.usedMaterials,
                completedAt: log.logDate,
                isTemplate: false,
                notes: log.notes,
                area: log.location
            });
        }
    });

    return successResponse(res, {
        seasonName: season.seasonName,
        currentDay,
        currentStage: currentStageName,
        tasks: dailyTasks
    }, `Công việc ngày thứ ${currentDay}`);
}));

/**
 * POST /api/seasons/hide-task
 * Chức năng: Ẩn task vĩnh viễn
 */
router.post('/hide-task', asyncHandler(async (req, res) => {
    const { seasonId, taskName, reason } = req.body;
    
    // Lấy user đầu tiên
    const User = require('../models/User');
    const user = await User.findOne();
    const userId = user ? user._id : null;

    if (!seasonId || !taskName || !reason) {
        return errorResponse(res, 'Thiếu thông tin bắt buộc', 400);
    }

    const seasonObjectId = mongoose.Types.ObjectId.isValid(seasonId) 
        ? new mongoose.Types.ObjectId(seasonId) 
        : seasonId;

    // Kiểm tra xem đã tồn tại chưa
    const existing = await HiddenTask.findOne({
        season: seasonObjectId,
        taskName: taskName
    });

    if (existing) {
        return successResponse(res, { hidden: true }, 'Task đã được ẩn trước đó', 200);
    }

    // Tạo mới HiddenTask
    const hiddenTask = new HiddenTask({
        season: seasonObjectId,
        taskName: taskName, // Tên này sẽ dùng để lọc ở API GET /daily
        user: userId,
        reason: reason
    });

    await hiddenTask.save();

    return successResponse(res, { hidden: true }, 'Đã ẩn task thành công', 201);
}));

/**
 * GET /api/seasons/user
 */
router.get('/user', asyncHandler(async (req, res) => {
    const seasons = await FarmSeason.find({ isActive: true })
        .select('_id seasonName farmArea startDate')
        .sort({ createdAt: -1 });

    if (seasons.length === 0) return errorResponse(res, 'Chưa có mùa vụ nào', 404);

    return successResponse(res, { seasons }, MESSAGES.SUCCESS.DATA_RETRIEVED);
}));

/**
 * DELETE /api/seasons/:seasonId
 */
router.delete('/:seasonId', asyncHandler(async (req, res) => {
    const { seasonId } = req.params;
    if (!mongoose.Types.ObjectId.isValid(seasonId)) {
        return errorResponse(res, 'Season ID không hợp lệ', 400);
    }
    const seasonObjectId = new mongoose.Types.ObjectId(seasonId);

    const season = await FarmSeason.findOne({ _id: seasonObjectId });
    if (!season) return errorResponse(res, 'Không tìm thấy mùa vụ', 404);

    await Promise.all([
        FarmSeason.deleteOne({ _id: seasonObjectId }),
        LogEntry.deleteMany({ season: seasonObjectId }),
        HiddenTask.deleteMany({ season: seasonObjectId })
    ]);

    return successResponse(res, { deleted: true }, 'Đã xóa mùa vụ thành công', 200);
}));

module.exports = router;