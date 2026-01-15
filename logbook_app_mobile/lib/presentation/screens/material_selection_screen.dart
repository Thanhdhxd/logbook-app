// lib/screens/material_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_providers.dart';
import '../providers/service_providers.dart';
import '../../utils/snackbar_helper.dart';

class MaterialSelectionScreen extends ConsumerStatefulWidget {
  final TaskEntity? task;
  final String seasonId;
  final String? seasonLocation;

  const MaterialSelectionScreen({
    super.key,
    this.task,
    required this.seasonId,
    this.seasonLocation,
  });

  @override
  ConsumerState<MaterialSelectionScreen> createState() =>
      _MaterialSelectionScreenState();
}

class _MaterialSelectionScreenState extends ConsumerState<MaterialSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _taskNameController = TextEditingController();
  final Map<String, TextEditingController> _quantityControllers = {};
  final Map<String, String> _unitControllers = {}; // Lưu đơn vị cho mỗi vật tư
  final _notesController = TextEditingController();
  
  List<dynamic> _suggestedMaterials = [];
  List<String> _selectedMaterials = [];
  bool _isLoading = false;
  bool _isSaving = false; // Guard để tránh double submit
  DateTime _selectedDateTime = DateTime.now();
  String? _selectedLocation; // Đổi thành nullable
  
  final List<String> _availableLocations = [
    'Thửa ruộng A',
    'Thửa ruộng B',
    'Thửa ruộng C',
    'Khu vực khác',
  ];

  @override
  void initState() {
    super.initState();
    // Kiểm tra xem location từ season có trong danh sách không
    final seasonLoc = widget.seasonLocation ?? 'Thửa ruộng A';
    _selectedLocation = _availableLocations.contains(seasonLoc) 
        ? seasonLoc 
        : _availableLocations.first; // Đảm bảo luôn chọn item hợp lệ
    
    // Nếu có task từ kế hoạch, fill dữ liệu
    if (widget.task != null) {
      _taskNameController.text = widget.task!.taskName;
      _loadSuggestedMaterials();
      
      // Khởi tạo controllers cho vật tư gợi ý từ task
      for (var material in widget.task!.suggestedMaterials) {
        _quantityControllers[material.materialName] = TextEditingController(
          text: material.quantityPerUnit.toString(),
        );
        _selectedMaterials.add(material.materialName);
        _unitControllers[material.materialName] = material.unit;
      }
    }
  }

  Future<void> _loadSuggestedMaterials() async {
    if (widget.task == null) return;
    
    setState(() => _isLoading = true);
    try {
      final materials = await ref.read(materialServiceProvider).getSuggestedMaterials(
        widget.seasonId,
        widget.task!.taskName,
      );
      setState(() {
        _suggestedMaterials = materials;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _showMaterialSearch() {
    final availableMaterials = [
      'Phân lân',
      'Kali',
      'Thuốc trừ sâu A',
      'Phân NPK',
      'Phân Đạm',
      'Giống lúa',
      'Thuốc diệt cỏ',
      'Phân hữu cơ',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn vật tư',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Nhập tên vật tư...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
            
            // Material list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: availableMaterials.length,
                itemBuilder: (context, index) {
                  final material = availableMaterials[index];
                  final isSelected = _selectedMaterials.contains(material);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade50 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.grass,
                          color: isSelected ? Colors.white : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        material,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedMaterials.remove(material);
                            _quantityControllers[material]?.dispose();
                            _quantityControllers.remove(material);
                            _unitControllers.remove(material);
                          } else {
                            _selectedMaterials.add(material);
                            _quantityControllers[material] = TextEditingController(text: '0');
                            _unitControllers[material] = 'kg';
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Guard: Nếu đang saving thì không làm gì cả
    if (_isSaving) return;
    
    // Thu thập dữ liệu vật tư đã chọn
    final List<Map<String, dynamic>> usedMaterials = [];
    
    _quantityControllers.forEach((materialName, controller) {
      if (controller.text.isNotEmpty) {
        final quantity = double.tryParse(controller.text);
        final unit = _unitControllers[materialName] ?? 'kg';
        if (quantity != null && quantity > 0) {
          usedMaterials.add({
            'materialName': materialName,
            'quantity': quantity,
            'unit': unit,
          });
        }
      }
    });

    setState(() {
      _isLoading = true;
      _isSaving = true; // Đánh dấu đang saving
    });
    
    final success = await ref.read(taskServiceProvider).logTaskConfirmation(
      seasonId: widget.seasonId,
      taskName: _taskNameController.text,
      status: 'PENDING',
      logType: 'manual',
      usedMaterials: usedMaterials,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      location: _selectedLocation,
      completedAt: _selectedDateTime,
    );

    setState(() {
      _isLoading = false;
      _isSaving = false; // Reset flag
    });

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      SnackbarHelper.showError(context, 'Lỗi khi ghi nhật ký');
    }
  }

  Future<void> _handleScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QRScannerScreen(),
      ),
    );

    if (result != null && mounted) {
      final barcode = result.toString();
      
      // Hiển thị loading
      setState(() => _isLoading = true);
      
      try {
        // Tìm vật tư theo barcode
        final material = await ref.read(materialServiceProvider).getMaterialByBarcode(barcode);
        
        if (material != null && mounted) {
          final materialName = material['name'] as String;
          final unit = material['unit'] as String? ?? 'kg';
          
          setState(() {
            if (!_selectedMaterials.contains(materialName)) {
              _selectedMaterials.add(materialName);
              _quantityControllers[materialName] = TextEditingController();
              _unitControllers[materialName] = unit;
            }
            _isLoading = false;
          });
          
          if (mounted) {
            SnackbarHelper.showSuccess(context, '✓ Đã thêm: $materialName');
          }
        } else {
          setState(() => _isLoading = false);
          if (mounted) {
            SnackbarHelper.showError(context, '❌ Không tìm thấy vật tư với mã: $barcode');
          }
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          SnackbarHelper.showError(context, 'Lỗi: ${e.toString()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Quay lại',
        ),
        title: const Text('Thêm nhật ký thủ công', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // CÔNG VIỆC
            _buildSectionTitle('CÔNG VIỆC', fontSize: 20),
            const SizedBox(height: 16),
            TextFormField(
              controller: _taskNameController,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: 'VD: Phun thuốc trừ sâu',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                prefixIcon: const Icon(Icons.assignment, size: 28),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập tên công việc';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // KHU VỰC
            _buildSectionTitle('KHU VỰC', fontSize: 20),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, size: 28),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  items: _availableLocations.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 18)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLocation = newValue;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // THỜI GIAN
            _buildSectionTitle('THỜI GIAN', fontSize: 20),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDateTime(context),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 28),
                    const SizedBox(width: 16),
                    Text(
                      '${_selectedDateTime.day.toString().padLeft(2, '0')}/${_selectedDateTime.month.toString().padLeft(2, '0')}/${_selectedDateTime.year} ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // VẬT TƯ ĐÃ SỬ DỤNG
            _buildSectionTitle('VẬT TƯ ĐÃ SỬ DỤNG', fontSize: 20),
            const SizedBox(height: 16),
            
            // Vật tư hay dùng (hiển thị khi chưa chọn gì)
            if (_selectedMaterials.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vật tư hay dùng:',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['Phân lân', 'Kali', 'Thuốc trừ sâu A'].map((material) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMaterials.add(material);
                              _quantityControllers[material] = TextEditingController(text: '0');
                              _unitControllers[material] = 'kg';
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add, size: 16, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  material,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

            // Vật tư đã chọn
            if (_selectedMaterials.isNotEmpty)
              Column(
                children: _selectedMaterials.map((material) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.check, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 120,
                                    child: TextFormField(
                                      controller: _quantityControllers[material],
                                      decoration: InputDecoration(
                                        hintText: 'Số lượng',
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[400],
                                        ),
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: Colors.grey.shade300),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Colors.green, width: 2),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButton<String>(
                                      value: _unitControllers[material] ?? 'kg',
                                      underline: const SizedBox(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600], size: 20),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'kg',
                                          child: Text('kg'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'g',
                                          child: Text('g'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _unitControllers[material] = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: Colors.grey.shade600,
                          onPressed: () {
                            setState(() {
                              _selectedMaterials.remove(material);
                              _quantityControllers[material]?.dispose();
                              _quantityControllers.remove(material);
                              _unitControllers.remove(material);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),

            // Tìm kiếm
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tìm kiếm:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showMaterialSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Nhập tên vật tư...',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Quét mã vạch / QR
            ElevatedButton.icon(
              onPressed: _handleScan,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Quét mã vạch / QR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // GHI CHÚ
            _buildSectionTitle('GHI CHÚ (KHÔNG BẮT BUỘC)', fontSize: 20),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: 'VD: Bón vào lúc trời rầm mát...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),

            const SizedBox(height: 32),

            // Nút Lưu nhật ký
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleSave,
              icon: const Icon(Icons.save, size: 28),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              label: _isLoading
                  ? const SizedBox(
                      height: 28,
                      width: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Lưu nhật ký',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {double fontSize = 16}) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: Colors.black87,
      ),
    );
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _quantityControllers.forEach((_, controller) => controller.dispose());
    _notesController.dispose();
    super.dispose();
  }
}

// Màn hình quét QR/Barcode thực tế
class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isScanned = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Kiểm tra platform
    _checkPlatform();
  }

  void _checkPlatform() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      // Nếu sau 2 giây mà không có camera, hiển thị lỗi
      if (mounted && _errorMessage == null) {
        setState(() {
          _errorMessage = 'Camera không khả dụng trên web browser.\nVui lòng chạy app trên điện thoại Android/iOS.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi khởi động camera: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Quét mã vạch / QR'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Để test trên Chrome, bạn có thể nhập mã thủ công:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Nhập mã vạch...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      Navigator.pop(context, value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Quét mã vạch / QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                return const Icon(Icons.cameraswitch);
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isScanned) return;
              
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => _isScanned = true);
                  
                  // Mapping barcode to material name
                  String materialName = _getMaterialFromBarcode(barcode.rawValue!);
                  
                  Navigator.pop(context, materialName);
                  break;
                }
              }
            },
          ),
          
          // Overlay với khung quét
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),
          
          // Hướng dẫn
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'Đặt mã vạch/QR vào trong khung',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mã sẽ được quét tự động',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMaterialFromBarcode(String barcode) {
    // Mapping barcode to material names
    // Trong thực tế, bạn sẽ gọi API để lấy thông tin vật tư từ barcode
    final Map<String, String> barcodeMapping = {
      '8934563001234': 'Phân NPK',
      '8934563001235': 'Phân Đạm',
      '8934563001236': 'Kali',
      '8934563001237': 'Phân lân',
      '8934563001238': 'Thuốc trừ sâu A',
    };
    
    return barcodeMapping[barcode] ?? 'Vật tư (${barcode.substring(0, 8)})';
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

// Custom painter cho overlay quét
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaSize = size.width * 0.7;
    final double left = (size.width - scanAreaSize) / 2;
    final double top = (size.height - scanAreaSize) / 2;
    
    // Vẽ nền tối xung quanh khung quét
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final holePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanAreaSize, scanAreaSize),
        const Radius.circular(12),
      ));
    
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5);
    
    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, holePath),
      backgroundPaint,
    );
    
    // Vẽ viền khung quét
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    
    final borderRadius = 12.0;
    final cornerLength = 30.0;
    
    // Góc trên trái
    canvas.drawLine(
      Offset(left, top + borderRadius),
      Offset(left, top + cornerLength),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(left, top, borderRadius * 2, borderRadius * 2),
      3.14,
      1.57,
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + borderRadius, top),
      Offset(left + cornerLength, top),
      borderPaint,
    );
    
    // Góc trên phải
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top),
      Offset(left + scanAreaSize - borderRadius, top),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        left + scanAreaSize - borderRadius * 2,
        top,
        borderRadius * 2,
        borderRadius * 2,
      ),
      4.71,
      1.57,
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + borderRadius),
      Offset(left + scanAreaSize, top + cornerLength),
      borderPaint,
    );
    
    // Góc dưới trái
    canvas.drawLine(
      Offset(left, top + scanAreaSize - cornerLength),
      Offset(left, top + scanAreaSize - borderRadius),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        left,
        top + scanAreaSize - borderRadius * 2,
        borderRadius * 2,
        borderRadius * 2,
      ),
      1.57,
      1.57,
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + borderRadius, top + scanAreaSize),
      Offset(left + cornerLength, top + scanAreaSize),
      borderPaint,
    );
    
    // Góc dưới phải
    canvas.drawLine(
      Offset(left + scanAreaSize - cornerLength, top + scanAreaSize),
      Offset(left + scanAreaSize - borderRadius, top + scanAreaSize),
      borderPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        left + scanAreaSize - borderRadius * 2,
        top + scanAreaSize - borderRadius * 2,
        borderRadius * 2,
        borderRadius * 2,
      ),
      0,
      1.57,
      false,
      borderPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaSize, top + scanAreaSize - cornerLength),
      Offset(left + scanAreaSize, top + scanAreaSize - borderRadius),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}