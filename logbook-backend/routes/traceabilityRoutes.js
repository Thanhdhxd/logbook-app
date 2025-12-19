// routes/traceabilityRoutes.js
const express = require('express');
const router = express.Router();
const FarmSeason = require('../models/FarmSeason');
const LogEntry = require('../models/LogEntry');
const PlanTemplate = require('../models/PlanTemplate');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { asyncHandler } = require('../middleware/errorHandler');
const { MESSAGES } = require('../config/constants');

/**
 * GET /api/traceability/:seasonId
 * Chức năng: Truy xuất nguồn gốc - Lấy toàn bộ thông tin chi tiết của mùa vụ
 */
router.get('/:seasonId', asyncHandler(async (req, res) => {
    const { seasonId } = req.params;

    // 1. Lấy thông tin mùa vụ
    const season = await FarmSeason.findById(seasonId)
        .populate('planTemplate');

    if (!season) {
        return errorResponse(res, 'Không tìm thấy mã lô/mùa vụ', 404);
    }

    // 2. Lấy tất cả nhật ký đã thực hiện trong mùa vụ này
    const logEntries = await LogEntry.find({ 
        season: seasonId,
        status: 'DONE' // Chỉ lấy công việc đã hoàn thành
    }).sort({ logDate: 1 }); // Sắp xếp theo thời gian

    // 3. Tổ chức dữ liệu theo giai đoạn - HIỂN THỊ TẤT CẢ tasks từ template
    const template = season.planTemplate;
    const stagesWithLogs = [];

    if (template && template.stages) {
        for (const stage of template.stages) {
            const stageTasks = [];
            
            // Lấy TẤT CẢ tasks trong giai đoạn (từ template)
            for (const task of stage.tasks) {
                const taskLogs = logEntries.filter(log => 
                    log.taskName === task.taskName
                );

                // Tạo thông tin task (dù đã làm hay chưa)
                const taskInfo = {
                    taskName: task.taskName,
                    isCompleted: taskLogs.length > 0,
                    completedDates: [],
                    materials: [],
                    notes: '',
                    scheduledDate: task.scheduledDate || null, // Ngày dự kiến từ template
                    suggestedMaterials: task.suggestedMaterials || []
                };

                if (taskLogs.length > 0) {
                    // Task đã hoàn thành - gộp tất cả logs
                    const allMaterials = [];
                    let notes = [];

                    taskLogs.forEach(log => {
                        if (log.usedMaterials && log.usedMaterials.length > 0) {
                            allMaterials.push(...log.usedMaterials);
                        }
                        if (log.notes) {
                            notes.push(log.notes);
                        }
                    });

                    taskInfo.completedDates = taskLogs.map(log => log.logDate);
                    taskInfo.materials = allMaterials;
                    taskInfo.notes = notes.join('; ');
                }

                stageTasks.push(taskInfo);
            }

            // Thêm TẤT CẢ giai đoạn (kể cả chưa có log)
            stagesWithLogs.push({
                stageName: stage.stageName,
                startDay: stage.startDay,
                endDay: stage.endDay,
                tasks: stageTasks
            });
        }
    }

    // 4. Tạo response
    const traceabilityData = {
        lotCode: season._id, // Mã lô
        seasonName: season.seasonName,
        farmArea: season.farmArea,
        startDate: season.startDate,
        harvestDate: null, // Có thể tính toán hoặc lấy từ log cuối cùng
        stages: stagesWithLogs,
        templateName: template ? template.templateName : 'Không có kế hoạch',
        cropType: template ? template.cropType : 'N/A'
    };

    // Tính ngày thu hoạch (dựa vào log cuối cùng)
    if (logEntries.length > 0) {
        const lastLog = logEntries[logEntries.length - 1];
        traceabilityData.harvestDate = lastLog.logDate;
    }

    return successResponse(
        res, 
        { traceability: traceabilityData },
        'Lấy thông tin truy xuất nguồn gốc thành công'
    );
}));

/**
 * GET /api/traceability/search/:lotCode
 * Chức năng: Tìm kiếm theo mã lô (có thể dùng QR code)
 */
router.get('/search/:lotCode', asyncHandler(async (req, res) => {
    const { lotCode } = req.params;

    // Tìm season theo ID hoặc theo seasonName
    const season = await FarmSeason.findOne({
        $or: [
            { _id: lotCode },
            { seasonName: lotCode }
        ]
    });

    if (!season) {
        return errorResponse(res, 'Không tìm thấy thông tin với mã lô này', 404);
    }

    // Redirect sang endpoint chính
    return res.redirect(`/api/traceability/${season._id}`);
}));

module.exports = router;
