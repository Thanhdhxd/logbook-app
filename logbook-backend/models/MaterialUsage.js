// models/MaterialUsage.js
const mongoose = require('mongoose');

// Schema để track việc sử dụng vật tư của người dùng (để tính favorites)
const MaterialUsageSchema = new mongoose.Schema({
    user: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: true 
    },
    materialName: { type: String, required: true },
    usageCount: { type: Number, default: 1 }, // Số lần sử dụng
    lastUsedAt: { type: Date, default: Date.now }
});

// Index để tìm kiếm nhanh
MaterialUsageSchema.index({ user: 1, materialName: 1 }, { unique: true });
MaterialUsageSchema.index({ user: 1, usageCount: -1 }); // Sort by usage count

module.exports = mongoose.model('MaterialUsage', MaterialUsageSchema);
