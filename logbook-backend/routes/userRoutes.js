// routes/userRoutes.js
const express = require('express');
const router = express.Router();
const MaterialUsage = require('../models/MaterialUsage');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { asyncHandler } = require('../middleware/errorHandler');

/**
 * POST /api/users/fcm-token
 * Lưu FCM token để gửi push notification
 */
router.post('/fcm-token', asyncHandler(async (req, res) => {
    const { fcmToken } = req.body;
    
    if (!fcmToken) {
        return errorResponse(res, 'FCM token là bắt buộc', 400);
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
    
    // Cập nhật FCM token
    user.fcmToken = fcmToken;
    await user.save();
    
    return successResponse(res, { fcmToken }, 'Đã lưu FCM token thành công');
}));

/**
 * GET /api/users/favorite-materials
 * Lấy danh sách vật tư hay dùng (top 10)
 */
router.get('/favorite-materials', asyncHandler(async (req, res) => {
    // Lấy user đầu tiên
    const User = require('../models/User');
    const user = await User.findOne();
    
    if (!user) {
        return successResponse(res, { materials: [] }, 'Chưa có dữ liệu favorites');
    }
    
    // Lấy top 10 vật tư được dùng nhiều nhất
    const topMaterials = await MaterialUsage.find({ user: user._id })
        .sort({ usageCount: -1 })
        .limit(10)
        .select('materialName usageCount lastUsedAt');
    
    return successResponse(res, { materials: topMaterials }, 'Lấy danh sách vật tư yêu thích thành công');
}));

/**
 * POST /api/users/track-material-usage
 * Track việc sử dụng vật tư (tự động gọi khi user chọn vật tư)
 */
router.post('/track-material-usage', asyncHandler(async (req, res) => {
    const { materialName } = req.body;
    
    if (!materialName) {
        return errorResponse(res, 'Material name là bắt buộc', 400);
    }
    
    // Lấy user đầu tiên
    const User = require('../models/User');
    const user = await User.findOne();
    
    if (!user) {
        return errorResponse(res, 'Không tìm thấy user', 404);
    }
    
    // Tìm hoặc tạo material usage record
    let materialUsage = await MaterialUsage.findOne({
        user: user._id,
        materialName: materialName
    });
    
    if (materialUsage) {
        // Tăng usage count
        materialUsage.usageCount += 1;
        materialUsage.lastUsedAt = new Date();
        await materialUsage.save();
    } else {
        // Tạo mới
        materialUsage = await MaterialUsage.create({
            user: user._id,
            materialName: materialName,
            usageCount: 1
        });
    }
    
    return successResponse(res, { materialUsage }, 'Đã track material usage');
}));

module.exports = router;
