// Keep backend alive - ping itself every 10 minutes to prevent Render cold start
const https = require('https');

const BACKEND_URL = process.env.BACKEND_URL || 'https://logbook-backend-pxuq.onrender.com';
const PING_INTERVAL = 10 * 60 * 1000; // 10 phút

function pingBackend() {
    const url = `${BACKEND_URL}/`;
    
    https.get(url, (res) => {
        if (res.statusCode === 200) {
            console.log('✅ Keep-alive ping successful');
        }
    }).on('error', (err) => {
        console.error('⚠️ Keep-alive ping failed:', err.message);
    });
}

function startKeepAlive() {
    // Chỉ bật keep-alive trong production (không cần trong development)
    if (process.env.NODE_ENV === 'production' || BACKEND_URL.includes('render.com')) {
        console.log('🔄 Keep-alive enabled - pinging every 10 minutes');
        setInterval(pingBackend, PING_INTERVAL);
        // Ping ngay lập tức khi khởi động
        setTimeout(pingBackend, 60000); // 1 phút sau khi start
    } else {
        console.log('⏸️ Keep-alive disabled (development mode)');
    }
}

module.exports = { startKeepAlive };
