// middleware/auth.js
const { DEFAULT_USER_ID } = require('../config/constants');

/**
 * Authentication Middleware
 * Hiện tại dùng user ID cố định, sau này sẽ thay bằng JWT
 */
const isAuth = (req, res, next) => {
    // TODO: Thay thế bằng JWT authentication
    // const token = req.headers.authorization?.split(' ')[1];
    // const decoded = jwt.verify(token, process.env.JWT_SECRET);
    // req.user = { id: decoded.userId };
    
    req.user = { id: DEFAULT_USER_ID };
    next();
};

module.exports = { isAuth };
