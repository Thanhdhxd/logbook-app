const express = require('express');
const router = express.Router();
const PlanTemplate = require('../models/PlanTemplate'); // Import Model vừa tạo

// Middleware - Chức năng kiểm tra xem người dùng có phải Admin không (cần triển khai sau)
const isAdmin = (req, res, next) => {
    // Tạm thời cho phép tất cả các request đi qua
    // Trong thực tế, bạn sẽ kiểm tra token/session của người dùng
    next();
};

/**
 * 1. POST /api/templates
 * Chức năng: Tạo một Kế hoạch chăm sóc mẫu mới (Dành cho Admin/Chuyên gia) [cite: 6]
 */
router.post('/', isAdmin, async (req, res) => {
    try {
        // Dữ liệu template được gửi trong req.body từ client (Admin App)
        const newTemplate = new PlanTemplate(req.body);
        
        // Lưu template vào database
        const savedTemplate = await newTemplate.save();
        
        res.status(201).json({ 
            message: 'Tạo kế hoạch mẫu thành công!', 
            template: savedTemplate 
        });

    } catch (err) {
        console.error(err);
        // Xử lý lỗi trùng lặp (nếu templateName là unique) hoặc lỗi schema
        res.status(400).json({ message: 'Lỗi khi tạo kế hoạch mẫu', error: err.message });
    }
});

/**
 * 2. GET /api/templates
 * Chức năng: Lấy danh sách tất cả các Kế hoạch mẫu [cite: 6]
 */
router.get('/', async (req, res) => {
    try {
        // Tìm và trả về tất cả các templates
        const templates = await PlanTemplate.find({}); 
        
        res.status(200).json({
            message: 'Truy vấn kế hoạch mẫu thành công',
            count: templates.length,
            templates: templates
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Lỗi server khi truy vấn kế hoạch mẫu' });
    }
});

/**
 * 3. PUT /api/templates/:id
 * Chức năng: Cập nhật một kế hoạch mẫu
 */
router.put('/:id', isAdmin, async (req, res) => {
    try {
        const { id } = req.params;
        
        const updatedTemplate = await PlanTemplate.findByIdAndUpdate(
            id,
            req.body,
            { new: true, runValidators: true }
        );
        
        if (!updatedTemplate) {
            return res.status(404).json({ message: 'Không tìm thấy kế hoạch mẫu' });
        }
        
        res.status(200).json({
            message: 'Cập nhật kế hoạch mẫu thành công',
            template: updatedTemplate
        });
    } catch (err) {
        console.error(err);
        res.status(400).json({ message: 'Lỗi khi cập nhật kế hoạch mẫu', error: err.message });
    }
});

/**
 * 4. DELETE /api/templates/:id
 * Chức năng: Xóa một kế hoạch mẫu
 */
router.delete('/:id', isAdmin, async (req, res) => {
    try {
        const { id } = req.params;
        
        const deletedTemplate = await PlanTemplate.findByIdAndDelete(id);
        
        if (!deletedTemplate) {
            return res.status(404).json({ message: 'Không tìm thấy kế hoạch mẫu' });
        }
        
        res.status(200).json({
            message: 'Xóa kế hoạch mẫu thành công',
            template: deletedTemplate
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Lỗi server khi xóa kế hoạch mẫu' });
    }
});

module.exports = router;