const mongoose = require('mongoose');

const FarmSeasonSchema = new mongoose.Schema({
    // Dữ liệu chính
    seasonName: { type: String, required: true }, // Ví dụ: Lúa vụ Đông Xuân
    farmArea: { type: String, required: true }, // Thửa ruộng A, Khu vực B
    
    // Liên kết với Kế hoạch mẫu (Template)
    planTemplate: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'PlanTemplate', 
        required: false
    },
    
    // Ngày bắt đầu tính toán
    startDate: { type: Date, required: true }, // Ngày xuống giống (Ví dụ: 01/11/2025) 
    
    // Dữ liệu người dùng (User ID)
    user: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    },

    isActive: { type: Boolean, default: true }, // Mùa vụ còn hoạt động không
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('FarmSeason', FarmSeasonSchema);