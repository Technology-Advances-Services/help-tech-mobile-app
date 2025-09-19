import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/qr_technical_service.dart';

class AddQrTechnical extends StatefulWidget {

  const AddQrTechnical({super.key});

  @override
  State<AddQrTechnical> createState() => _AddQrTechnicalState();
}

class _AddQrTechnicalState extends State<AddQrTechnical> {

  final _qrTechnicalService = QrTechnicalService();

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  File? qrImage;
  bool isLoading = false;

  Future<void> pickQrImage() async {

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        qrImage = File(pickedFile.path);
      });
    }
  }

  Future<void> submitQr() async {

    setState(() => isLoading = true);

    var result = await _qrTechnicalService.addQrTechnical(qrImage!);

    setState(() => isLoading = false);

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFC25252),
            Color(0xFF944FA4),
            Color(0xFF602D98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Agregar QR Yape'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Sube tu QR',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        qrImage != null ?
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            qrImage!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ) :
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'No has seleccionado un QR',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Seleccionar QR'),
                          onPressed: pickQrImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        isLoading ? const CircularProgressIndicator(
                          color: Colors.white,
                        ) :
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.send),
                            label: const Text('Subir QR'),
                            onPressed: submitQr,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 6,
                              shadowColor: Colors.tealAccent.shade200,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}