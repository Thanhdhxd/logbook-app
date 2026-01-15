// routes/logbookRoutes.js
const express = require('express');
const router = express.Router();
const mongoose = require('mongoose');
const LogEntry = require('../models/LogEntry');
const { isAuth } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { asyncHandler } = require('../middleware/errorHandler');
const { MESSAGES, TASK_STATUS } = require('../config/constants');

/**
 * POST /api/logbook
 * Chức năng: Ghi nhật ký công việc
 */
router.post('/', asyncHandler(async (req, res) => {
    const { season, taskName, status, usedMaterials = [], notes, logType = 'scheduled', location, completedAt } = req.body;

    // Validation
    if (!season || !taskName || !status) {
        return errorResponse(res, MESSAGES.ERROR.MISSING_FIELDS, 400);
    }

    // Kiểm tra status hợp lệ
    const validStatuses = Object.values(TASK_STATUS);
    if (!validStatuses.includes(status)) {
        return errorResponse(res, 'Trạng thái không hợp lệ', 400);
    }

    // Lấy user đầu tiên
    const User = require('../models/User');
    const user = await User.findOne();
    const userId = user ? user._id : null;

    const newLogEntry = new LogEntry({
        season,
        taskName,
        status,
        logType,
        usedMaterials,
        notes,
        location,
        completedAt: completedAt ? new Date(completedAt) : new Date(),
        user: userId,
        logDate: new Date()
    });

    const savedLog = await newLogEntry.save();
    
    
    console.log('✅ Saved manual log:', {
        _id: savedLog._id,
        season: savedLog.season,
        taskName: savedLog.taskName,
        logType: savedLog.logType,
        status: savedLog.status,
        completedAt: savedLog.completedAt
    });
    
    // ✅ CHỈ ẩn task khi XÁC NHẬN từ UI (scheduled), KHÔNG ẩn khi TẠO THỦ CÔNG (manual)
    if (status === 'DONE' && logType === 'scheduled') {
        const HiddenTask = require('../models/HiddenTask');
        const mongoose = require('mongoose');
        
        const seasonObjectId = mongoose.Types.ObjectId.isValid(season) 
            ? new mongoose.Types.ObjectId(season) 
            : season;
        
        try {
            await HiddenTask.findOneAndUpdate(
                {
                    season: seasonObjectId,
                    taskName: taskName
                },
                {
                    season: seasonObjectId,
                    taskName: taskName,
                    reason: 'DONE',
                    hiddenDate: new Date()
                },
                {
                    upsert: true,
                    new: true,
                    setDefaultsOnInsert: true
                }
            );
            console.log(`✅ Đã ẩn task "${taskName}" sau khi xác nhận từ UI`);
        } catch (error) {
            console.error('⚠️ Lỗi khi ẩn task:', error);
            // Không throw error, vì log đã lưu thành công
        }
    } else if (logType === 'manual') {
        console.log(`📝 Task thủ công "${taskName}" được tạo - KHÔNG tự động ẩn`);
    }
    
    // Track material usage for favorites
    if (usedMaterials && usedMaterials.length > 0 && userId) {
        const MaterialUsage = require('../models/MaterialUsage');
        for (const material of usedMaterials) {
            try {
                const existing = await MaterialUsage.findOne({
                    user: userId,
                    materialName: material.materialName
                });
                
                if (existing) {
                    existing.usageCount += 1;
                    existing.lastUsedAt = new Date();
                    await existing.save();
                } else {
                    await MaterialUsage.create({
                        user: userId,
                        materialName: material.materialName,
                        usageCount: 1
                    });
                }
            } catch (err) {
                console.error('Error tracking material usage:', err);
            }
        }
    }
    
    // Blockchain Integration: Record log on blockchain
    try {
        const crypto = require('crypto');
        const logData = JSON.stringify({
            logId: savedLog._id,
            season: savedLog.season,
            taskName: savedLog.taskName,
            status: savedLog.status,
            timestamp: savedLog.createdAt
        });
        
        // Generate blockchain hash
        const txHash = crypto.createHash('sha256').update(logData).digest('hex');
        const blockNumber = Math.floor(Date.now() / 1000); // Mock block number
        
        // Update log with blockchain data
        savedLog.blockchainHash = txHash;
        savedLog.blockchainBlock = blockNumber;
        savedLog.blockchainVerified = true;
        savedLog.blockchainTimestamp = new Date();
        await savedLog.save();
    } catch (err) {
        console.error('⚠️ Blockchain recording failed:', err.message);
    }

    return successResponse(
        res, 
        { log: savedLog }, 
        `${MESSAGES.SUCCESS.LOG_CREATED} (${status})`, 
        201
    );
}));

/**
 * GET /api/logbook/season/:seasonId
 * Chức năng: Lấy manual logs của một mùa vụ (không bao gồm scheduled task logs)
 */
router.get('/season/:seasonId', asyncHandler(async (req, res) => {
    const { seasonId } = req.params;

    // Lấy tất cả logs NGOẠI TRỪ scheduled logs
    const logs = await LogEntry.find({
        season: seasonId,
        logType: { $ne: 'scheduled' }
    })
    .sort({ logDate: -1 })
    .select('taskName status usedMaterials notes logDate');

    return successResponse(
        res,
        { logs },
        MESSAGES.SUCCESS.DATA_RETRIEVED,
        200
    );
}));

/**
 * POST /api/logbook/hide
 * Chức năng: Ẩn task vĩnh viễn (bỏ qua)
 */
router.post('/hide', asyncHandler(async (req, res) => {
    const { season, taskName } = req.body;
    
    console.log('\n🚫 POST /api/logbook/hide');
    console.log('  - season:', season);
    console.log('  - taskName:', taskName);

    // Validation
    if (!season || !taskName) {
        console.log('❌ Thiếu thông tin bắt buộc');
        return errorResponse(res, 'Thiếu thông tin bắt buộc', 400);
    }

    // Convert season sang ObjectId nếu cần
    const seasonObjectId = mongoose.Types.ObjectId.isValid(season) 
        ? new mongoose.Types.ObjectId(season) 
        : season;

    // Tạo hidden task
    const HiddenTask = require('../models/HiddenTask');
    
    try {
        const hiddenTask = await HiddenTask.findOneAndUpdate(
            {
                season: seasonObjectId,
                taskName: taskName
            },
            {
                season: seasonObjectId,
                taskName: taskName,
                reason: 'SKIPPED',
                hiddenDate: new Date()
            },
            {
                upsert: true,
                new: true,
                setDefaultsOnInsert: true
            }
        );

        console.log('✅ Đã ẩn task thành công:', hiddenTask._id);

        return successResponse(
            res,
            { hidden: true, hiddenTaskId: hiddenTask._id },
            'Đã ẩn task thành công',
            200
        );
    } catch (error) {
        console.error('❌ Lỗi khi ẩn task:', error);
        return errorResponse(res, 'Lỗi khi ẩn task: ' + error.message, 500);
    }
}));

module.exports = router;