// scripts/seedVaiThieuTemplate.js
const mongoose = require('mongoose');
const PlanTemplate = require('../models/PlanTemplate');
require('dotenv').config();

const vaiThieuTemplate = {
    templateName: 'Quy trình kỹ thuật canh tác vải thiều xuất khẩu',
    cropType: 'Vải thiều',
    durationDays: 365, // 1 năm (chu kỳ khép kín)
    stages: [
        {
            stageName: 'Phục hồi sau thu hoạch và nuôi lộc',
            startDay: 1,    // Tháng 6
            endDay: 152,    // Tháng 10 (5 tháng)
            tasks: [
                {
                    taskName: 'Cắt tỉa và vệ sinh vườn',
                    frequency: '1 lần',
                    scheduledDate: '10/06/2025',
                    suggestedMaterials: []
                },
                {
                    taskName: 'Bón phân thúc lộc (Phân chuồng)',
                    frequency: '1 lần',
                    scheduledDate: '15/06/2025',
                    suggestedMaterials: [
                        {
                            materialName: 'Phân chuồng hoai mục',
                            suggestedQuantityUnit: '60-70 kg/cây (10-15 năm tuổi)'
                        }
                    ]
                },
                {
                    taskName: 'Bón phân thúc lộc (NPK)',
                    frequency: '1 lần',
                    scheduledDate: '15/06/2025',
                    suggestedMaterials: [
                        {
                            materialName: 'Đạm urê',
                            suggestedQuantityUnit: '0,75-0,9 kg/cây (50% lượng cả năm)'
                        },
                        {
                            materialName: 'Lân supe',
                            suggestedQuantityUnit: '0,8-1,0 kg/cây (40% lượng cả năm)'
                        },
                        {
                            materialName: 'Kali clorua',
                            suggestedQuantityUnit: '0,5-0,6 kg/cây (25% lượng cả năm)'
                        }
                    ]
                },
                {
                    taskName: 'Phun thuốc bảo vệ lộc non (đợt 1)',
                    frequency: '1 lần',
                    scheduledDate: '20/06/2025',
                    suggestedMaterials: [
                        {
                            materialName: 'Abamectin 1.8EC',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        },
                        {
                            materialName: 'Alpha Cypermetrin',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        }
                    ]
                },
                {
                    taskName: 'Tưới nước định kỳ',
                    frequency: 'Hàng tuần',
                    scheduledDate: '20/06/2025',
                    suggestedMaterials: []
                },
                {
                    taskName: 'Phun thuốc bảo vệ lộc non (đợt 2)',
                    frequency: '1 lần',
                    scheduledDate: '20/07/2025',
                    suggestedMaterials: [
                        {
                            materialName: 'Emamectin benzoate',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        }
                    ]
                },
                {
                    taskName: 'Phun thuốc bảo vệ lộc non (đợt 3)',
                    frequency: '1 lần',
                    scheduledDate: '20/08/2025',
                    suggestedMaterials: [
                        {
                            materialName: 'Abamectin 1.8EC',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        }
                    ]
                }
            ]
        },
        {
            stageName: 'Kiểm soát lộc đông và xử lý ra hoa',
            startDay: 153,  // Tháng 11
            endDay: 213,    // Tháng 12 (2 tháng)
            tasks: [
                {
                    taskName: 'Xiết nước (Ngừng tưới)',
                    frequency: 'Liên tục',
                    scheduledDate: '01/11/2025',
                    suggestedMaterials: []
                },
                {
                    taskName: 'Khoanh vỏ cành',
                    frequency: '1 lần',
                    scheduledDate: '25/11/2025',
                    suggestedMaterials: []
                },
                {
                    taskName: 'Xử lý lộc đông (nếu có)',
                    frequency: 'Khi cần thiết',
                    scheduledDate: '05/12/2025',
                    suggestedMaterials: [
                        {
                            materialName: 'Ethephon (Ethrel)',
                            suggestedQuantityUnit: '800-1000 ppm'
                        }
                    ]
                }
            ]
        },
        {
            stageName: 'Giai đoạn 3: Ra hoa và đậu quả',
            startDay: 214,  // Tháng 1
            endDay: 304,    // Tháng 3 (3 tháng)
            tasks: [
                {
                    taskName: 'Tưới đẫm khi nhú giò hoa',
                    frequency: '1 lần',
                    scheduledDate: '05/01/2026',
                    suggestedMaterials: []
                },
                {
                    taskName: 'Phun nước rửa sương muối (nếu có)',
                    frequency: 'Khi cần thiết',
                    scheduledDate: '10/01/2026',
                    suggestedMaterials: []
                },
                {
                    taskName: 'Bón phân thúc hoa',
                    frequency: '1 lần',
                    scheduledDate: '15/01/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Đạm urê',
                            suggestedQuantityUnit: '0,4-0,45 kg/cây (25% lượng cả năm)'
                        },
                        {
                            materialName: 'Lân supe',
                            suggestedQuantityUnit: '0,6-0,75 kg/cây (30% lượng cả năm)'
                        },
                        {
                            materialName: 'Kali clorua',
                            suggestedQuantityUnit: '0,5-0,6 kg/cây (25% lượng cả năm)'
                        }
                    ]
                },
                {
                    taskName: 'Phun phân bón lá chứa Bo',
                    frequency: '2 lần',
                    scheduledDate: '20/01/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Phân bón lá có Bo',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        }
                    ]
                },
                {
                    taskName: 'Phun thuốc trừ rệp sáp và bọ xít',
                    frequency: '2-3 lần',
                    scheduledDate: '25/01/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Ema 5EC',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        },
                        {
                            materialName: 'Movento 1500D',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        },
                        {
                            materialName: 'Trebon 10EC',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        }
                    ]
                },
                {
                    taskName: 'Phun thuốc trừ bệnh (sương mai, thán thư)',
                    frequency: '2-3 lần',
                    scheduledDate: '01/02/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Daconil 75WP',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        },
                        {
                            materialName: 'Ridomil Gold 68WG',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        },
                        {
                            materialName: 'Score 250EC',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        }
                    ]
                }
            ]
        },
        {
            stageName: 'Nuôi quả lớn',
            startDay: 305,  // Tháng 4
            endDay: 364,    // Tháng 5 (2 tháng)
            tasks: [
                {
                    taskName: 'Cắt tỉa định quả (Lần 3)',
                    frequency: '1 lần',
                    scheduledDate: '10/04/2026',
                    suggestedMaterials: []
                },
                {
                    taskName: 'Bón phân nuôi quả (Lần 1)',
                    frequency: '1 lần',
                    scheduledDate: '12/04/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Đạm urê',
                            suggestedQuantityUnit: '0,4-0,45 kg/cây (25% còn lại)'
                        },
                        {
                            materialName: 'Lân supe',
                            suggestedQuantityUnit: '0,6-0,75 kg/cây (30% còn lại)'
                        },
                        {
                            materialName: 'Kali clorua',
                            suggestedQuantityUnit: '0,6-0,75 kg/cây (30% lượng cả năm)'
                        }
                    ]
                },
                {
                    taskName: 'Phun thuốc phòng sâu đục cuống (đợt 1)',
                    frequency: '1 lần',
                    scheduledDate: '10/03/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Bacillus thuringiensis',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        },
                        {
                            materialName: 'Matrine',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        },
                        {
                            materialName: 'Catex 1.8EC (Abamectin)',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        }
                    ]
                },
                {
                    taskName: 'Phun thuốc phòng sâu đục cuống (đợt 2)',
                    frequency: '1 lần',
                    scheduledDate: '15/04/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Reasgant 3.6EC (Abamectin)',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        },
                        {
                            materialName: 'Tasieu 1.9EC (Emamectin)',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        }
                    ]
                },
                {
                    taskName: 'Bón phân nuôi quả (Lần 2 - Chỉ Kali)',
                    frequency: '1 lần',
                    scheduledDate: '05/05/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Kali clorua',
                            suggestedQuantityUnit: '0,4-0,5 kg/cây (20% còn lại)'
                        }
                    ]
                },
                {
                    taskName: 'Phun thuốc phòng sâu đục cuống (đợt 3)',
                    frequency: '1 lần',
                    scheduledDate: '20/05/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Tasieu 1.9EC (Emamectin)',
                            suggestedQuantityUnit: 'Theo hướng dẫn nhà sản xuất'
                        }
                    ]
                },
                {
                    taskName: 'Tưới phun mưa chống nứt quả',
                    frequency: 'Hàng tuần',
                    scheduledDate: '01/05/2026',
                    suggestedMaterials: []
                }
            ]
        },
        {
            stageName: 'Thu hoạch và bảo quản',
            startDay: 365,  // Tháng 6
            endDay: 365,    // Tháng 6
            tasks: [
                {
                    taskName: 'Thu hoạch vải',
                    frequency: '1 lần',
                    scheduledDate: '01/06/2026',
                    suggestedMaterials: []
                },
                {
                    taskName: 'Phân loại và đóng gói',
                    frequency: '1 lần',
                    scheduledDate: '01/06/2026',
                    suggestedMaterials: [
                        {
                            materialName: 'Thùng xốp',
                            suggestedQuantityUnit: 'Theo nhu cầu'
                        },
                        {
                            materialName: 'Đá lạnh',
                            suggestedQuantityUnit: 'Theo nhu cầu'
                        }
                    ]
                }
            ]
        }
    ]
};

async function seedVaiThieuTemplate() {
    try {
        // Kết nối MongoDB
        await mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/LogbookDB');
        console.log('✅ Đã kết nối MongoDB');

        // Kiểm tra xem template đã tồn tại chưa
        const existingTemplate = await PlanTemplate.findOne({ 
            templateName: vaiThieuTemplate.templateName 
        });

        if (existingTemplate) {
            console.log('⚠️  Template "Quy trình kỹ thuật canh tác vải thiều xuất khẩu" đã tồn tại!');
            console.log('Bạn có muốn cập nhật? Xóa template cũ và chạy lại script này.');
        } else {
            // Tạo template mới
            const newTemplate = await PlanTemplate.create(vaiThieuTemplate);
            console.log('✅ Đã tạo template vải thiều thành công!');
            console.log('Template ID:', newTemplate._id);
            console.log('Tên:', newTemplate.templateName);
            console.log('Số giai đoạn:', newTemplate.stages.length);
            
            let totalTasks = 0;
            newTemplate.stages.forEach(stage => {
                totalTasks += stage.tasks.length;
            });
            console.log('Tổng số công việc:', totalTasks);
        }

        await mongoose.disconnect();
        console.log('✅ Đã ngắt kết nối MongoDB');
        
    } catch (error) {
        console.error('❌ Lỗi:', error.message);
        process.exit(1);
    }
}

// Chạy script
seedVaiThieuTemplate();
