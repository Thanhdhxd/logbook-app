// scripts/createUser.js
// Script để tạo user mẫu với password đã mã hóa
require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const { DB_NAME } = require('../config/constants');

const createSampleUsers = async () => {
    try {
        // Kết nối MongoDB
        const DB_URI = process.env.MONGO_URI;
        await mongoose.connect(DB_URI, { dbName: DB_NAME });
        console.log('✅ Đã kết nối MongoDB');
        
        // Xóa tất cả users cũ (optional - comment dòng này nếu không muốn xóa)
        // await User.deleteMany({});
        // console.log('🗑️  Đã xóa tất cả users cũ');
        
        // Tạo các user mẫu
        const sampleUsers = [
            {
                name: 'Nguyễn Văn A',
                username: 'admin',
                password: 'admin123'
            },
            {
                name: 'Trần Thị B',
                username: 'user',
                password: 'user123'
            },
            {
                name: 'Demo User',
                username: 'demo',
                password: 'demo123'
            }
        ];
        
        for (const userData of sampleUsers) {
            // Kiểm tra xem user đã tồn tại chưa
            const existingUser = await User.findOne({ username: userData.username });
            
            if (existingUser) {
                console.log(`⚠️  User ${userData.username} đã tồn tại, bỏ qua...`);
                continue;
            }
            
            // Mã hóa password
            const hashedPassword = await bcrypt.hash(userData.password, 10);
            
            // Tạo user mới
            const newUser = await User.create({
                name: userData.name,
                username: userData.username,
                password: hashedPassword
            });
            
            console.log(`✅ Đã tạo user: ${userData.name} (${userData.username})`);
            console.log(`   Password: ${userData.password}`);
        }
        
        console.log('\n🎉 Hoàn thành! Danh sách tài khoản:');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        sampleUsers.forEach(user => {
            console.log(`Tên tài khoản: ${user.username}`);
            console.log(`Password: ${user.password}`);
            console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        });
        
    } catch (error) {
        console.error('❌ Lỗi:', error);
    } finally {
        await mongoose.disconnect();
        console.log('👋 Đã ngắt kết nối MongoDB');
    }
};

// Chạy script
createSampleUsers();
