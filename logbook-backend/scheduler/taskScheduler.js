// scheduler/taskScheduler.js
const cron = require('node-cron');
const FarmSeason = require('../models/FarmSeason');
const HiddenTask = require('../models/HiddenTask');
const { getDaysSinceStart } = require('../utils/dateUtils');

// Khởi tạo Firebase Admin SDK
let admin = null;
try {
    admin = require('firebase-admin');
    const serviceAccount = require('../config/serviceAccountKey.json');
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
    console.log('✅ Firebase Admin SDK initialized');
} catch (error) {
    console.warn('⚠️ Firebase not initialized:', error.message);
    console.warn('⚠️ Push notifications disabled. Add serviceAccountKey.json to config/');
}

// Tính số tasks cần làm hôm nay
const getTasksCountForDay = async (season) => {
    try {
        if (!season.planTemplate) return 0;
        
        const PlanTemplate = require('../models/PlanTemplate');
        const template = await PlanTemplate.findById(season.planTemplate);
        if (!template) return 0;
        
        const currentDay = getDaysSinceStart(season.startDate);
        const hiddenTasks = await HiddenTask.find({ season: season._id });
        const hiddenTaskNames = new Set(hiddenTasks.map(t => t.taskName));
        
        let taskCount = 0;
        template.stages.forEach(stage => {
            if (currentDay >= stage.startDay && currentDay <= stage.endDay) {
                stage.tasks.forEach(task => {
                    if (!hiddenTaskNames.has(task.taskName)) {
                        taskCount++;
                    }
                });
            }
        });
        
        return taskCount;
    } catch (error) {
        console.error('Error counting tasks:', error);
        return 0;
    }
};

// Gửi thông báo hàng ngày
const sendDailyReminders = async () => {
    try {
        console.log('--- Daily reminder check started ---');
        
        const activeSeasons = await FarmSeason.find({ isActive: true }).populate('user');

        for (const season of activeSeasons) {
            const dailyTasksCount = await getTasksCountForDay(season);
            
            if (dailyTasksCount > 0 && season.user && season.user.fcmToken && admin) {
                const message = {
                    notification: {
                        title: '🔔 NHẮC VIỆC HÔM NAY!',
                        body: `${season.farmArea}: Bạn có ${dailyTasksCount} công việc cần thực hiện.`,
                    },
                    data: {
                        seasonId: season._id.toString(),
                        seasonName: season.seasonName,
                        taskCount: dailyTasksCount.toString()
                    },
                    token: season.user.fcmToken
                };

                try {
                    await admin.messaging().send(message);
                    console.log(`✅ Sent reminder to ${season.user.name} (${dailyTasksCount} tasks)`);
                } catch (fcmError) {
                    console.error(`❌ FCM error for user ${season.user._id}:`, fcmError.message);
                }
            } else if (dailyTasksCount > 0 && !admin) {
                console.log(`⚠️ Season ${season.seasonName} has ${dailyTasksCount} tasks but Firebase not configured`);
            }
        }
        console.log('--- Daily reminder check completed ---');
    } catch (error) {
        console.error('Cron job error:', error);
    }
};

// Thiết lập Cron Job
const startScheduler = () => {
    cron.schedule('0 7 * * *', sendDailyReminders, {
        scheduled: true,
        timezone: "Asia/Ho_Chi_Minh"
    });
    console.log('✅ Cron Job scheduled for 7:00 AM daily');
};

module.exports = { startScheduler, sendDailyReminders };