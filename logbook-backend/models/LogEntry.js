const mongoose = require('mongoose');

// Schema cho chi tiết Vật tư đã sử dụng (Dữ liệu thực tế khi ghi nhật ký)
const UsedMaterialSchema = new mongoose.Schema({
    materialName: { type: String, required: true }, // Tên vật tư đã dùng (Phân, thuốc,...)
    quantity: { type: Number, required: true, min: 0 }, // Số lượng thực tế đã dùng
    unit: { type: String, default: 'kg' }, // Đơn vị (kg, lít,...)
    barcode: { type: String, trim: true }, // Mã vạch/QR code (nếu quét)
}, { _id: false });

// Schema chính cho Nhật ký Công việc
const LogEntrySchema = new mongoose.Schema({
    // Thông tin Công việc
    taskName: { type: String, required: true }, // Tên công việc (ví dụ: Bón thúc đợt 1)
    
    // Liên kết với Mùa vụ
    season: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'FarmSeason', 
        required: true 
    },
    
    // Ngày thực hiện/Ghi log
    logDate: { type: Date, default: Date.now }, 
    
    // Trạng thái (Quan trọng cho logic To-do List)
    status: {
        type: String,
        enum: ['DONE', 'SKIPPED', 'MANUAL', 'PENDING', 'IN_PROGRESS'], // Hoàn thành, Bỏ qua, Thủ công, Chưa làm, Đang làm
        required: true
    },
    
    // Loại log: scheduled (từ kế hoạch) hoặc manual (thủ công)
    logType: {
        type: String,
        enum: ['scheduled', 'manual'],
        default: 'scheduled'
    },
    
    // Chi tiết khi hoàn thành
    usedMaterials: [UsedMaterialSchema], // Danh sách vật tư đã dùng thực tế
    notes: { type: String }, // Ghi chú thêm
    location: { type: String }, // Khu vực thực hiện công việc
    completedAt: { type: Date }, // Thời gian hoàn thành (cho manual log)
    
    // Thông tin người dùng
    user: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    },
    
    // Blockchain fields
    blockchainHash: { type: String }, // Transaction hash
    blockchainBlock: { type: Number }, // Block number
    blockchainVerified: { type: Boolean, default: false },
    blockchainTimestamp: { type: Date },
    
    createdAt: { type: Date, default: Date.now }
});

// Thiết lập index để tìm kiếm nhanh theo Mùa vụ và Công việc
LogEntrySchema.index({ season: 1, taskName: 1, logDate: 1 });
LogEntrySchema.index({ season: 1, logType: 1, completedAt: -1 }); // Tối ưu cho manual logs query
LogEntrySchema.index({ season: 1, status: 1, completedAt: -1 }); // Tối ưu cho completed logs query

module.exports = mongoose.model('LogEntry', LogEntrySchema);