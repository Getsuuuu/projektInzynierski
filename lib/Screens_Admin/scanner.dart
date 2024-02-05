import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'QRCodeResultPage.dart';

class ScanerPage extends StatefulWidget {
  @override
  _ScanerPageState createState() => _ScanerPageState();
}

class _ScanerPageState extends State<ScanerPage> {
  String result = '';
  bool isCodeScanned = false;
  late String uniqueId;
  late String currentUser;

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanQRCode() async {
    try {
      final ScanResult scanResult = await BarcodeScanner.scan();

      if (!isCodeScanned && scanResult.type == ResultType.Barcode) {
        setState(() {
          isCodeScanned = true;
          result = scanResult.rawContent;
        });

        handleScannedQRCode(result);
      }
    } on Exception catch (e) {
      print('Error scanning QR code: $e');
      setState(() {
        isCodeScanned = false;
      });
    }
  }

  void handleScannedQRCode(String qrCodeData) async {
    await saveScannedQRCode(qrCodeData);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScannedQrCodePage(
          qrCodeData: qrCodeData,
          uniqueId: uniqueId,
          currentUser: currentUser,
          onReturn: () {
            setState(() {
              isCodeScanned = false;
            });
          },
        ),
      ),
    ).then((_) {
      setState(() {
        isCodeScanned = false;
      });
    });
  }

  Future<void> saveScannedQRCode(String qrCodeData) async {
    try {
      dynamic decodedData = json.decode(qrCodeData);

      if (decodedData is List<dynamic>) {
        if (decodedData.length > 0) {
          uniqueId = decodedData[0].toString();
          currentUser = decodedData.length > 1 ? decodedData[1].toString() : '';
        } else {
          throw Exception('Error dekodowania');
        }
      } else if (decodedData is Map<String, dynamic>) {
        uniqueId = decodedData['uniqueId'].toString();
        currentUser = decodedData['currentUser'].toString();
      } else {
        throw Exception('Error dekodowania danych');
      }
    } catch (e) {
      print('Error dekodowania kodu QR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zeskanuj QR'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(6.0),
              constraints: BoxConstraints(
                minWidth: double.infinity,
              ),
                child: isCodeScanned
                    ? Text(
                  'Result: $result',
                  style: TextStyle(fontSize: 18),
                )
                    : OutlinedButton(
                    onPressed: () {
                      scanQRCode();
                    },
                    style: OutlinedButton.styleFrom(
                      primary: Colors.black,
                      side: BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Zeskanuj',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
