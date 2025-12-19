const express = require('express');
const router = express.Router();
const Material = require('../models/Material'); 
const PlanTemplate = require('../models/PlanTemplate'); 
const LogEntry = require('../models/LogEntry');
const { isAuth } = require('../middleware/auth');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { asyncHandler } = require('../middleware/errorHandler');
const { MESSAGES } = require('../config/constants');
const mongoose = require('mongoose');

// Middleware isAdmin (giữ nguyên)
const isAdmin = (req, res, next) => { next(); };

/**
 * POST /api/materials
 * Chức năng: Admin thêm vật tư mới
 */
router.post('/', isAdmin, asyncHandler(async (req, res) => {
    const newMaterial = new Material(req.body);
    const savedMaterial = await newMaterial.save();
    return successResponse(res, { material: savedMaterial }, 'Tạo vật tư thành công', 201);
}));

/**
 * GET /api/materials
 * Chức năng: Lấy danh sách tất cả vật tư
 */
router.get('/', asyncHandler(async (req, res) => {
    const materials = await Material.find({});
    return successResponse(res, { materials }, MESSAGES.SUCCESS.DATA_RETRIEVED);
}));

/**
 * GET /api/materials/favorites
 * Chức năng: Lấy vật tư hay dùng nhất của user (top 10)
 */
router.get('/favorites', asyncHandler(async (req, res) => {
    // Lấy user đầu tiên
    const User = require('../models/User');
    const user = await User.findOne();
    if (!user) {
        return successResponse(res, { materials: [] }, 'Chưa có dữ liệu');
    }
    
    const userId = user._id;
    
    // Aggregate để đếm số lần dùng mỗi vật tư
    const favorites = await LogEntry.aggregate([
        { $match: { user: userId } },
        { $unwind: '$usedMaterials' },
        { 
            $group: {
                _id: '$usedMaterials.materialName',
                count: { $sum: 1 },
                totalQuantity: { $sum: '$usedMaterials.quantity' },
                unit: { $first: '$usedMaterials.unit' }
            }
        },
        { $sort: { count: -1 } },
        { $limit: 10 },
        {
            $project: {
                _id: 0,
                materialName: '$_id',
                usageCount: '$count',
                totalQuantity: '$totalQuantity',
                unit: '$unit'
            }
        }
    ]);
    
    return successResponse(res, { favorites }, 'Lấy vật tư hay dùng thành công');
}));

/**
 * PUT /api/materials/:id
 * Chức năng: Cập nhật vật tư
 */
router.put('/:id', isAdmin, asyncHandler(async (req, res) => {
    const updatedMaterial = await Material.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedMaterial) {
        return errorResponse(res, 'Không tìm thấy vật tư để cập nhật', 404);
    }   
    return successResponse(res, { material: updatedMaterial }, 'Cập nhật vật tư thành công');
}));

/**
 * DELETE /api/materials/:id
 * Chức năng: Xóa vật tư
 */
router.delete('/:id', isAdmin, asyncHandler(async (req, res) => {
    const deletedMaterial = await Material.findByIdAndDelete(req.params.id);
    if (!deletedMaterial) {
        return errorResponse(res, 'Không tìm thấy vật tư để xóa', 404);
    }
    return successResponse(res, { material: deletedMaterial }, 'Xóa vật tư thành công');
}));

/**
 * GET /api/materials/suggested/:seasonId/:taskName
 * Chức năng: Lấy vật tư gợi ý cho công việc cụ thể từ kế hoạch mẫu
 */
router.get('/suggested/:seasonId/:taskName', asyncHandler(async (req, res) => {
    const { seasonId, taskName } = req.params;
    
    const FarmSeason = require('../models/FarmSeason');
    const season = await FarmSeason.findById(seasonId).populate('planTemplate');
    
    if (!season || !season.planTemplate) {
        return errorResponse(res, 'Không tìm thấy kế hoạch mẫu cho mùa vụ này', 404);
    }
    
    let suggestedMaterials = [];
    season.planTemplate.stages.forEach(stage => {
        stage.tasks.forEach(task => {
            if (task.taskName === taskName) {
                suggestedMaterials = task.suggestedMaterials;
            }
        });
    });
    
    return successResponse(res, { suggestedMaterials }, 'Lấy vật tư gợi ý thành công');
}));

/**
 * GET /api/materials/barcode/:barcode
 * Chức năng: Tra cứu vật tư bằng mã vạch
 */
router.get('/barcode/:barcode', asyncHandler(async (req, res) => {
    const { barcode } = req.params;
    const material = await Material.findOne({ barcodeNumber: barcode });
    
    if (!material) {
        return errorResponse(res, 'Không tìm thấy vật tư với mã vạch này', 404);
    }
    
    return successResponse(res, {
        material: {
            name: material.materialName,
            supplier: material.supplier,
            barcode: material.barcodeNumber,
            unit: material.unit
        }
    }, 'Tra cứu vật tư thành công');
}));

module.exports = router;
