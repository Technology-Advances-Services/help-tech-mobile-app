import 'dart:io';

import 'package:flutter/material.dart';
import 'package:helptechmobileapp/Subscription/components/add_membership.dart';
import 'package:helptechmobileapp/IAM/models/technical.dart';
import 'package:helptechmobileapp/IAM/services/register_service.dart';
import 'package:helptechmobileapp/Location/models/specialty.dart';
import 'package:image_picker/image_picker.dart';

import '../../Location/models/department.dart';
import '../../Location/models/district.dart';
import '../../Location/services/information_service.dart';
import '../../Shared/widgets/error_dialog.dart';
import '../models/consumer.dart';
import 'login.dart';

class Register extends StatefulWidget {

  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final InformationService _informationService = InformationService();
  final RegisterService _registerService = RegisterService();

  List<Department> _departments = [];
  List<District> _districts = [];
  List<Specialty> _specialties = [];

  Department? _selectedDepartment;
  District? _selectedDistrict;
  Specialty? _selectedSpecialty;

  String selectedRole = 'TECNICO';
  File? _selectedImage;
  String? selectedGenre;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _districtIdController = TextEditingController();
  final TextEditingController _specialtyIdController = TextEditingController();
  final TextEditingController _profileUrlController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genreController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
    _loadSpecialties();
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

  Future<void> _loadDepartments() async {

    final departments = await _informationService.getDepartments();

    setState(() {
      _departments = departments;
    });
  }

  Future<void> _loadDistrictsByDepartment(int departmentId) async {

    final districts = await _informationService
        .getDistrictsByDepartment(departmentId);

    setState(() {
      _districts = districts;
      _selectedDistrict = null;
    });
  }

  Future<void> _loadSpecialties() async {

    final specialties = await _informationService.getSpecialties();

    setState(() {
      _specialties = specialties;
    });
  }

  Future<void> _pickImage() async {

    final pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    color: Colors.white.withOpacity(0.95),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Registro de Usuario',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          DropdownButtonFormField<String>(
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
                            decoration: InputDecoration(
                              labelText: 'Rol',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),

                          _buildTextField(controller: _idController, label: 'DNI'),
                          _buildDropdownDepartment(),
                          _buildDropdownDistrictsByDepartment(),

                          if (selectedRole == 'TECNICO')
                            _buildDropdownSpecialties(),

                          _buildImagePicker(),

                          _buildTextField(controller: _firstnameController, label: 'Nombres'),
                          _buildTextField(controller: _lastnameController, label: 'Apellidos'),
                          _buildTextField(controller: _ageController, label: 'Edad', isNumber: true),

                          _buildDropdownGenre(),

                          _buildTextField(controller: _phoneController, label: 'Telefono', isNumber: true),
                          _buildTextField(controller: _emailController, label: 'Email'),
                          _buildTextField(controller: _codeController, label: 'Contraseña', isPassword: true),

                          const SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: () async {

                              String personId = _idController.text.toString();
                              String role = selectedRole;

                              bool result = false;

                              if (role == 'TECNICO') {

                                Technical technical = Technical(
                                  id: _idController.text,
                                  specialtyId: _selectedSpecialty!.id,
                                  districtId: _selectedDistrict!.id,
                                  firstname: _firstnameController.text,
                                  lastname: _lastnameController.text,
                                  age: int.parse(_ageController.text),
                                  genre: _genreController.text,
                                  phone: int.parse(_phoneController.text),
                                  email: _emailController.text,
                                  code: _codeController.text
                                );

                                result = await _registerService.registerTechnical
                                  (technical, _selectedImage!);
                              }
                              else if (role == 'CONSUMIDOR') {

                                Consumer consumer = Consumer(
                                    id: _idController.text,
                                    districtId: _selectedDistrict!.id,
                                    firstname: _firstnameController.text,
                                    lastname: _lastnameController.text,
                                    age: int.parse(_ageController.text),
                                    genre: _genreController.text,
                                    phone: int.parse(_phoneController.text),
                                    email: _emailController.text,
                                    code: _codeController.text
                                );

                                result = await _registerService.registerConsumer
                                  (consumer, _selectedImage!);
                              }

                              if (result == true) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AddMembership(
                                    personId: personId,
                                    role: role,
                                  ),
                                ).then((task) {
                                  if (task == true) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const Login()),
                                          (route) => false,
                                    );
                                  }
                                });
                              }
                              else {
                                showDialog(
                                  context: context,
                                  builder: (context) => const ErrorDialog
                                    (message: 'Error al registrarse.'),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Registrarse'),
                          ),
                        ],
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

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto de Perfil',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
                image: _selectedImage != null
                    ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                )
                    : null,
              ),
              child: _selectedImage == null
                  ? const Center(
                child: Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
              )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDropdownDepartment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<Department>(
        value: _selectedDepartment,
        decoration: InputDecoration(
          labelText: 'Departamento',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: _departments.map((dep) {
          return DropdownMenuItem(
            value: dep,
            child: Text(dep.name),
          );
        }).toList(),
        onChanged: (dep) {
          setState(() {
            _selectedDepartment = dep;
            _loadDistrictsByDepartment(dep!.id);
          });
        },
      ),
    );
  }
  Widget _buildDropdownDistrictsByDepartment() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<District>(
        value: _selectedDistrict,
        decoration: InputDecoration(
          labelText: 'Distrito',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        items: _districts.map((dist) {
          return DropdownMenuItem(
            value: dist,
            child: Text(dist.name),
          );
        }).toList(),
        onChanged: (dist) {
          setState(() {
            _selectedDistrict = dist;
          });
        },
      ),
    );
  }
  Widget _buildDropdownSpecialties() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<Specialty>(
        value: _selectedSpecialty,
        decoration: InputDecoration(
          labelText: 'Especialidad',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: _specialties.map((spe) {
          return DropdownMenuItem(
            value: spe,
            child: Text(spe.name),
          );
        }).toList(),
        onChanged: (spe) {
          setState(() {
            _selectedSpecialty = spe;
          });
        },
      ),
    );
  }
  Widget _buildDropdownGenre() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: selectedGenre,
        decoration: InputDecoration(
          labelText: 'Genero',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
          DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
        ],
        onChanged: (value) {
          setState(() {
            selectedGenre = value;
          });
        },
      ),
    );
  }
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isNumber = false,
    bool isPassword = false,
  }) {
    bool obscure = isPassword;

    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType:
            isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscure = !obscure;
                  });
                },
              )
                  : null,
            ),
          ),
        );
      },
    );
  }
}