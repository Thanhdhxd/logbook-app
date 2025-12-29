const mongoose = require('mongoose');

// Schema để lưu các task đã bị ẩn (bỏ qua hoặc hoàn thành)
const HiddenTaskSchema = new mongoose.Schema({
    season: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'FarmSeason', 
        required: true 
    },
    taskName: { type: String, required: true },
    user: { 
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User', 
        required: false  // ✅ Không bắt buộc để tránh lỗi khi không có user
    },
    hiddenDate: { type: Date, default: Date.now },
    reason: { 
        type: String, 
        enum: ['DONE', 'SKIPPED'],
        required: true 
    }
});

// ✅ UNIQUE index để tránh duplicate (1 task chỉ ẩn 1 lần)
HiddenTaskSchema.index({ season: 1, taskName: 1 }, { unique: true });

module.exports = mongoose.model('HiddenTask', HiddenTaskSchema);
