import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'dart:convert';

import '../models/consumer.dart';
import '../models/technical.dart';

class RegisterService {

  final String _baseUrl = 'http://helptechservice.runasp.net/api/';

  Future<bool> registerTechnical
      (Technical technical, File imageFile) async {

    final bytes = await imageFile.length();
    final ext = imageFile.path.split('.').last.toLowerCase();

    if (bytes > 5 * 1024 * 1024) {
      return false;
    }
    if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
      return false;
    }
    if (technical.id.trim().isEmpty) {
      return false;
    }
    if (technical.id.trim().length < 8 || technical.id.trim().length > 8) {
      return false;
    }
    if (technical.specialtyId < 1) {
      return false;
    }
    if (technical.districtId < 1) {
      return false;
    }
    if (technical.profileUrl.trim().isEmpty) {
      return false;
    }
    if (technical.firstname.trim().isEmpty) {
      return false;
    }
    if (technical.lastname.trim().isEmpty) {
      return false;
    }
    if (technical.age < 18 || technical.age > 70) {
      return false;
    }
    if (technical.genre.trim().isEmpty) {
      return false;
    }
    if (technical.phone < 900000000 || technical.phone > 999999999) {
      return false;
    }
    if (technical.email.trim().isEmpty) {
      return false;
    }
    if (technical.code.trim().isEmpty) {
      return false;
    }

    try {

      technical.profileUrl = (await uploadProfileTechnical
        (technical.id, imageFile))!;

      final response = await http.post(
        Uri.parse('${_baseUrl}access/register-technical'),
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
          'code': technical.code
        })
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    }
    catch(e) {
      return false;
    }
  }

  Future<bool> registerConsumer
      (Consumer consumer, File imageFile) async {

    final bytes = await imageFile.length();
    final ext = imageFile.path.split('.').last.toLowerCase();

    if (bytes > 5 * 1024 * 1024) {
      return false;
    }
    if (!(ext == 'jpg' || ext == 'jpeg' || ext == 'png')) {
      return false;
    }
    if (consumer.id.trim().isEmpty) {
      return false;
    }
    if (consumer.id.trim().length < 8 || consumer.id.trim().length > 8) {
      return false;
    }
    if (consumer.districtId < 1) {
      return false;
    }
    if (consumer.profileUrl.trim().isEmpty) {
      return false;
    }
    if (consumer.firstname.trim().isEmpty) {
      return false;
    }
    if (consumer.lastname.trim().isEmpty) {
      return false;
    }
    if (consumer.age < 18 || consumer.age > 70) {
      return false;
    }
    if (consumer.genre.trim().isEmpty) {
      return false;
    }
    if (consumer.phone < 900000000 || consumer.phone > 999999999) {
      return false;
    }
    if (consumer.email.trim().isEmpty) {
      return false;
    }
    if (consumer.code.trim().isEmpty) {
      return false;
    }

    try {

      consumer.profileUrl = (await uploadProfileConsumer
        (consumer.id, imageFile))!;

      final response = await http.post(
        Uri.parse('${_baseUrl}access/register-consumer'),
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
          'code': consumer.code
        })
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    }
    catch (e) {
      return false;
    }
  }

  Future<String?> uploadProfileTechnical
      (String technicalId, File imageFile) async {

    String extension = path.extension(imageFile.path);

    String fileName = 'Perfil-$technicalId$extension';

    Reference storageRef = FirebaseStorage.instance.ref()
        .child('HelpTechAppWeb/Technicals-Profiles/$fileName');

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    String profileUrl = await snapshot.ref.getDownloadURL();

    return profileUrl;
  }

  Future<String?> uploadProfileConsumer
      (String consumerId, File imageFile) async {

    String extension = path.extension(imageFile.path);

    String fileName = 'Perfil-$consumerId$extension';

    Reference storageRef = FirebaseStorage.instance.ref()
        .child('HelpTechAppWeb/Consumers-Profiles/$fileName');

    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;

    String profileUrl = await snapshot.ref.getDownloadURL();

    return profileUrl;
  }

  Future<String?> uploadCriminalRecordTechnical
      (String technicalId) async {

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
    }

    return null;
  }
}