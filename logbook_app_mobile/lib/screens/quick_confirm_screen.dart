// lib/screens/quick_confirm_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/daily_task.dart';
import '../services/task_service.dart';
import '../services/material_service.dart';

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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm: $result'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Đã xác nhận công việc'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi khi xác nhận'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm, dd/MM/yyyy');
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Xác nhận công việc'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thông tin công việc
                  _buildInfoCard(dateFormat),
                  
                  const SizedBox(height: 16),
                  
                  // Vật tư đã sử dụng
                  _buildMaterialsSection(),
                  
                  const SizedBox(height: 16),
                  
                  // Ghi chú
                  _buildNotesSection(),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          
          // Nút Lưu nhật ký
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Lưu nhật ký',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Công việc: ${widget.task.taskName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(
                'Khu vực: ${widget.seasonLocation ?? "Chưa xác định"}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Text(
                'Thời gian: ${dateFormat.format(DateTime.now())}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VẬT TƯ ĐÃ SỬ DỤNG',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Hiển thị vật tư đã chọn (từ usedMaterials hoặc suggestedMaterials)
          if (_selectedMaterials.isNotEmpty) ...[
            const Text(
              'Vật tư đã sử dụng:',
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ..._selectedMaterials.map((materialName) =>
              _buildMaterialCheckbox(materialName, false),
            ),
            const SizedBox(height: 16),
          ],
          
          // Thêm vật tư khác
          const Text(
            'Thêm vật tư khác',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vật tư hay dùng:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          
          // Nút vật tư hay dùng (hardcode)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickAddButton('+ Phân đạm'),
              _buildQuickAddButton('+ Kali'),
              _buildQuickAddButton('+ Thuốc trừ sâu A'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Tìm kiếm
          const Text(
            'Tìm kiếm:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Nhập tên vật tư...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
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
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: _searchMaterials,
          ),
          
          // Kết quả tìm kiếm
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
                    title: Text(materialName, style: const TextStyle(fontSize: 14)),
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
          
          const SizedBox(height: 16),
          
          // Phương án 3: Quét mã vạch/QR
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _scanQRCode,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Quét mã vạch / QR'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                side: const BorderSide(color: Colors.blue),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          
        ],
      ),
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
            style: const TextStyle(fontSize: 14),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        if (isChecked && controller != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 40, bottom: 8),
            child: Row(
              children: [
                const Text(
                  'Số lượng',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'VD: 10',
                      hintStyle: TextStyle(
                        fontSize: 13,
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
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                // Dropdown chọn đơn vị
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: unit,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 20),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GHI CHÚ (KHÔNG BẮT BUỘC)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Bón vào lúc trời rầm mát...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                borderSide: const BorderSide(color: Colors.blue),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            style: const TextStyle(fontSize: 14),
            maxLines: 3,
          ),
        ],
      ),
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