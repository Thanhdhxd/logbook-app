require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

// Import models (đảm bảo models được register)
require('./models/User');
require('./models/FarmSeason');
require('./models/LogEntry');
require('./models/Material');
require('./models/PlanTemplate');
require('./models/HiddenTask');
require('./models/MaterialUsage');

// Import middleware
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

// Import routes
const templateRoutes = require('./routes/templateRoutes');
const seasonRoutes = require('./routes/seasonRoutes');
const logbookRoutes = require('./routes/logbookRoutes');
const materialRoutes = require('./routes/materialRoutes');
const dataRoutes = require('./routes/dataRoutes');
const traceabilityRoutes = require('./routes/traceabilityRoutes');
const userRoutes = require('./routes/userRoutes');
const blockchainRoutes = require('./routes/blockchainRoutes');

// Import scheduler
const { startScheduler } = require('./scheduler/taskScheduler');

// Import constants
const { PORT, DB_NAME } = require('./config/constants');

const app = express();

// *** Thiết lập kết nối MongoDB ***
const DB_URI = process.env.MONGO_URI; 

mongoose.connect(DB_URI, { dbName: DB_NAME })
    .then(() => console.log('✅ Đã kết nối thành công tới MongoDB.'))
    .catch(err => console.error('❌ Lỗi kết nối MongoDB:', err));

// *** Middleware ***
app.use(cors()); // Kích hoạt CORS cho tất cả các route
app.use(express.json()); // Cho phép server đọc JSON từ request body

// *** Health check route ***
app.get('/', (req, res) => {
    res.json({ 
        success: true,
        message: 'Back-end đang chạy và đã kết nối DB',
        timestamp: new Date().toISOString()
    });
});

// *** API Routes ***
app.use('/api/templates', templateRoutes);
app.use('/api/seasons', seasonRoutes);
app.use('/api/logbook', logbookRoutes);
app.use('/api/materials', materialRoutes);
app.use('/api/data', dataRoutes);
app.use('/api/traceability', traceabilityRoutes);
app.use('/api/users', userRoutes);
app.use('/api/blockchain', blockchainRoutes);

// *** Error Handling Middleware ***
app.use(notFoundHandler);
app.use(errorHandler);

// *** Khởi động Scheduler ***
startScheduler();

// *** Khởi động Server ***
app.listen(PORT, () => {
    console.log(`🚀 Server đang lắng nghe tại cổng: ${PORT}`);
    console.log(`📡 API endpoint: http://localhost:${PORT}/api`);
});