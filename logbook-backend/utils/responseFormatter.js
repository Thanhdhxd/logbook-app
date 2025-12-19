// utils/responseFormatter.js

/**
 * Success Response Formatter
 */
const successResponse = (res, data, message = 'Thành công', statusCode = 200) => {
    return res.status(statusCode).json({
        success: true,
        message: message,
        data: data
    });
};

/**
 * Error Response Formatter
 */
const errorResponse = (res, message = 'Lỗi', statusCode = 400, errors = null) => {
    return res.status(statusCode).json({
        success: false,
        message: message,
        errors: errors
    });
};

/**
 * Pagination Response Formatter
 */
const paginatedResponse = (res, data, page, limit, total, message = 'Thành công') => {
    return res.status(200).json({
        success: true,
        message: message,
        data: data,
        pagination: {
            page: page,
            limit: limit,
            total: total,
            totalPages: Math.ceil(total / limit)
        }
    });
};

module.exports = {
    successResponse,
    errorResponse,
    paginatedResponse
};
