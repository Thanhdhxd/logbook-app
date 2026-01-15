// lib/presentation/screens/create_season_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/season_providers.dart';
import '../../utils/snackbar_helper.dart';
import '../../domain/entities/template_entity.dart';
import '../widgets/template_dropdown.dart';

class CreateSeasonScreen extends ConsumerStatefulWidget {
  const CreateSeasonScreen({super.key});

  @override
  ConsumerState<CreateSeasonScreen> createState() => _CreateSeasonScreenState();
}

class _CreateSeasonScreenState extends ConsumerState<CreateSeasonScreen> {
    TemplateEntity? _selectedTemplate;
  final _formKey = GlobalKey<FormState>();
  final _seasonNameController = TextEditingController();
  final _farmAreaController = TextEditingController();
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
    if (_selectedTemplate == null) {
      SnackbarHelper.showError(context, 'Vui lòng chọn kế hoạch áp dụng!');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final createSeason = ref.read(createSeasonUseCaseProvider);
      final season = await createSeason.execute(
        seasonName: _seasonNameController.text,
        farmArea: _farmAreaController.text, 
        startDate: _selectedDate,
        templateId: _selectedTemplate!.id,
      );
      if (mounted) {
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
        title: const Text('Tạo Mùa Vụ Mới', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _seasonNameController,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Tên mùa vụ',
                  labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  hintText: 'VD: Mùa Lúa Đông Xuân 2025',
                  hintStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label, size: 28),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên mùa vụ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _farmAreaController,
                style: const TextStyle(fontSize: 20),
                decoration: const InputDecoration(
                  labelText: 'Vị trí canh tác',
                  labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  hintText: 'VD: Thửa ruộng A, Khu vực B',
                  hintStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.landscape, size: 28),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập vị trí';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TemplateDropdown(
                onChanged: (val) => _selectedTemplate = val,
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: Colors.green, size: 30),
                title: const Text('Ngày bắt đầu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                trailing: const Icon(Icons.edit, size: 28),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _createSeason,
                icon: const Icon(Icons.save, size: 28),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                label: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Tạo Mùa Vụ'),
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

