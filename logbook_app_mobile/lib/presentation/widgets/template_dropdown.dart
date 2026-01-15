import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/template_entity.dart';
import '../providers/template_providers.dart';

class TemplateDropdown extends ConsumerStatefulWidget {
  final Function(TemplateEntity?) onChanged;
  final TemplateEntity? initialValue;
  const TemplateDropdown({Key? key, required this.onChanged, this.initialValue}) : super(key: key);

  @override
  ConsumerState<TemplateDropdown> createState() => _TemplateDropdownState();
}

class _TemplateDropdownState extends ConsumerState<TemplateDropdown> {
  List<TemplateEntity> _templates = [];
  TemplateEntity? _selected;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    setState(() { _loading = true; _error = null; });
    try {
      final getAllTemplates = ref.read(getAllTemplatesUseCaseProvider);
      final templates = await getAllTemplates();
      setState(() {
        _templates = templates;
        _selected = widget.initialValue;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text('Lỗi tải kế hoạch: $_error', style: const TextStyle(color: Colors.red))),
          IconButton(onPressed: _fetchTemplates, icon: const Icon(Icons.refresh))
        ],
      );
    }
    return DropdownButtonFormField<TemplateEntity>(
      value: _selected,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Chọn kế hoạch áp dụng',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.assignment),
      ),
      items: _templates.map((template) => DropdownMenuItem(
        value: template,
        child: Text(template.templateName, style: const TextStyle(fontSize: 18)),
      )).toList(),
      onChanged: (val) {
        setState(() { _selected = val; });
        widget.onChanged(val);
      },
      validator: (val) => val == null ? 'Vui lòng chọn kế hoạch' : null,
    );
  }
}
