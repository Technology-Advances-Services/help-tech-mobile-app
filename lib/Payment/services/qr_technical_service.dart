import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../models/qr_technical.dart';

class QrTechnicalService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  final _storage = const FlutterSecureStorage();

  dynamic token = '';
  dynamic username = '';

  Future<bool> addQrTechnical(File imageFile) async {

    if (await validateQr(imageFile) == false) {
      return false;
    }

    token = await _storage.read(key: 'token');

    final qrTechnical = QrTechnical(
      technicalId: await _storage.read(key: 'username'),
      qrUrl: (await uploadQrTechnical(username, imageFile))!
    );

    final response = await http.post(
      Uri.parse('${_baseUrl}qrtechnicals/add-qr-technical'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'technicalId': qrTechnical.technicalId,
        'qrUrl': qrTechnical.qrUrl
      })
    );

    return response.statusCode >= 200 && response.statusCode < 300;
  }

  Future<List<QrTechnical>> qrByTechnical() async {

    token = await _storage.read(key: 'token');
    username = await _storage.read(key: 'username');

    token = token.replaceAll('"', '');

    final response = await http.get(
      Uri.parse('${_baseUrl}qrtechnicals/qr-by-technical?technicalId=$username'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {

      List<dynamic> data = json.decode(response.body);

      return data.map((item) {
        return QrTechnical(
          id: item['id'],
          technicalId: item['technicalId'] ?? '',
          registrationDate: item['registrationDate'] != null
            ? DateTime.parse(item['registrationDate'])
            : null,
          qrUrl: item['qrUrl'] ?? '',
          state: item['state'] ?? ''
        );
      }).toList();
    }

    return [];
  }

  Future<String?> uploadQrTechnical
      (String technicalId, File imageFile) async {

    String extension = path.extension(imageFile.path);

    String fileName = 'Yape-$technicalId$extension';

    Reference storageRef = FirebaseStorage.instance.ref()
        .child('HelpTechAppWeb/Qr-Technicals/$fileName');

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    String profileUrl = await snapshot.ref.getDownloadURL();

    return profileUrl;
  }

  Future<bool> validateQr(File imageFile) async {

    final inputImage = InputImage.fromFile(imageFile);
    final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);

    final barcodes = await barcodeScanner.processImage(inputImage);

    return barcodes.any((barcode) => barcode.format == BarcodeFormat.qrCode);
  }
}