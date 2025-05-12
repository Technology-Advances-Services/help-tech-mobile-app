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
  _AddMembership createState() => _AddMembership();
}

class _AddMembership extends State<AddMembership> {

  final MembershipService _membershipService = MembershipService();

  List<Membership> memberships = [];
  Membership? selectedMembership;

  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _policiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMemberships();
  }

  @override
  void dispose() {

    _nameController.dispose();
    _priceController.dispose();
    _policiesController.dispose();

    super.dispose();
  }


  Future<void> _loadMemberships() async {

    final tmpMemberships = await _membershipService.getMemberships();

    setState(() {
      memberships = tmpMemberships;
    });
  }

  void _onMembershipSelected(Membership? selected) {

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
              value: selectedMembership,
              items: memberships.map((m) {
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
              controller: _nameController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _priceController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _policiesController,
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
          onPressed: isLoading ? null : () async {

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
              Navigator.of(context).pop(true);
            }
            else {
              showDialog(
                context: context,
                builder: (context) => const ErrorDialog
                  (message: 'Error al registrar membresia.'),
              );
            }
          },
          child: isLoading
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