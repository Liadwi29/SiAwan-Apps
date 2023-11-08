import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
// void main() => runApp(const MaterialApp(home: MyHome()));
import 'package:presensi/models/save-presensi-response.dart';
import 'package:presensi/models/cons.dart';
import 'package:http/http.dart' as http;

class ScanQr extends StatelessWidget {
  const ScanQr({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Qr Presensi')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => QRScannerScreen(),
            ));
          },
          child: const Text('Scan QR'),
        ),
      ),
    );
  }
}

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  late Future<String> _token;
  late Future<String> _email;

  @override
  void initState() {
    super.initState();
    _prefsSetup();
  }

  Future<void> _prefsSetup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = Future<String>.value(prefs.getString('token') ?? '');
    _email = Future<String>.value(prefs.getString('email') ?? '');
  }

  Future<void> _sendDataToAPI(String scannedData) async {
    final apiUrl = '$BASE_URL/api/save-presensi/$scannedData/${await _email}';
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await _token}',
    };

    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    print(response.statusCode);
    if (response.statusCode == 200) {
      // Successfully sent data to the API
      print(apiUrl);
      print('Data sent successfully');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Sukses simpan Presensi')));
      Navigator.pop(context);
    } else {
      // Handle the error
      print(apiUrl);
      print('${await _email} Failed to send data. Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: (controller) {
                controller.scannedDataStream.listen((scanData) async {
                  setState(() {
                    result = scanData;
                  });
                  if (result != null) {
                    await _sendDataToAPI(result!.code.toString());
                  }
                });
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                'Scanned Data: ${result?.code ?? 'No Data'}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

