import 'package:flutter/material.dart';
import 'package:helptechmobileapp/IAM/services/register_service.dart';

import '../../Information/services/information_service.dart';
import '../models/membership.dart';

class AddMembership extends StatefulWidget {

  final String personId;
  final String role;

  const AddMembership({
    super.key,
    required this.personId,
    required this.role,
  });

  @override
  _AddMembership createState() => _AddMembership();
}

class _AddMembership extends State<AddMembership> {

  late String personId;
  late String role;

  final InformationService _informationService = InformationService();
  final RegisterService _registerService = RegisterService();

  List<Membership> _memberships = [];
  Membership? _selectedMembership;

  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController policiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  @override
  void dispose() {

    nameController.dispose();
    priceController.dispose();
    policiesController.dispose();

    super.dispose();
  }


  Future<void> _loadMemberships() async {

    final memberships = await _informationService.getMemberships();

    setState(() {
      personId = widget.personId;
      role = widget.role;
      _memberships = memberships;
    });
  }

  void _onMembershipSelected(Membership? selected) {

    if (selected != null) {
      setState(() {
        _selectedMembership = selected;
        nameController.text = selected.name;
        priceController.text = selected.price.toStringAsFixed(2);
        policiesController.text = selected.policies;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar membresia'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Membership>(
              value: _selectedMembership,
              items: _memberships.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m.name),
                );
              }).toList(),
              onChanged: _onMembershipSelected,
              decoration: const InputDecoration(
                labelText: 'Selecciona una membresia',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: nameController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: priceController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: policiesController,
              readOnly: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Politicas',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading
              ? null
              : () async {
            setState(() {
              _isLoading = true;
            });

            final result = await _registerService.registerMembership(
              _selectedMembership!, personId, role,
            );

            setState(() {
              _isLoading = false;
            });

            if (result) {
              Navigator.of(context).pop(true);
            }
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error al registrar la membresia')),
              );
            }
          },
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('Finalizar'),
        )
      ],
    );
  }
}