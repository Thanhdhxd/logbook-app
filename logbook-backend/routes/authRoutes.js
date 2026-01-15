// routes/authRoutes.js
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { JWT_SECRET, JWT_EXPIRES_IN } = require('../config/constants');
const { successResponse, errorResponse } = require('../utils/responseFormatter');
const { asyncHandler } = require('../middleware/errorHandler');

/**
 * POST /api/auth/login
 * Đăng nhập và nhận JWT token
 */
router.post('/login', asyncHandler(async (req, res) => {
    const { username, password } = req.body;
    
    // Validate input
    if (!username || !password) {
        return errorResponse(res, 'Tên tài khoản và mật khẩu là bắt buộc', 400);
    }
    
    // Tìm user theo username
    const user = await User.findOne({ username: username.toLowerCase() });
    
    if (!user) {
        return errorResponse(res, 'Tên tài khoản hoặc mật khẩu không chính xác', 401);
    }
    
    // Kiểm tra password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    
    if (!isPasswordValid) {
        return errorResponse(res, 'Tên tài khoản hoặc mật khẩu không chính xác', 401);
    }
    
    // Tạo JWT token
    const token = jwt.sign(
        { 
            userId: user._id.toString(),
            username: user.username,
            name: user.name
        },
        JWT_SECRET,
        { expiresIn: JWT_EXPIRES_IN }
    );
    
    // Trả về thông tin user và token
    return successResponse(res, {
        token,
        user: {
            id: user._id.toString(),
            name: user.name,
            username: user.username
        }
    }, 'Đăng nhập thành công');
}));

/**
 * POST /api/auth/verify
 * Xác thực token (optional - để check token còn hợp lệ không)
 */
router.post('/verify', asyncHandler(async (req, res) => {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return errorResponse(res, 'Token không hợp lệ', 401);
    }
    
    const token = authHeader.split(' ')[1];
    
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const user = await User.findById(decoded.userId).select('-password');
        
        if (!user) {
            return errorResponse(res, 'Token không hợp lệ', 401);
        }
        
        return successResponse(res, {
            user: {
                id: user._id.toString(),
                name: user.name,
                username: user.username
            }
        }, 'Token hợp lệ');
    } catch (error) {
        return errorResponse(res, 'Token đã hết hạn hoặc không hợp lệ', 401);
    }
}));

module.exports = router;
