// config/constants.js
module.exports = {
    // Database
    DB_NAME: 'LogbookDB',
    
    // Server
    PORT: process.env.PORT || 3000,
    
    // Authentication (tạm thời hardcoded, sau này sẽ thay bằng JWT)
    DEFAULT_USER_ID: '60c72b2f9f1b2c0015b8d4f4',
    
    // Task Status
    TASK_STATUS: {
        DONE: 'DONE',
        SKIPPED: 'SKIPPED',
        PENDING: 'PENDING',
        MANUAL: 'MANUAL'
    },
    
    // Response Messages
    MESSAGES: {
        SUCCESS: {
            SEASON_CREATED: 'Khởi tạo mùa vụ thành công',
            LOG_CREATED: 'Ghi nhật ký thành công',
            DATA_RETRIEVED: 'Lấy dữ liệu thành công'
        },
        ERROR: {
            MISSING_FIELDS: 'Thiếu thông tin bắt buộc',
            SEASON_NOT_FOUND: 'Không tìm thấy mùa vụ',
            TEMPLATE_NOT_FOUND: 'Không tìm thấy kế hoạch mẫu',
            SERVER_ERROR: 'Lỗi server',
            DATABASE_ERROR: 'Lỗi cơ sở dữ liệu'
        }
    }
};
