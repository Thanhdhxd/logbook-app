// lib/screens/quick_confirm_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/daily_task.dart';
import '../services/task_service.dart';
import '../services/material_service.dart';
import '../utils/snackbar_helper.dart';

/// Màn hình xác nhận nhanh cho scheduled tasks
class QuickConfirmScreen extends StatefulWidget {
  final DailyTask task;
  final String seasonId;
  final String? seasonLocation;

  const QuickConfirmScreen({
    super.key,
    required this.task,
    required this.seasonId,
    this.seasonLocation,
  });

  @override
  State<QuickConfirmScreen> createState() => _QuickConfirmScreenState();
}

class _QuickConfirmScreenState extends State<QuickConfirmScreen> {
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, String> _unitControllers = {}; // Lưu đơn vị cho mỗi vật tư
  final _notesController = TextEditingController();
  final MaterialService _materialService = MaterialService();
  final _searchController = TextEditingController();
  
  List<String> _selectedMaterials = [];
  List<String> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    print('🔧 QuickConfirm Init - Task: ${widget.task.taskName}');
    print('🔧 usedMaterials count: ${widget.task.usedMaterials.length}');
    print('🔧 suggestedMaterials count: ${widget.task.suggestedMaterials.length}');
    print('🔧 notes: ${widget.task.notes}');
    
    // Pre-fill vật tư từ usedMaterials (nếu đã có log) hoặc suggestedMaterials
    if (widget.task.usedMaterials.isNotEmpty) {
      print('🔧 Pre-filling from usedMaterials');
      // Đã có log trước đó, hiển thị vật tư đã dùng
      for (var material in widget.task.usedMaterials) {
        print('🔧 Adding used material: ${material.materialName} - ${material.quantity} ${material.unit}');
        _selectedMaterials.add(material.materialName);
        _quantityControllers[material.materialName] = TextEditingController(
          text: material.quantity.toString(),
        );
        _unitControllers[material.materialName] = material.unit ?? 'kg';
      }
    } else {
      print('🔧 Pre-filling from suggestedMaterials');
      // Chưa có log, hiển thị vật tư gợi ý từ template
      for (var material in widget.task.suggestedMaterials) {
        _selectedMaterials.add(material.materialName);
        _quantityControllers[material.materialName] = TextEditingController();
        _unitControllers[material.materialName] = material.unit;
      }
    }
    
    print('🔧 Total selected materials: ${_selectedMaterials.length}');
    
    // Pre-fill notes nếu có
    if (widget.task.notes != null && widget.task.notes!.isNotEmpty) {
      _notesController.text = widget.task.notes!;
    }
  }

  @override
  void dispose() {
    _quantityControllers.forEach((_, controller) => controller.dispose());
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleMaterial(String materialName) {
    setState(() {
      if (_selectedMaterials.contains(materialName)) {
        _selectedMaterials.remove(materialName);
        _quantityControllers[materialName]?.dispose();
        _quantityControllers.remove(materialName);
        _unitControllers.remove(materialName);
      } else {
        _selectedMaterials.add(materialName);
        _quantityControllers[materialName] = TextEditingController();
        _unitControllers[materialName] = 'kg'; // Mặc định là kg
      }
    });
  }

  Future<void> _searchMaterials(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    
    try {
      final results = await _materialService.searchMaterials(query);
      setState(() {
        _searchResults = results.map((m) => m['name'].toString()).toList();
      });
    } catch (e) {
      setState(() => _searchResults = []);
    }
  }

  void _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Quét mã vạch / QR'),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  Navigator.pop(context, barcode.rawValue);
                  break;
                }
              }
            },
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (!_selectedMaterials.contains(result)) {
          _selectedMaterials.add(result);
          _quantityControllers[result] = TextEditingController();
        }
      });
      
      SnackbarHelper.showSuccess(
        context,
        'Đã thêm: $result',
      );
    }
  }

  Future<void> _handleSave() async {
    if (_isLoading) return;
    
    // Thu thập dữ liệu vật tư
    final List<Map<String, dynamic>> usedMaterials = [];
    
    for (var materialName in _selectedMaterials) {
      final controller = _quantityControllers[materialName];
      final unit = _unitControllers[materialName] ?? 'kg';
      if (controller != null && controller.text.isNotEmpty) {
        final quantity = double.tryParse(controller.text);
        if (quantity != null && quantity > 0) {
          usedMaterials.add({
            'materialName': materialName,
            'quantity': quantity,
            'unit': unit,
          });
        }
      }
    }

    setState(() => _isLoading = true);

    final success = await TaskService().logTaskConfirmation(
      seasonId: widget.seasonId,
      taskName: widget.task.taskName,
      status: 'DONE',
      logType: 'scheduled',
      usedMaterials: usedMaterials,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      location: widget.seasonLocation,
      completedAt: DateTime.now(),
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      SnackbarHelper.showError(
        context,
        'Lỗi khi xác nhận',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm, dd/MM/yyyy');
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text(
          'Xác Nhận Công Việc',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(size: 32, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thông tin công việc
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildInfoCard(dateFormat),
              ),
              // Vật tư đã sử dụng
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildMaterialsSection(),
              ),
              // Ghi chú
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.only(bottom: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildNotesSection(),
              ),
              // Nút lưu nhật ký
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        textStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 26,
                              width: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Lưu Nhật Ký'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(DateFormat dateFormat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Công việc: ${widget.task.taskName}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: Colors.orange, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Khu vực: ${widget.seasonLocation ?? "Chưa xác định"}',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.orange[800],
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.access_time, color: Colors.blue, size: 28),
            const SizedBox(width: 16),
            Text(
              'Thời gian: ${dateFormat.format(DateTime.now())}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaterialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VẬT TƯ ĐÃ SỬ DỤNG',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 18),
        if (_selectedMaterials.isNotEmpty) ...[
          const Text(
            'Danh sách vật tư:',
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._selectedMaterials.map((materialName) =>
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: _buildMaterialCheckbox(materialName, false),
            ),
          ),
          const SizedBox(height: 18),
        ],
        // Thêm vật tư khác
        const Text(
          'Thêm vật tư khác',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _buildQuickAddButton('+ Phân đạm'),
            _buildQuickAddButton('+ Kali'),
            _buildQuickAddButton('+ Thuốc trừ sâu A'),
          ],
        ),
        const SizedBox(height: 14),
        // Tìm kiếm
        const Text(
          'Tìm kiếm vật tư:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Nhập tên vật tư...',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
            prefixIcon: const Icon(Icons.search, size: 22, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          style: const TextStyle(fontSize: 15),
          onChanged: _searchMaterials,
        ),
        if (_searchResults.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final materialName = _searchResults[index];
                return ListTile(
                  dense: true,
                  title: Text(materialName, style: const TextStyle(fontSize: 15)),
                  trailing: Icon(
                    _selectedMaterials.contains(materialName)
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color: _selectedMaterials.contains(materialName)
                        ? Colors.green
                        : Colors.grey,
                  ),
                  onTap: () {
                    _toggleMaterial(materialName);
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 14),
        // Quét mã vạch/QR
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _scanQRCode,
            icon: const Icon(Icons.qr_code_scanner, size: 24),
            label: const Text('Quét mã vạch / QR', style: TextStyle(fontSize: 17)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialCheckbox(String materialName, bool isSuggested) {
    final isChecked = _selectedMaterials.contains(materialName);
    final controller = _quantityControllers[materialName];
    final unit = _unitControllers[materialName] ?? 'kg';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: isChecked,
          onChanged: (value) => _toggleMaterial(materialName),
          title: Text(
            materialName,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: false,
          activeColor: Colors.green,
          checkColor: Colors.white,
        ),
        if (isChecked && controller != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 44, bottom: 10),
            child: Row(
              children: [
                const Text(
                  'Số lượng',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'VD: 10',
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(width: 12),
                // Dropdown chọn đơn vị
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: unit,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 18),
                    items: const [
                      DropdownMenuItem(value: 'kg', child: Text('kg')),
                      DropdownMenuItem(value: 'g', child: Text('g')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _unitControllers[materialName] = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GHI CHÚ (KHÔNG BẮT BUỘC)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepOrange,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'Ví dụ: Bón vào lúc trời rầm mát...',
            hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(String text) {
    final materialName = text.replaceAll('+ ', '');
    final isSelected = _selectedMaterials.contains(materialName);
    
    return OutlinedButton(
      onPressed: () => _toggleMaterial(materialName),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.blue,
        backgroundColor: isSelected ? Colors.blue : Colors.white,
        side: BorderSide(color: isSelected ? Colors.blue : Colors.blue[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
      ),
    );
  }}