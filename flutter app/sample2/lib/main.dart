import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/read_screen.dart';
import 'screens/write_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NfcLauncher(),
      routes: {
        '/read': (context) => const ReadScreen(),
        '/write': (context) => const WriteScreen(),
      },
    );
  }
}

class NfcLauncher extends StatefulWidget {
  const NfcLauncher({super.key});

  @override
  _NfcLauncherState createState() => _NfcLauncherState();
}

class _NfcLauncherState extends State<NfcLauncher> {
  static const platform = MethodChannel('nfc_launch_channel');

  @override
  void initState() {
    super.initState();
    _checkNfcLaunch();
  }

  Future<void> _checkNfcLaunch() async {
    try {
      final String? intentAction = await platform.invokeMethod('getLaunchIntentAction');
      if (mounted) {
        if (intentAction == 'android.nfc.action.NDEF_DISCOVERED') {
          Navigator.pushReplacementNamed(context, '/read');
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/read'),
              child: const Text('Read NFC Card'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/write'),
              child: const Text('Write NFC Card'),
            ),
          ],
        ),
      ),
    );
  }
}