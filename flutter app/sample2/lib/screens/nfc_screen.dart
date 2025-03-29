import 'package:flutter/material.dart';
import '../services/nfc_service.dart';

class NfcScreen extends StatefulWidget {
  const NfcScreen({super.key});

  @override
  _NfcScreenState createState() => _NfcScreenState();
}

class _NfcScreenState extends State<NfcScreen> {
  String _nfcData = 'Scan a tag';
  final NfcService _nfcService = NfcService();
  final TextEditingController _textController = TextEditingController(); // Controller for input

  @override
  void initState() {
    super.initState();
    _startNfcScan();
  }

  void _startNfcScan() {
    _nfcService.startNfcScan((data) {
      setState(() {
        _nfcData = data;
      });
    });
  }

  void _writeNfcTag() {
    final textToWrite = _textController.text.trim(); // Get text from input
    if (textToWrite.isEmpty) {
      setState(() {
        _nfcData = 'Please enter some text to write!';
      });
      return;
    }
    _nfcService.writeNfcTag(textToWrite, (data) {
      setState(() {
        _nfcData = data;
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose(); // Clean up controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Reader')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_nfcData),
              const SizedBox(height: 20),
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter text to write to NFC tag',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _writeNfcTag,
                child: const Text('Write to Tag'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}