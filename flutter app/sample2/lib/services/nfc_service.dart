import 'package:nfc_manager/nfc_manager.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

class NfcService {
  static const String _safeBrowsingApiKey = 'AIzaSyDAhRycwa4uFGRRmF5giRYdQm916lGnmqw';
  static const String _safeBrowsingUrl = 'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=AIzaSyDAhRycwa4uFGRRmF5giRYdQm916lGnmqw';

  Future<String> _checkUrlSafety(String url) async {
    debugPrint('Checking URL safety: $url');
    try {
      final requestBody = {
        'client': {'clientId': 'sample2-nfc-app', 'clientVersion': '1.0.0'},
        'threatInfo': {
          'threatTypes': ['MALWARE', 'SOCIAL_ENGINEERING', 'UNWANTED_SOFTWARE', 'POTENTIALLY_HARMFUL_APPLICATION'],
          'platformTypes': ['ANY_PLATFORM'],
          'threatEntryTypes': ['URL'],
          'threatEntries': [{'url': url}],
        },
      };
      final response = await http.post(
        Uri.parse(_safeBrowsingUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('matches') && data['matches'] is List && data['matches'].isNotEmpty) {
          final threatType = data['matches'][0]['threatType'] as String;
          debugPrint('Threat detected (Google Safe Browsing): $threatType');
          return 'URL: $url\nSafety: Unsafe ($threatType - Google Safe Browsing)';
        } else {
          debugPrint('No threats detected by Google Safe Browsing, performing local check');
          // Fallback local check
          return _localUrlSafetyCheck(url);
        }
      } else {
        debugPrint('API failed with status: ${response.statusCode}');
        return 'URL: $url\nSafety: Check failed (HTTP ${response.statusCode}: ${response.body})';
      }
    } catch (e) {
      debugPrint('Safe Browsing API error: $e');
      // Fallback to local check if API fails entirely
      return _localUrlSafetyCheck(url) + '\nNote: API unavailable ($e)';
    }
  }

  String _localUrlSafetyCheck(String url) {
    debugPrint('Performing local safety check on: $url');
    // Basic heuristic for safety
    if (url.startsWith('https://')) {
      // HTTPS is generally safer
      if (_containsSuspiciousKeywords(url)) {
        debugPrint('Local check: Unsafe due to suspicious keywords');
        return 'URL: $url\nSafety: Unsafe';
      }
      debugPrint('Local check: Safe (HTTPS)');
      return 'URL: $url\nSafety: Safe';
    } else if (url.startsWith('http://')) {
      // HTTP is less secure
      debugPrint('Local check: Unsafe (HTTP)');
      return 'URL: $url\nSafety: Unsafe';
    } else {
      // Non-HTTP/HTTPS or malformed
      debugPrint('Local check: Unsafe (unknown protocol)');
      return 'URL: $url\nSafety: Unsafe';
    }
  }

  bool _containsSuspiciousKeywords(String url) {
    // Simple keyword check for common phishing/malware patterns
    final suspiciousKeywords = [
      'login',
      'password',
      'free',
      'download',
      'verify',
      'account',
      'secure',
    ];
    final lowerUrl = url.toLowerCase();
    for (final keyword in suspiciousKeywords) {
      if (lowerUrl.contains(keyword)) {
        return true;
      }
    }
    return false;
  }

  void startNfcScan(Function(String) onData) async {
    debugPrint('Starting NFC scan session');
    await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      debugPrint('NFC tag discovered');
      final ndef = Ndef.from(tag);
      if (ndef != null) {
        debugPrint('Reading NDEF data');
        final message = await ndef.read();
        debugPrint('NDEF message read: ${message.records.length} records');
        final data = <String>[];
        for (final record in message.records) {
          debugPrint('Record Type: ${record.type.toList()}');
          debugPrint('Raw Payload: ${record.payload.toList()}');
          if (record.type.length == 1 && record.type[0] == 0x55) {
            final payload = record.payload;
            if (payload.isNotEmpty) {
              final prefixCode = payload[0];
              final uriBody = String.fromCharCodes(payload.sublist(1));
              String uri;
              switch (prefixCode) {
                case 0x01:
                  uri = 'http://www.$uriBody';
                  break;
                case 0x02:
                  uri = 'https://www.$uriBody';
                  break;
                case 0x03:
                  uri = 'http://$uriBody';
                  break;
                case 0x04:
                  uri = 'https://$uriBody';
                  break;
                default:
                  uri = uriBody;
              }
              final safetyResult = await _checkUrlSafety(uri);
              data.add(safetyResult);
            } else {
              data.add('Empty URI');
            }
          } else {
            final payload = String.fromCharCodes(record.payload);
            if (payload.startsWith('http://') || payload.startsWith('https://')) {
              final safetyResult = await _checkUrlSafety(payload);
              data.add(safetyResult);
            } else {
              data.add(payload);
            }
          }
        }
        debugPrint('Data to return: ${data.join('\n')}');
        onData(data.join('\n'));
      } else {
        debugPrint('NDEF not supported');
        onData('NDEF not supported');
      }
    });
  }

  void writeNfcTag(String text, Function(String) onComplete) async {
    debugPrint('Starting NFC write session');
    await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      final ndef = Ndef.from(tag);
      if (ndef != null) {
        final textBytes = utf8.encode(text);
        final ndefRecord = NdefRecord(
          typeNameFormat: NdefTypeNameFormat.values[1],
          type: Uint8List.fromList([0x54]),
          identifier: Uint8List(0),
          payload: textBytes,
        );
        final ndefMessage = NdefMessage([ndefRecord]);
        await ndef.write(ndefMessage);
        onComplete('Data written to tag: $text');
      } else {
        onComplete('NDEF not supported');
      }
    });
  }
}