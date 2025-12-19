// middleware/errorHandler.js
const { MESSAGES } = require('../config/constants');

/**
 * Error Handler Middleware
 * Xử lý tất cả các lỗi trong ứng dụng
 */
const errorHandler = (err, req, res, next) => {
    console.error('Error:', err);
    
    const statusCode = err.statusCode || 500;
    const message = err.message || MESSAGES.ERROR.SERVER_ERROR;
    
    res.status(statusCode).json({
        success: false,
        message: message,
        error: process.env.NODE_ENV === 'development' ? err.stack : undefined
    });
};

/**
 * 404 Handler
 */
const notFoundHandler = (req, res) => {
    res.status(404).json({
        success: false,
        message: `Route ${req.originalUrl} không tồn tại`
    });
};

/**
 * Async Handler Wrapper
 * Bọc các async route handlers để catch errors
 */
const asyncHandler = (fn) => (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = {
    errorHandler,
    notFoundHandler,
    asyncHandler
};
