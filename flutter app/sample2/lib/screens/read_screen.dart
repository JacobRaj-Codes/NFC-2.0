import 'package:flutter/material.dart';
import '../services/nfc_service.dart';

class ReadScreen extends StatefulWidget {
  const ReadScreen({super.key});

  @override
  _ReadScreenState createState() => _ReadScreenState();
}

class _ReadScreenState extends State<ReadScreen> {
  String _nfcData = 'Place the card near the Phone'; // Initial text
  final NfcService _nfcService = NfcService();

  @override
  void initState() {
    super.initState();
    _startNfcScan(); // Start scan in background without loading
  }

  void _startNfcScan() {
    _nfcService.startNfcScan((data) {
      if (mounted) { // Ensure widget is still active
        setState(() {
          _nfcData = data; // Update text with scan result
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Read NFC Card')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _nfcData,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}