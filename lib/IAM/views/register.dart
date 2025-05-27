import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../Location/models/department.dart';
import '../../Location/models/district.dart';
import '../../Location/models/specialty.dart';
import '../../Location/services/information_service.dart';
import '../../Shared/widgets/error_dialog.dart';
import '../../Subscription/components/add_membership.dart';
import '../models/consumer.dart';
import '../models/technical.dart';
import '../services/register_service.dart';

import 'login.dart';

class Register extends StatefulWidget {

  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final InformationService _informationService = InformationService();
  final RegisterService _registerService = RegisterService();

  List<Department> departments = [];
  List<District> districts = [];
  List<Specialty> specialties = [];

  Department? selectedDepartment;
  District? selectedDistrict;
  Specialty? selectedSpecialty;

  String selectedRole = 'TECNICO';
  File? selectedImage;
  String? selectedGenre;

  final _idController = TextEditingController();
  final _districtIdController = TextEditingController();
  final _specialtyIdController = TextEditingController();
  final _profileUrlController = TextEditingController();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genreController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  Future<void> submitPerson() async {

    String personId = _idController.text.toString();
    String role = selectedRole;

    bool result = false;

    if (role == 'TECNICO') {
      Technical technical = Technical(
        id: _idController.text,
        specialtyId: selectedSpecialty!.id,
        districtId: selectedDistrict!.id,
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        age: int.parse(_ageController.text),
        genre: _genreController.text,
        phone: int.parse(_phoneController.text),
        email: _emailController.text,
        code: _codeController.text,
      );

      result = await _registerService.registerTechnical
        (technical, selectedImage!);

    }
    else if (role == 'CONSUMIDOR') {
      Consumer consumer = Consumer(
        id: _idController.text,
        districtId: selectedDistrict!.id,
        firstname: _firstnameController.text,
        lastname: _lastnameController.text,
        age: int.parse(_ageController.text),
        genre: _genreController.text,
        phone: int.parse(_phoneController.text),
        email: _emailController.text,
        code: _codeController.text,
      );

      result = await _registerService.registerConsumer
        (consumer, selectedImage!);
    }

    if (result == true) {
      showDialog(context: context, builder: (context) =>
        AddMembership(personId: personId, role: role),
      ).then((task) {

        if (task == true) {
          Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) =>
            const Login()), (route) => false
          );
        }
        else {
          showDialog(context: context, builder: (context) =>
            const ErrorDialog(message: 'Error al registrarse.')
          );
        }
      });
    }
    else {
      showDialog(context: context, builder: (context) =>
        const ErrorDialog(message: 'Error al registrarse.')
      );
    }
  }

  Future<void> loadDepartments() async {

    final tmpDepartments = await _informationService.getDepartments();

    setState(() {
      departments = tmpDepartments;
    });
  }

  Future<void> loadDistrictsByDepartment(int departmentId) async {

    final tmpDistricts = await _informationService
      .getDistrictsByDepartment(departmentId);

    setState(() {
      districts = tmpDistricts;
      selectedDistrict = null;
    });
  }

  Future<void> loadSpecialties() async {

    final tmpSpecialties = await _informationService.getSpecialties();

    setState(() {
      specialties = tmpSpecialties;
    });
  }

  Future<void> pickImage() async {

    final pickedFile = await ImagePicker().pickImage
      (source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _districtIdController.dispose();
    _specialtyIdController.dispose();
    _profileUrlController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _ageController.dispose();
    _genreController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadDepartments();
    loadSpecialties();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/IAM/home_wallpaper.PNG',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Registro de Usuario',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black26,
                                    offset: Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            buildDropdownRole(),
                            const SizedBox(height: 15),

                            buildTextField(
                              controller: _idController,
                              label: 'DNI'
                            ),

                            buildDropdownDepartment(),
                            buildDropdownDistrictsByDepartment(),

                            if (selectedRole == 'TECNICO')
                              buildDropdownSpecialties(),

                            buildImagePicker(),

                            buildTextField(
                              controller: _firstnameController,
                              label: 'Nombres'
                            ),
                            buildTextField(
                              controller: _lastnameController,
                              label: 'Apellidos'
                            ),
                            buildTextField(
                              controller: _ageController,
                              label: 'Edad',
                              isNumber: true
                            ),
                            buildDropdownGenre(),

                            buildTextField(
                              controller: _phoneController,
                              label: 'Telefono',
                              isNumber: true
                            ),
                            buildTextField(
                              controller: _emailController,
                              label: 'Email'
                            ),
                            buildTextField(
                              controller: _codeController,
                              label: 'Contraseña',
                              isPassword: true
                            ),
                            const SizedBox(height: 25),

                            ElevatedButton(
                              onPressed: () async => submitPerson(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.tealAccent.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric
                                  (horizontal: 50, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                                shadowColor: Colors.tealAccent.shade200,
                              ),
                              child: const Text(
                                'Registrarse',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
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
        ],
      ),
    );
  }

  Widget buildDropdownRole() {
    return DropdownButtonFormField<String>(
      value: selectedRole,
      items: const [
        DropdownMenuItem(
          value: 'CONSUMIDOR',
          child: Text('CONSUMIDOR'),
        ),
        DropdownMenuItem(
          value: 'TECNICO',
          child: Text('TECNICO'),
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedRole = value!;
        });
      },
      style: const TextStyle(
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        labelText: 'Rol',
        filled: true,
        fillColor: Colors.white.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto de Perfil',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: pickImage,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70),
                borderRadius: BorderRadius.circular(8),
                image: selectedImage != null ?
                DecorationImage(
                  image: FileImage(selectedImage!),
                  fit: BoxFit.cover,
                ) : null,
              ),
              child: selectedImage == null ?
              const Center(
                child: Icon(Icons.add_a_photo, color: Colors.white70, size: 40),
              ) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownDepartment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<Department>(
        value: selectedDepartment,
        decoration: InputDecoration(
          labelText: 'Departamento',
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        dropdownColor: Colors.white.withOpacity(0.85),
        items: departments.map((dep) {
          return DropdownMenuItem(
            value: dep,
            child: Text(dep.name),
          );
        }).toList(),
        onChanged: (dep) {
          setState(() {
            selectedDepartment = dep;
            loadDistrictsByDepartment(dep!.id);
          });
        },
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget buildDropdownDistrictsByDepartment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<District>(
        value: selectedDistrict,
        decoration: InputDecoration(
          labelText: 'Distrito',
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        dropdownColor: Colors.white.withOpacity(0.85),
        items: districts.map((dist) {
          return DropdownMenuItem(
            value: dist,
            child: Text(dist.name),
          );
        }).toList(),
        onChanged: (dist) {
          setState(() {
            selectedDistrict = dist;
          });
        },
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget buildDropdownSpecialties() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<Specialty>(
        value: selectedSpecialty,
        decoration: InputDecoration(
          labelText: 'Especialidad',
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        dropdownColor: Colors.white.withOpacity(0.85),
        items: specialties.map((spe) {
          return DropdownMenuItem(
            value: spe,
            child: Text(spe.name),
          );
        }).toList(),
        onChanged: (spe) {
          setState(() {
            selectedSpecialty = spe;
          });
        },
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget buildDropdownGenre() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: selectedGenre,
        decoration: InputDecoration(
          labelText: 'Genero',
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white),
        ),
        dropdownColor: Colors.white.withOpacity(0.85),
        items: const [
          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
          DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
        ],
        onChanged: (value) {
          setState(() {
            selectedGenre = value;
            _genreController.text = value ?? '';
          });
        },
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          labelStyle: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}