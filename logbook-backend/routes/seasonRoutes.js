// routes/seasonRoutes.js
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const FarmSeason = require('../models/FarmSeason');
const PlanTemplate = require('../models/PlanTemplate');
const LogEntry = require('../models/LogEntry');
const HiddenTask = require('../models/HiddenTask');
const { getDaysSinceStart } = require('../utils/dateUtils');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { asyncHandler } = require('../middleware/errorHandler');
const { MESSAGES } = require('../config/constants');

/**
 * POST /api/seasons
 * Bắt đầu mùa vụ mới
 */
router.post('/', asyncHandler(async (req, res) => {
    const { seasonName, farmArea, startDate } = req.body;

    if (!seasonName || !farmArea || !startDate) {
        return errorResponse(res, MESSAGES.ERROR.MISSING_FIELDS, 400);
    }

    const User = require('../models/User');
    let user = await User.findOne();
    if (!user) {
        user = await User.create({
            name: 'Demo User',
            email: 'demo@example.com',
            password: 'demo123'
        });
    }

    let matchedTemplate = null;
    const allTemplates = await PlanTemplate.find();
    for (const template of allTemplates) {
        if (template.cropType && seasonName.includes(template.cropType)) {
            matchedTemplate = template._id;
            break;
        }
    }

    const season = await FarmSeason.create({
        seasonName,
        farmArea,
        planTemplate: matchedTemplate,
        startDate: new Date(startDate),
        user: user._id
    });

    return successResponse(res, { season }, 'Tạo mùa vụ thành công', 201);
}));

/**
 * GET /api/seasons/daily/:seasonId
 * Lấy công việc cần làm hôm nay (CHỈ task thủ công + lọc task bị bỏ qua)
 */
router.get('/daily/:seasonId', asyncHandler(async (req, res) => {
    const { seasonId } = req.params;

    const season = await FarmSeason.findById(seasonId);
    if (!season) {
        return errorResponse(res, 'Không tìm thấy mùa vụ', 404);
    }

    const currentDay = getDaysSinceStart(season.startDate);
    const seasonObjectId = new mongoose.Types.ObjectId(seasonId);

    // Lấy user demo
    const User = require('../models/User');
    const user = await User.findOne();
    const userId = user ? user._id : null;

    // 🔥 LẤY DANH SÁCH TASK ĐÃ BỎ QUA (ẨN VĨNH VIỄN)
    const skippedTasks = await HiddenTask.find({
        season: seasonObjectId,
        user: userId,
        reason: 'SKIPPED'
    }).select('taskName');

    const skippedTaskNames = skippedTasks.map(t => t.taskName);

    // Lấy nhật ký thủ công 30 ngày gần nhất
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const manualLogs = await LogEntry.find({
        season: seasonObjectId,
        logType: 'manual',
        completedAt: { $ne: null, $gte: thirtyDaysAgo }
    }).sort({ completedAt: -1 });

    // Gộp theo taskName (lấy log mới nhất)
    const map = new Map();
    manualLogs.forEach(log => {
        if (!map.has(log.taskName)) {
            map.set(log.taskName, log);
        }
    });

    const dailyTasks = [];

    map.forEach((log, taskName) => {

        // ❗ Nếu task đã bị bỏ qua → KHÔNG HIỂN THỊ
        if (skippedTaskNames.includes(taskName)) return;

        dailyTasks.push({
            taskId: log._id.toString(),
            taskName: log.taskName,
            usedMaterials: log.usedMaterials || [],
            frequency: 'Nhật ký thủ công',
            area: log.location || season.farmArea,
            status: 'DONE',
            notes: log.notes,
            completedAt: log.completedAt
        });
    });

    return successResponse(res, {
        currentDay,
        farmArea: season.farmArea,
        tasks: dailyTasks
    }, 'Công việc cần làm hôm nay');
}));

/**
 * POST /api/seasons/hide-task
 * 👉 BỎ QUA TASK = ẨN VĨNH VIỄN
 */
router.post('/hide-task', asyncHandler(async (req, res) => {
    const { seasonId, taskName } = req.body;

    if (!seasonId || !taskName) {
        return errorResponse(res, 'Thiếu thông tin', 400);
    }

    const User = require('../models/User');
    const user = await User.findOne();
    const userId = user ? user._id : null;

    const seasonObjectId = new mongoose.Types.ObjectId(seasonId);

    const existed = await HiddenTask.findOne({
        season: seasonObjectId,
        user: userId,
        taskName,
        reason: 'SKIPPED'
    });

    if (!existed) {
        await HiddenTask.create({
            season: seasonObjectId,
            user: userId,
            taskName,
            reason: 'SKIPPED'
        });
    }

    return successResponse(res, { hidden: true }, 'Đã bỏ qua task');
}));

/**
 * DELETE /api/seasons/:seasonId
 * Xóa mùa vụ
 */
router.delete('/:seasonId', asyncHandler(async (req, res) => {
    const seasonObjectId = new mongoose.Types.ObjectId(req.params.seasonId);

    await Promise.all([
        FarmSeason.deleteOne({ _id: seasonObjectId }),
        LogEntry.deleteMany({ season: seasonObjectId }),
        HiddenTask.deleteMany({ season: seasonObjectId })
    ]);

    return successResponse(res, { deleted: true }, 'Đã xóa mùa vụ');
}));

module.exports = router;
