// models/PlanTemplate.js
const mongoose = require('mongoose');

// --- 1. Schema cho Vật tư gợi ý (Vật tư gợi ý - Quan trọng [cite: 11]) ---
const MaterialSchema = new mongoose.Schema({
    materialName: { type: String, required: true }, // Phân NPK 16-16-8, Phân Urê [cite: 11]
    suggestedQuantityUnit: { type: String } // Ví dụ: kg/sào, lít/ha
}, { _id: false }); // Không cần ID riêng cho sub-document này

// --- 2. Schema cho Công việc gợi ý (Công việc gợi ý [cite: 8]) ---
const TaskSchema = new mongoose.Schema({
    taskName: { type: String, required: true }, // Bón thúc đợt 1, Phun thuốc trừ sâu [cite: 9]
    frequency: { type: String }, // Tần suất: Hàng ngày, 1 lần, 2 lần/tuần [cite: 10]
    scheduledDate: { type: String }, // Ngày dự kiến (format: DD/MM/YYYY)
    suggestedMaterials: [MaterialSchema] // Danh sách vật tư [cite: 11]
}, { _id: false });

// --- 3. Schema cho Giai đoạn (Chi tiết theo giai đoạn [cite: 7]) ---
const StageSchema = new mongoose.Schema({
    stageName: { type: String, required: true }, // Giai đoạn 1: Làm đất, Giai đoạn 3: Đẻ nhánh [cite: 7]
    startDay: { type: Number, required: true }, // Ngày bắt đầu (Ví dụ: Ngày 1)
    endDay: { type: Number, required: true }, // Ngày kết thúc (Ví dụ: Ngày 10)
    tasks: [TaskSchema] // Danh sách các công việc trong giai đoạn này
}, { _id: false });

// --- 4. Schema chính cho Kế hoạch chăm sóc mẫu (Template) [cite: 6] ---
const PlanTemplateSchema = new mongoose.Schema({
    templateName: { type: String, required: true, unique: true }, // Quy trình chăm sóc lúa 5451 vụ Đông Xuân [cite: 6]
    cropType: { type: String, required: true }, // Ví dụ: Lúa, Cà phê
    durationDays: { type: Number }, // Tổng thời gian của kế hoạch (Ví dụ: 90 ngày)
    stages: [StageSchema], // Chia nhỏ theo các giai đoạn sinh trưởng [cite: 7]
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('PlanTemplate', PlanTemplateSchema);