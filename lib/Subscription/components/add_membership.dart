import 'package:flutter/material.dart';
import 'package:helptechmobileapp/Subscription/services/membership_service.dart';

import '../../Shared/widgets/error_dialog.dart';
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
  _AddMembershipState createState() => _AddMembershipState();
}

class _AddMembershipState extends State<AddMembership> {

  final MembershipService _membershipService = MembershipService();

  List<Membership> memberships = [];
  Membership? selectedMembership;

  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _policiesController = TextEditingController();

  Future<void> submitMembership() async {

    setState(() {
      isLoading = true;
    });

    final result = await _membershipService.registerMembership(
      selectedMembership!, widget.personId, widget.role,
    );

    setState(() {
      isLoading = false;
    });

    if (result) {
      Navigator.of(context).pop(result);
    }
    else {
      showDialog(context: context, builder: (context) => const ErrorDialog
        (message: 'Error al registrar membresía.')
      );
    }
  }

  Future<void> loadMemberships() async {

    final tmpMemberships = await _membershipService.getMemberships();

    setState(() {
      memberships = tmpMemberships;
    });
  }

  void onMembershipSelected(Membership? selected) {

    if (selected != null) {
      setState(() {
        selectedMembership = selected;
        _nameController.text = selected.name;
        _priceController.text = selected.price.toStringAsFixed(2);
        _policiesController.text = selected.policies;
      });
    }
  }

  @override
  void dispose() {

    _nameController.dispose();
    _priceController.dispose();
    _policiesController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadMemberships();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Registrar membresía'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15)
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            DropdownButtonFormField<Membership>(
              value: selectedMembership,
              items: memberships.map((m) {
                return DropdownMenuItem(
                  value: m,
                  child: Text(m.name)
                );
              }).toList(),
              onChanged: onMembershipSelected,
              decoration: const InputDecoration(
                labelText: 'Selecciona una membresía',
                border: OutlineInputBorder()
              )
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _nameController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder()
              )
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _priceController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder()
              )
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _policiesController,
              readOnly: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Politicas',
                border: OutlineInputBorder()
              )
            )
          ]
        )
      ),
      actions: [
        ElevatedButton(
          onPressed: isLoading ? null : () async => submitMembership,
          child: isLoading ?
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
            )
          ) : const Text('Finalizar')
        )
      ]
    );
  }
}