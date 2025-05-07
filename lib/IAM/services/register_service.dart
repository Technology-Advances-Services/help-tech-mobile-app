import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:helptechmobileapp/IAM/models/membership.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'dart:convert';

import 'package:helptechmobileapp/IAM/models/technical.dart';

import '../models/consumer.dart';

class RegisterService {

  final String baseUrl = 'http://helptechservice.runasp.net/api/';

  Future<bool> registerTechnical
      (Technical technical, File imageFile) async {

    try {

      technical.profileUrl = (await uploadProfileTechnical
        (technical.id, imageFile))!;

      final response = await http.post(
        Uri.parse('${baseUrl}access/register-technical'),
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
        }),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    }
    catch(e) {
      return false;
    }
  }

  Future<bool> registerConsumer
      (Consumer consumer, File imageFile) async {

    try {

      consumer.profileUrl = (await uploadProfileConsumer
        (consumer.id, imageFile))!;

      final response = await http.post(
        Uri.parse('${baseUrl}access/register-consumer'),
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
        }),
      );

      return response.statusCode >= 200 && response.statusCode < 300;
    }
    catch (e) {
      return false;
    }
  }

  Future<bool> registerMembership
      (Membership membership, String personId, String role) async {

    String endpoint = role == 'TECNICO' ? 'contracts/create-technical-contract'
        : 'contracts/create-consumer-contract';

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': membership.id,
        if (role == 'TECNICO') 'technicalId': personId,
        if (role == 'CONSUMIDOR') 'consumerId': personId,
        'name': membership.name,
        'price': membership.price,
        'policies': membership.policies,
      })
    );

    return response.statusCode >= 200 && response.statusCode < 300;
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
    else {
      return null;
    }
  }
}