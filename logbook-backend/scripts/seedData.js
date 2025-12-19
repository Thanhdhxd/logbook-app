// scripts/seedData.js
require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const FarmSeason = require('../models/FarmSeason');
const PlanTemplate = require('../models/PlanTemplate');
const Material = require('../models/Material');
const LogEntry = require('../models/LogEntry');
const HiddenTask = require('../models/HiddenTask');

const MONGODB_URI = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/LogbookDB';

async function clearDatabase() {
    console.log('🗑️  Đang xóa dữ liệu cũ...');
    await User.deleteMany({});
    await FarmSeason.deleteMany({});
    await PlanTemplate.deleteMany({});
    await Material.deleteMany({});
    await LogEntry.deleteMany({});
    await HiddenTask.deleteMany({});
    console.log('✅ Đã xóa hết dữ liệu cũ');
}

async function seedData() {
    try {
        await mongoose.connect(MONGODB_URI);
        console.log('✅ Đã kết nối MongoDB');

        await clearDatabase();

        // 1. Tạo User mẫu
        console.log('👤 Tạo user mẫu...');
        const user = await User.create({
            name: 'Nông dân Demo',
            email: 'demo@example.com',
            password: '$2a$10$rQqX7KZ4N0yH3FJhQz4kI.xYZ123ABC'  // Demo password hash
        });
        console.log('✅ Đã tạo user:', user.name);

        // 2. Tạo Materials
        console.log('📦 Tạo vật tư mẫu...');
        const materials = await Material.insertMany([
            { materialName: 'Phân đạm', type: 'FERTILIZER', barcodeNumber: '0001' },
            { materialName: 'Phân lân', type: 'FERTILIZER', barcodeNumber: '0002' },
            { materialName: 'Kali', type: 'FERTILIZER', barcodeNumber: '0003' },
            { materialName: 'Thuốc trừ sâu A', type: 'PESTICIDE', barcodeNumber: '0004' },
            { materialName: 'Thuốc diệt cỏ B', type: 'PESTICIDE', barcodeNumber: '0005' },
            { materialName: 'Phân hữu cơ', type: 'FERTILIZER', barcodeNumber: '0006' }
        ]);
        console.log(`✅ Đã tạo ${materials.length} vật tư`);

        // 3. Tạo Template mẫu
        console.log('📋 Tạo kế hoạch mẫu...');
        const template = await PlanTemplate.create({
            templateName: 'Lúa Đông Xuân',
            cropType: 'Lúa',
            user: user._id,
            stages: [
                {
                    stageName: 'Chuẩn bị đất',
                    startDay: 1,
                    endDay: 7,
                    tasks: [
                        {
                            taskName: 'Bón phân lót',
                            frequency: 'Một lần',
                            suggestedMaterials: [
                                { materialName: 'Phân đạm', quantityPerUnit: 50, unit: 'kg' },
                                { materialName: 'Phân lân', quantityPerUnit: 30, unit: 'kg' }
                            ]
                        },
                        {
                            taskName: 'Cày bừa',
                            frequency: 'Một lần',
                            suggestedMaterials: []
                        }
                    ]
                },
                {
                    stageName: 'Gieo mạ',
                    startDay: 8,
                    endDay: 35,
                    tasks: [
                        {
                            taskName: 'Tưới nước',
                            frequency: 'Hàng ngày',
                            suggestedMaterials: []
                        },
                        {
                            taskName: 'Phun thuốc trừ sâu',
                            frequency: '3 ngày/lần',
                            suggestedMaterials: [
                                { materialName: 'Thuốc trừ sâu A', quantityPerUnit: 2, unit: 'lít' }
                            ]
                        }
                    ]
                },
                {
                    stageName: 'Chăm sóc',
                    startDay: 36,
                    endDay: 80,
                    tasks: [
                        {
                            taskName: 'Bón thúc đợt 1',
                            frequency: 'Một lần',
                            suggestedMaterials: [
                                { materialName: 'Phân đạm', quantityPerUnit: 40, unit: 'kg' },
                                { materialName: 'Kali', quantityPerUnit: 20, unit: 'kg' }
                            ]
                        },
                        {
                            taskName: 'Tưới nước',
                            frequency: 'Hàng ngày',
                            suggestedMaterials: []
                        }
                    ]
                },
                {
                    stageName: 'Thu hoạch',
                    startDay: 81,
                    endDay: 100,
                    tasks: [
                        {
                            taskName: 'Gặt lúa',
                            frequency: 'Một lần',
                            suggestedMaterials: []
                        },
                        {
                            taskName: 'Phơi khô',
                            frequency: 'Một lần',
                            suggestedMaterials: []
                        }
                    ]
                }
            ]
        });
        console.log('✅ Đã tạo kế hoạch:', template.templateName);

        // 4. Tạo Mùa vụ mẫu
        console.log('🌾 Tạo mùa vụ mẫu...');
        const startDate = new Date('2025-01-01');
        const season = await FarmSeason.create({
            seasonName: 'Lúa Đông Xuân 2025',
            farmArea: 'Thửa ruộng A, Huyết B, Tỉnh C',
            planTemplate: template._id,
            startDate: startDate,
            user: user._id
        });
        console.log('✅ Đã tạo mùa vụ:', season.seasonName);

        // 5. Tạo một số Log Entry mẫu
        console.log('📝 Tạo nhật ký mẫu...');
        const completedDate = new Date('2025-01-05T08:30:00');
        await LogEntry.create({
            season: season._id,
            taskName: 'Bón phân lót',
            status: 'DONE',
            logType: 'manual',
            usedMaterials: [
                { materialName: 'Phân đạm', quantity: 55, unit: 'kg' },
                { materialName: 'Phân lân', quantity: 32, unit: 'kg' }
            ],
            notes: 'Đã hoàn thành bón phân. Thời tiết tốt.',
            location: 'Thửa ruộng A',
            completedAt: completedDate,
            user: user._id
        });
        console.log('✅ Đã tạo nhật ký mẫu');

        console.log('\n✨ Hoàn tất seed dữ liệu!');
        console.log('📊 Tổng kết:');
        console.log(`   - Users: 1`);
        console.log(`   - Materials: ${materials.length}`);
        console.log(`   - Templates: 1`);
        console.log(`   - Seasons: 1`);
        console.log(`   - Log Entries: 1`);
        console.log('\n🔑 Thông tin đăng nhập:');
        console.log(`   Email: demo@example.com`);
        console.log(`   Password: demo123`);

    } catch (error) {
        console.error('❌ Lỗi:', error);
    } finally {
        await mongoose.connection.close();
        console.log('👋 Đã ngắt kết nối MongoDB');
        process.exit(0);
    }
}

seedData();
