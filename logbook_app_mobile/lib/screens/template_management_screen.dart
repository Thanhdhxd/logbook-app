// lib/screens/template_management_screen.dart
import 'package:flutter/material.dart';
import '../models/plan_template.dart';
import '../services/template_service.dart';
import '../utils/snackbar_helper.dart';
import 'create_template_screen.dart';
import 'template_detail_screen.dart';

class TemplateManagementScreen extends StatefulWidget {
  const TemplateManagementScreen({super.key});

  @override
  State<TemplateManagementScreen> createState() =>
      _TemplateManagementScreenState();
}

class _TemplateManagementScreenState extends State<TemplateManagementScreen> {
  final TemplateService _templateService = TemplateService();
  List<PlanTemplate> _templates = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final templates = await _templateService.getAllTemplates();
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteTemplate(PlanTemplate template) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa kế hoạch "${template.templateName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _templateService.deleteTemplate(template.id);
        if (mounted) {
          SnackbarHelper.showSuccess(
            context,
            'Đã xóa kế hoạch thành công',
          );
          _loadTemplates();
        }
      } catch (e) {
        if (mounted) {
          SnackbarHelper.showError(
            context,
            'Lỗi khi xóa: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Quản lý kế hoạch', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Nút thêm kế hoạch mới
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateTemplateScreen(),
                    ),
                  );
                  if (result == true) {
                    _loadTemplates();
                  }
                },
                icon: const Icon(Icons.add_box, size: 32),
                label: const Text(
                  'Thêm kế hoạch mới',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),

          // Danh sách kế hoạch
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTemplates,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có kế hoạch nào',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút "Thêm kế hoạch mới" để bắt đầu',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _templates.length,
      itemBuilder: (context, index) {
        final template = _templates[index];
        return _buildTemplateCard(template);
      },
    );
  }

  Widget _buildTemplateCard(PlanTemplate template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.13),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemplateDetailScreen(template: template),
            ),
          );
          if (result == true) {
            _loadTemplates();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.assignment, color: Colors.blue, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      template.templateName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey, size: 28),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteTemplate(template);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 24),
                            SizedBox(width: 10),
                            Text('Xóa', style: TextStyle(color: Colors.red, fontSize: 18)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Loại cây trồng: ${template.cropType}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${template.stages.length} Giai đoạn - ${template.totalTasks} Công việc',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
