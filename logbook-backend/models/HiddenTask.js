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
        required: true 
    },
    hiddenDate: { type: Date, default: Date.now },
    reason: { 
        type: String, 
        enum: ['DONE', 'SKIPPED'],
        required: true 
    }
});

// Index để tìm kiếm nhanh
HiddenTaskSchema.index({ season: 1, user: 1, taskName: 1 });

module.exports = mongoose.model('HiddenTask', HiddenTaskSchema);
