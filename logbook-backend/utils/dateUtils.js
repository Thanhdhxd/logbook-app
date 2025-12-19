// Có thể đặt trong một file utils/dateUtils.js
const getDaysSinceStart = (startDate) => {
    const today = new Date();
    const start = new Date(startDate);
    
    // Đặt giờ về 0:0:0 để chỉ tính ngày (tránh lỗi múi giờ)
    today.setHours(0, 0, 0, 0);
    start.setHours(0, 0, 0, 0);

    // Tính toán sự khác biệt bằng mili giây
    const diffTime = Math.abs(today.getTime() - start.getTime());
    // Chuyển đổi sang ngày (1 ngày = 1000 * 60 * 60 * 24 mili giây)
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24)); 
    
    // Nếu ngày xuống giống là Ngày 1, thì diffDays = 0 khi chạy vào ngày xuống giống, 
    // nên ta thường trả về diffDays + 1 (hoặc tùy quy ước của bạn)
    return diffDays + 1; // Ví dụ: Ngày xuống giống (startDay) là Ngày 1
};

// ... sử dụng hàm này trong Route dưới đây ...
module.exports = { getDaysSinceStart };