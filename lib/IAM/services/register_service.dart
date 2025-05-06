import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'dart:convert';

import 'package:helptechmobileapp/IAM/models/technical.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/consumer.dart';

class RegisterService {

  final String baseUrl = 'http://helptechservice.runasp.net/api/';

  Future<void> requestPermission() async {

    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted) {
      print("Permiso concedido para acceder a las fotos.");
    } else {
      print("Permiso denegado para acceder a las fotos.");
    }
  }

  Future<bool> registerTechnical(Technical technical, String password) async {

    try {

      final response = await http.post(
        Uri.parse('$baseUrl/access/register-technical'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': technical.id,
          'specialtyId': technical.specialtyId,
          'districtId': technical.districtId,
          'profileUrl': technical.profileUrl,
          'firstname': technical.firstname,
          'lastname': technical.lastname,
          'age': technical.age,
          'genre': technical.genre,
          'phone': technical.phone,
          'email': technical.email,
          'code': technical.code,
          'availability': technical.availability,
          'state': 'ACTIVO',
          'code': password
        }),
      );

      return response.statusCode == 200;
    }
    catch(e) {
      return false;
    }
  }

  Future<bool> registerConsumer(Consumer consumer, String password) async {

    try {

      final response = await http.post(
        Uri.parse('$baseUrl/access/register-consumer'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': consumer.id,
          'districtId': consumer.districtId,
          'profileUrl': consumer.profileUrl,
          'firstname': consumer.firstname,
          'lastname': consumer.lastname,
          'age': consumer.age,
          'genre': consumer.genre,
          'phone': consumer.phone,
          'email': consumer.email,
          'code': consumer.code,
          'state': 'ACTIVO',
          'code': password,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> uploadProfileTechnical(int technicalId) async {

    await requestPermission();

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    File imageFile;

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
    else {
      return null;
    }

    String extension = path.extension(imageFile.path);

    String fileName = 'Perfil-$technicalId$extension';

    Reference storageRef = FirebaseStorage.instance.ref()
        .child('HelpTechAppWeb/Technicals-Profiles/$fileName');

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    String profileUrl = await snapshot.ref.getDownloadURL();

    return profileUrl;
  }

  Future<String?> uploadProfileConsumer(int consumerId) async {

    await requestPermission();

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    File imageFile;

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
    }
    else {
      return null;
    }

    String extension = path.extension(imageFile.path);

    String fileName = 'Perfil-$consumerId$extension';

    Reference storageRef = FirebaseStorage.instance.ref()
        .child('HelpTechAppWeb/Consumers-Profiles/$fileName');

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    String profileUrl = await snapshot.ref.getDownloadURL();

    return profileUrl;
  }

  Future<String?> uploadCriminalRecordTechnical(int technicalId) async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {

      File file = File(result.files.single.path!);

      String extension = path.extension(file.path);

      String fileName = 'Antecedente-$technicalId$extension';

      Reference storageRef = FirebaseStorage.instance.ref()
          .child('HelpTechAppWeb/Criminals-Records/$fileName');

      UploadTask uploadTask = storageRef.putFile(file);
      TaskSnapshot snapshot = await uploadTask;

      String fileUrl = await snapshot.ref.getDownloadURL();

      return fileUrl;
    } else {
      return null;
    }
  }
}