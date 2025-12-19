// scripts/resetAndSeedData.js
// Script để xóa toàn bộ dữ liệu cũ và seed dữ liệu mới

require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');
const FarmSeason = require('../models/FarmSeason');
const PlanTemplate = require('../models/PlanTemplate');
const LogEntry = require('../models/LogEntry');
const Material = require('../models/Material');
const HiddenTask = require('../models/HiddenTask');
const { DEFAULT_USER_ID, DB_NAME } = require('../config/constants');

const DB_URI = process.env.MONGO_URI;

async function resetAndSeedData() {
    try {
        await mongoose.connect(DB_URI, { dbName: DB_NAME });
        console.log('✅ Đã kết nối MongoDB');

        // 1. XÓA TOÀN BỘ DỮ LIỆU CŨ
        console.log('\n🗑️  Đang xóa dữ liệu cũ...');
        await User.deleteMany({});
        await FarmSeason.deleteMany({});
        await PlanTemplate.deleteMany({});
        await LogEntry.deleteMany({});
        await Material.deleteMany({});
        await HiddenTask.deleteMany({});
        console.log('✅ Đã xóa toàn bộ dữ liệu cũ');

        // 2. TẠO USER MẶC ĐỊNH
        console.log('\n👤 Đang tạo user mặc định...');
        const user = new User({
            _id: DEFAULT_USER_ID,
            name: 'Admin User',
            email: 'admin@logbook.com',
            password: 'default123'
        });
        await user.save();
        console.log('✅ Đã tạo user:', user.email);

        // 3. TẠO PLAN TEMPLATE (Kế hoạch chăm sóc lúa 5451)
        console.log('\n📋 Đang tạo kế hoạch mẫu...');
        const template = new PlanTemplate({
            templateName: 'Quy trình chăm sóc lúa 5451 vụ Đông Xuân',
            cropType: 'San Pham Lua Gao',
            durationDays: 90,
            stages: [
                {
                    stageName: 'Làm đất',
                    startDay: 1,
                    endDay: 10,
                    tasks: [
                        {
                            taskName: 'Cày, bừa, phơi đất',
                            frequency: '1 lần',
                            suggestedMaterials: [
                                { materialName: 'Vôi bột', suggestedQuantityUnit: '100kg/sào' }
                            ]
                        },
                        {
                            taskName: 'Bón lót',
                            frequency: '1 lần',
                            suggestedMaterials: [
                                { materialName: 'Phân chuồng', suggestedQuantityUnit: '50kg/sào' }
                            ]
                        }
                    ]
                },
                {
                    stageName: 'Gieo sạ',
                    startDay: 11,
                    endDay: 20,
                    tasks: [
                        {
                            taskName: 'Bón phân đạm',
                            frequency: '1 lần',
                            suggestedMaterials: [
                                { materialName: 'Phân NPK 16-16-8', suggestedQuantityUnit: '50kg' }
                            ]
                        },
                        {
                            taskName: 'Gieo sạ',
                            frequency: '1 lần',
                            suggestedMaterials: [
                                { materialName: 'Giống Lúa 5451', suggestedQuantityUnit: '20kg' }
                            ]
                        }
                    ]
                },
                {
                    stageName: 'Chăm sóc (DEMO)',
                    startDay: 21,
                    endDay: 50,
                    tasks: [
                        {
                            taskName: 'Bón thúc đợt 1',
                            frequency: '1 lần',
                            suggestedMaterials: [
                                { materialName: 'Phân Urê', suggestedQuantityUnit: '30kg' }
                            ]
                        },
                        {
                            taskName: 'Phun thuốc trừ sâu',
                            frequency: '2 lần',
                            suggestedMaterials: [
                                { materialName: 'Thuốc trừ sâu', suggestedQuantityUnit: '1 lít' }
                            ]
                        }
                    ]
                }
            ],
            createdBy: DEFAULT_USER_ID
        });
        await template.save();
        console.log('✅ Đã tạo kế hoạch:', template.templateName);

        // 4. TẠO MÙA VỤ
        console.log('\n🌾 Đang tạo mùa vụ...');
        const season = new FarmSeason({
            seasonName: 'Lúa thơm 5451 (Hợp tác xã Xanh)',
            farmArea: 'Thửa ruộng A, Huyết B, Tỉnh C',
            planTemplate: template._id,
            startDate: new Date('2025-11-01'),
            user: DEFAULT_USER_ID,
            isActive: true
        });
        await season.save();
        console.log('✅ Đã tạo mùa vụ:', season.seasonName);
        console.log('   Mã lô:', season._id);

        // 5. TẠO LOG ENTRIES (Nhật ký đã thực hiện)
        console.log('\n📝 Đang tạo nhật ký canh tác...');
        
        const logEntries = [
            // Giai đoạn 1: Làm đất
            {
                taskName: 'Cày, bừa, phơi đất',
                season: season._id,
                logDate: new Date('2025-11-01'),
                status: 'DONE',
                logType: 'scheduled',
                usedMaterials: [
                    { materialName: 'Vôi bột', quantity: 100, unit: 'kg' }
                ],
                notes: 'Đã hoàn thành làm đất',
                user: DEFAULT_USER_ID
            },
            {
                taskName: 'Bón lót',
                season: season._id,
                logDate: new Date('2025-11-05'),
                status: 'DONE',
                logType: 'scheduled',
                usedMaterials: [
                    { materialName: 'Phân chuồng', quantity: 50, unit: 'kg' }
                ],
                notes: 'Bón đều',
                user: DEFAULT_USER_ID
            },
            // Giai đoạn 2: Gieo sạ
            {
                taskName: 'Bón phân đạm',
                season: season._id,
                logDate: new Date('2025-11-11'),
                status: 'DONE',
                logType: 'scheduled',
                usedMaterials: [
                    { materialName: 'Phân NPK 16-16-8', quantity: 50, unit: 'kg' }
                ],
                notes: '',
                user: DEFAULT_USER_ID
            },
            {
                taskName: 'Gieo sạ',
                season: season._id,
                logDate: new Date('2025-11-12'),
                status: 'DONE',
                logType: 'scheduled',
                usedMaterials: [
                    { materialName: 'Giống Lúa 5451', quantity: 20, unit: 'kg' }
                ],
                notes: 'Gieo đều, mật độ phù hợp',
                user: DEFAULT_USER_ID
            },
            // Giai đoạn 3: Chăm sóc
            {
                taskName: 'Bón thúc đợt 1',
                season: season._id,
                logDate: new Date('2025-11-25'),
                status: 'DONE',
                logType: 'scheduled',
                usedMaterials: [
                    { materialName: 'Phân Urê', quantity: 30, unit: 'kg' }
                ],
                notes: 'Bón sau khi cây đẻ nhánh',
                user: DEFAULT_USER_ID
            },
            {
                taskName: 'Phun thuốc trừ sâu',
                season: season._id,
                logDate: new Date('2025-11-28'),
                status: 'DONE',
                logType: 'scheduled',
                usedMaterials: [
                    { materialName: 'Thuốc trừ sâu Bio', quantity: 1, unit: 'lít' }
                ],
                notes: 'Phun vào chiều mát',
                user: DEFAULT_USER_ID
            },
            {
                taskName: 'Phun thuốc trừ sâu',
                season: season._id,
                logDate: new Date('2025-12-05'),
                status: 'DONE',
                logType: 'scheduled',
                usedMaterials: [
                    { materialName: 'Thuốc trừ sâu Bio', quantity: 1, unit: 'lít' }
                ],
                notes: 'Phun lần 2',
                user: DEFAULT_USER_ID
            }
        ];

        await LogEntry.insertMany(logEntries);
        console.log(`✅ Đã tạo ${logEntries.length} nhật ký canh tác`);

        // 6. TẠO MATERIALS (Vật tư)
        console.log('\n🧪 Đang tạo danh mục vật tư...');
        const materials = [
            {
                materialName: 'Vôi bột',
                type: 'FERTILIZER',
                supplier: 'Công ty phân bón A',
                barcodeNumber: 'VB001',
                description: 'Vôi bột cải tạo đất',
                isActive: true
            },
            {
                materialName: 'Phân chuồng',
                type: 'FERTILIZER',
                supplier: 'Hợp tác xã B',
                barcodeNumber: 'PC001',
                description: 'Phân hữu cơ chuồng bò',
                isActive: true
            },
            {
                materialName: 'Phân NPK 16-16-8',
                type: 'FERTILIZER',
                supplier: 'Công ty phân bón Việt Nam',
                barcodeNumber: 'NPK001',
                description: 'Phân NPK tổng hợp',
                isActive: true
            },
            {
                materialName: 'Phân Urê',
                type: 'FERTILIZER',
                supplier: 'Công ty phân bón C',
                barcodeNumber: 'URE001',
                description: 'Phân đạm Urê',
                isActive: true
            },
            {
                materialName: 'Giống Lúa 5451',
                type: 'OTHER',
                supplier: 'Trung tâm giống D',
                barcodeNumber: 'L5451',
                description: 'Giống lúa thuần 5451',
                isActive: true
            },
            {
                materialName: 'Thuốc trừ sâu Bio',
                type: 'PESTICIDE',
                supplier: 'Công ty thuốc BVTV E',
                barcodeNumber: 'TS001',
                description: 'Thuốc trừ sâu sinh học',
                isActive: true
            }
        ];

        await Material.insertMany(materials);
        console.log(`✅ Đã tạo ${materials.length} vật tư`);

        // 7. TỔNG KẾT
        console.log('\n' + '='.repeat(60));
        console.log('✅ SEED DỮ LIỆU THÀNH CÔNG!');
        console.log('='.repeat(60));
        console.log('\n📊 Thống kê:');
        console.log(`   - User: 1`);
        console.log(`   - Plan Template: 1`);
        console.log(`   - Mùa vụ: 1`);
        console.log(`   - Nhật ký: ${logEntries.length}`);
        console.log(`   - Vật tư: ${materials.length}`);
        console.log('\n🔑 Thông tin quan trọng:');
        console.log(`   - User ID: ${user._id}`);
        console.log(`   - Season ID (Mã lô): ${season._id}`);
        console.log(`   - Tên mùa vụ: ${season.seasonName}`);
        console.log('\n🚀 Bạn có thể test API tại:');
        console.log(`   GET http://localhost:3000/api/traceability/${season._id}`);
        console.log(`   GET http://localhost:3000/api/seasons/user`);
        console.log('\n');

        process.exit(0);
    } catch (error) {
        console.error('❌ Lỗi khi seed dữ liệu:', error);
        process.exit(1);
    }
}

resetAndSeedData();
