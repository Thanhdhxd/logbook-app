// routes/blockchainRoutes.js
const express = require('express');
const router = express.Router();
const LogEntry = require('../models/LogEntry');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { asyncHandler } = require('../middleware/errorHandler');
const crypto = require('crypto');

/**
 * POST /api/blockchain/record
 * Ghi log lên blockchain (simulated)
 */
router.post('/record', asyncHandler(async (req, res) => {
    const { logId, taskName, seasonId, materials, timestamp } = req.body;

    if (!logId || !taskName || !seasonId) {
        return errorResponse(res, 'Missing required fields', 400);
    }

    // Simulate blockchain transaction
    // Trong production, tích hợp với Ethereum/Hyperledger/etc
    const dataToHash = JSON.stringify({
        logId,
        taskName,
        seasonId,
        materials,
        timestamp
    });
    
    const transactionHash = '0x' + crypto.createHash('sha256')
        .update(dataToHash)
        .digest('hex');
    
    const blockNumber = Math.floor(Math.random() * 1000000) + 1000000;

    // Lưu transaction info vào log entry
    await LogEntry.findByIdAndUpdate(logId, {
        blockchainHash: transactionHash,
        blockchainBlock: blockNumber,
        blockchainVerified: true,
        blockchainTimestamp: new Date()
    });

    return successResponse(res, {
        transactionHash,
        blockNumber,
        verified: true,
        message: 'Log recorded on blockchain (simulated)'
    }, 'Blockchain record successful', 201);
}));

/**
 * GET /api/blockchain/verify/:logId
 * Xác thực log từ blockchain
 */
router.get('/verify/:logId', asyncHandler(async (req, res) => {
    const { logId } = req.params;

    const log = await LogEntry.findById(logId);
    
    if (!log) {
        return errorResponse(res, 'Log not found', 404);
    }

    if (!log.blockchainHash) {
        return successResponse(res, {
            verified: false,
            message: 'Log not recorded on blockchain'
        });
    }

    // Simulate blockchain verification
    return successResponse(res, {
        verified: log.blockchainVerified,
        transactionHash: log.blockchainHash,
        blockNumber: log.blockchainBlock,
        timestamp: log.blockchainTimestamp,
        message: 'Blockchain verification successful'
    });
}));

/**
 * GET /api/blockchain/trace/:seasonId
 * Truy xuất nguồn gốc toàn bộ mùa vụ
 */
router.get('/trace/:seasonId', asyncHandler(async (req, res) => {
    const { seasonId } = req.params;

    const logs = await LogEntry.find({ 
        season: seasonId,
        blockchainVerified: true 
    })
    .sort({ logDate: 1 })
    .select('taskName usedMaterials logDate blockchainHash blockchainBlock');

    const traceData = logs.map(log => ({
        date: log.logDate,
        task: log.taskName,
        materials: log.usedMaterials,
        blockchain: {
            hash: log.blockchainHash,
            block: log.blockchainBlock
        }
    }));

    return successResponse(res, {
        seasonId,
        totalRecords: logs.length,
        trace: traceData
    }, 'Traceability data retrieved');
}));

module.exports = router;
