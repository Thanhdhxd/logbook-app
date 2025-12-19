const mongoose = require('mongoose');

const MaterialSchema = new mongoose.Schema({
    // Thông tin cơ bản
    materialName: { type: String, required: true, unique: true, trim: true }, // Phân NPK 16-16-8, Thuốc trừ sâu A
    type: { 
        type: String, 
        enum: ['FERTILIZER', 'PESTICIDE', 'OTHER'], // Loại vật tư
        required: true 
    },
    supplier: { type: String }, // Nhà cung cấp
    
    // Thông tin phục vụ tính năng quét
    barcodeNumber: { type: String, unique: true, sparse: true, trim: true }, // Mã vạch/QR code chính
    description: { type: String },
    
    // Thông tin hệ thống
    isActive: { type: Boolean, default: true },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Material', MaterialSchema);