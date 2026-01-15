// lib/widgets/barcode_scanner_widget.dart
import 'package:flutter/material.dart';

class BarcodeScannerWidget extends StatelessWidget {
  const BarcodeScannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét mã v?ch'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tính nang quét mã v?ch',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Ð? s? d?ng tính nang này, b?n c?n cài d?t thêm package:\nmobile_scanner ho?c qr_code_scanner',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, 'MOCK_BARCODE_12345');
              },
              child: const Text('Mô ph?ng quét mã (Demo)'),
            ),
          ],
        ),
      ),
    );
  }
}

