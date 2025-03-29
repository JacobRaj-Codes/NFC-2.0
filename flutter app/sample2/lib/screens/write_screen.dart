import 'package:flutter/material.dart';
import '../services/nfc_service.dart';

class WriteScreen extends StatefulWidget {
  const WriteScreen({super.key});

  @override
  _WriteScreenState createState() => _WriteScreenState();
}

class _WriteScreenState extends State<WriteScreen> {
  String _nfcData = 'Enter text and place an NFC card to write';
  final NfcService _nfcService = NfcService();
  final TextEditingController _textController = TextEditingController();

  void _writeNfcTag() {
    final textToWrite = _textController.text.trim();
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
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Write NFC Card')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _nfcData,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
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