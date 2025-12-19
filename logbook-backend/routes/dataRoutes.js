// routes/dataRoutes.js
const express = require('express');
const router = express.Router();
const FarmSeason = require('../models/FarmSeason');
const LogEntry = require('../models/LogEntry');
const Material = require('../models/Material');
const PlanTemplate = require('../models/PlanTemplate');

// Middleware xác thực (giả định)
const isAuth = (req, res, next) => {
    req.user = { id: '60c72b2f9f1b2c0015b8d4f4' }; 
    next();
};

/**
 * GET /api/data/all
 * Chức năng: Lấy tất cả dữ liệu trong hệ thống
 */
router.get('/all', async (req, res) => {
    try {
        // Lấy tất cả dữ liệu song song (faster)
        const [seasons, logEntries, materials, templates] = await Promise.all([
            FarmSeason.find({}).populate('planTemplate'),
            LogEntry.find({}),
            Material.find({}),
            PlanTemplate.find({})
        ]);

        res.status(200).json({
            message: 'Lấy tất cả dữ liệu thành công',
            data: {
                seasons: seasons,
                logEntries: logEntries,
                materials: materials,
                templates: templates
            },
            stats: {
                totalSeasons: seasons.length,
                totalLogs: logEntries.length,
                totalMaterials: materials.length,
                totalTemplates: templates.length
            }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ 
            message: 'Lỗi server khi lấy dữ liệu', 
            error: err.message 
        });
    }
});

/**
 * GET /api/data/seasons
 * Chức năng: Lấy tất cả mùa vụ (kể cả inactive)
 */
router.get('/seasons', async (req, res) => {
    try {
        const seasons = await FarmSeason.find({})
            .populate('planTemplate')
            .sort({ createdAt: -1 }); // Mới nhất trước

        res.status(200).json({
            message: 'Lấy danh sách mùa vụ thành công',
            count: seasons.length,
            seasons: seasons
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ 
            message: 'Lỗi server', 
            error: err.message 
        });
    }
});

/**
 * GET /api/data/logs
 * Chức năng: Lấy tất cả nhật ký
 */
router.get('/logs', async (req, res) => {
    try {
        const logs = await LogEntry.find({})
            .populate('season', 'seasonName farmArea')
            .sort({ logDate: -1 }); // Mới nhất trước

        res.status(200).json({
            message: 'Lấy danh sách nhật ký thành công',
            count: logs.length,
            logs: logs
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ 
            message: 'Lỗi server', 
            error: err.message 
        });
    }
});

/**
 * GET /api/data/materials
 * Chức năng: Lấy tất cả vật tư
 */
router.get('/materials', async (req, res) => {
    try {
        const materials = await Material.find({}).sort({ materialName: 1 });

        res.status(200).json({
            message: 'Lấy danh sách vật tư thành công',
            count: materials.length,
            materials: materials
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ 
            message: 'Lỗi server', 
            error: err.message 
        });
    }
});

/**
 * GET /api/data/templates
 * Chức năng: Lấy tất cả kế hoạch mẫu
 */
router.get('/templates', async (req, res) => {
    try {
        const templates = await PlanTemplate.find({}).sort({ templateName: 1 });

        res.status(200).json({
            message: 'Lấy danh sách kế hoạch mẫu thành công',
            count: templates.length,
            templates: templates
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ 
            message: 'Lỗi server', 
            error: err.message 
        });
    }
});

/**
 * GET /api/data/export
 * Chức năng: Export toàn bộ dữ liệu để backup
 */
router.get('/export', async (req, res) => {
    try {
        const [seasons, logEntries, materials, templates] = await Promise.all([
            FarmSeason.find({}).lean(),
            LogEntry.find({}).lean(),
            Material.find({}).lean(),
            PlanTemplate.find({}).lean()
        ]);

        const exportData = {
            exportDate: new Date(),
            data: {
                seasons,
                logEntries,
                materials,
                templates
            }
        };

        // Set headers cho file download
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Content-Disposition', `attachment; filename=backup_${Date.now()}.json`);
        
        res.status(200).json(exportData);
    } catch (err) {
        console.error(err);
        res.status(500).json({ 
            message: 'Lỗi khi export dữ liệu', 
            error: err.message 
        });
    }
});

/**
 * GET /api/data/stats
 * Chức năng: Thống kê tổng quan hệ thống
 */
router.get('/stats', async (req, res) => {
    try {
        const [
            totalSeasons,
            activeSeasons,
            totalLogs,
            logsThisMonth,
            totalMaterials,
            totalTemplates
        ] = await Promise.all([
            FarmSeason.countDocuments({}),
            FarmSeason.countDocuments({ isActive: true }),
            LogEntry.countDocuments({}),
            LogEntry.countDocuments({ 
                logDate: { 
                    $gte: new Date(new Date().getFullYear(), new Date().getMonth(), 1) 
                } 
            }),
            Material.countDocuments({}),
            PlanTemplate.countDocuments({})
        ]);

        res.status(200).json({
            message: 'Thống kê hệ thống',
            stats: {
                seasons: {
                    total: totalSeasons,
                    active: activeSeasons,
                    inactive: totalSeasons - activeSeasons
                },
                logs: {
                    total: totalLogs,
                    thisMonth: logsThisMonth
                },
                materials: {
                    total: totalMaterials
                },
                templates: {
                    total: totalTemplates
                }
            }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ 
            message: 'Lỗi khi lấy thống kê', 
            error: err.message 
        });
    }
});

module.exports = router;