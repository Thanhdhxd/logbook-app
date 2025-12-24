// lib/screens/traceability_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/traceability.dart';
import '../services/traceability_service.dart';

class TraceabilityScreen extends StatefulWidget {
  final String seasonId;

  const TraceabilityScreen({
    super.key,
    required this.seasonId,
  });

  @override
  State<TraceabilityScreen> createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends State<TraceabilityScreen> {
  final TraceabilityService _service = TraceabilityService();
  TraceabilityData? _traceabilityData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTraceabilityData();
  }

  Future<void> _loadTraceabilityData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _service.getTraceability(widget.seasonId);
      setState(() {
        _traceabilityData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Kết quả truy xuất nguồn gốc', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTraceabilityData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _traceabilityData == null
                  ? const Center(child: Text('Không có dữ liệu'))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildBasicInfo(),
                          _buildStagesInfo(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.green[200],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.spa, color: Colors.green, size: 40),
            const SizedBox(width: 16),
            Text(
              _traceabilityData!.cropType.toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green[900],
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    final data = _traceabilityData!;
    final dateFormat = DateFormat('dd/MM/yyyy');
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.18),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.eco, color: Colors.green, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.seasonName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildInfoRow('Mã lô & xuất:', data.lotCode, Colors.red[700]!, fontSize: 18),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Ngày thu hoạch:',
            data.harvestDate != null
                ? dateFormat.format(data.harvestDate!)
                : 'Chưa thu hoạch',
            Colors.black87,
            fontSize: 18,
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Nơi canh tác:',
            data.farmArea,
            Colors.black87,
            fontSize: 18,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            children: [
              Chip(
                label: const Text('VietGAP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.green[100],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              Chip(
                label: const Text('OCOP 4 sao', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.blue[100],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor, {double fontSize = 16}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStagesInfo() {
    // Tính ngày hiện tại so với startDate
    final currentDay = _traceabilityData != null 
        ? DateTime.now().difference(_traceabilityData!.startDate).inDays + 1
        : 0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: Colors.green, size: 28),
                const SizedBox(width: 10),
                Text(
                  'Chi tiết nhật ký canh tác',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
          ),
          ...(_traceabilityData?.stages ?? [])
              .asMap()
              .entries
              .map((entry) => _buildStageCard(entry.key + 1, entry.value, currentDay))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildStageCard(int stageNumber, StageLog stage, int currentDay) {
    // Check xem giai đoạn này có phải là giai đoạn hiện tại không
    final isCurrentStage = currentDay >= stage.startDay && currentDay <= stage.endDay;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              'GIAI ĐOẠN $stageNumber: ${stage.stageName.toUpperCase()}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: stage.tasks
                  .map((task) => _buildTaskItem(task, isCurrentStage))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskLog task, bool isCurrentStage) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isCompleted = task.isCompleted ?? false;
    final today = DateTime.now();
    
    // Parse ngày dự kiến từ scheduledDate (DD/MM/YYYY)
    DateTime? scheduledDateTime;
    if (task.scheduledDate != null && task.scheduledDate!.isNotEmpty) {
      try {
        final parts = task.scheduledDate!.split('/');
        if (parts.length == 3) {
          scheduledDateTime = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
        }
      } catch (e) {
        // Ignore parse error
      }
    }
    
    // Logic hiển thị ngày
    String dateDisplay = '';
    bool isToday = false;
    
    if (isCompleted && task.completedDates.isNotEmpty) {
      dateDisplay = 'Ngày ${dateFormat.format(task.completedDates.first)}';
    } else if (scheduledDateTime != null) {
      final scheduledDateOnly = DateTime(scheduledDateTime.year, scheduledDateTime.month, scheduledDateTime.day);
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      
      if (scheduledDateOnly.isBefore(todayDateOnly)) {
        // Ngày đã qua → "Ngày DD/MM/YYYY" + chấm xám
        dateDisplay = 'Ngày ${task.scheduledDate}';
      } else if (scheduledDateOnly.isAtSameMomentAs(todayDateOnly)) {
        // Ngày hôm nay → "Ngày DD/MM/YYYY" + chấm xanh
        dateDisplay = 'Ngày ${task.scheduledDate}';
        isToday = true;
      } else {
        // Ngày chưa đến → "Dự kiến: DD/MM/YYYY" + chấm xám
        dateDisplay = 'Dự kiến: ${task.scheduledDate}';
      }
    } else {
      dateDisplay = 'Dự kiến: (Chưa đặt lịch)';
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4, right: 8),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isToday ? Colors.green[600] : Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateDisplay,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  task.taskName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Hiển thị vật tư thực tế (nếu đã hoàn thành)
                if (isCompleted && task.materials.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...task.materials.map((material) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Vật tư: ${material.materialName} (${material.quantity}${material.unit})',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      )),
                ],
                // Hiển thị vật tư đề xuất (nếu chưa hoàn thành)
                if (!isCompleted && task.suggestedMaterials != null && task.suggestedMaterials!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...task.suggestedMaterials!.map((material) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          material.suggestedQuantityUnit != null && material.suggestedQuantityUnit!.isNotEmpty
                            ? 'Vật tư: ${material.materialName} (${material.suggestedQuantityUnit})'
                            : 'Vật tư: ${material.materialName}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      )),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
