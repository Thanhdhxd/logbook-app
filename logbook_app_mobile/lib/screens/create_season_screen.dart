// lib/screens/create_season_screen.dart
import 'package:flutter/material.dart';
import '../services/season_service.dart';
import '../utils/snackbar_helper.dart';

class CreateSeasonScreen extends StatefulWidget {
  const CreateSeasonScreen({super.key});

  @override
  State<CreateSeasonScreen> createState() => _CreateSeasonScreenState();
}

class _CreateSeasonScreenState extends State<CreateSeasonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _seasonNameController = TextEditingController();
  final _farmAreaController = TextEditingController();
  final SeasonService _seasonService = SeasonService();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createSeason() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final season = await _seasonService.createSeason(
        seasonName: _seasonNameController.text,
        farmArea: _farmAreaController.text, 
        startDate: _selectedDate,
      );

      if (mounted) {
        // Trả về season vừa tạo để hiển thị thông báo ở màn hình trước
        Navigator.pop(context, season);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, 'Lỗi: $e');
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Mùa Vụ Mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _seasonNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên mùa vụ',
                  hintText: 'VD: Mùa Lúa Đông Xuân 2025',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên mùa vụ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _farmAreaController,
                decoration: const InputDecoration(
                    labelText: 'Vị trí canh tác',
                    hintText: 'VD: Thửa ruộng A, Khu vực B',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.landscape),
                ),
                validator: (value) {
                    if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập vị trí';
                    }
                    return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.green),
                title: const Text('Ngày bắt đầu'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _createSeason,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Tạo Mùa Vụ',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _seasonNameController.dispose();
    _farmAreaController.dispose();
    super.dispose();
  }
}