import 'dart:ui';

import 'package:flutter/material.dart';

import '../../Shared/widgets/success_dialog.dart';
import '../models/qr_technical.dart';
import '../services/qr_technical_service.dart';
import 'add_qr_technical.dart';

class PaymentPage extends StatefulWidget {

  const PaymentPage({super.key});

  @override
  _PaymentPage createState() => _PaymentPage();
}

class _PaymentPage extends State<PaymentPage> {

  final QrTechnicalService _qrTechnicalService = QrTechnicalService();

  List<QrTechnical> allQrTechnical = [];
  bool isLoading = true;

  Future<void> loadQrTechnical() async {

    setState(() => isLoading = true);

    allQrTechnical = await _qrTechnicalService.qrByTechnical();

    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    loadQrTechnical();
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
          title: const Text('Pagos con Yape'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/payment/yape_logo.png',
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Expanded(
              child: isLoading ?
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ) : allQrTechnical.isEmpty ?
              const Center(
                child: Text(
                  "Aún no tienes un QR registrado.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ) :
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              allQrTechnical.first.qrUrl,
                              width: 250,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "QR ID: ${allQrTechnical.first.id}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            allQrTechnical.first.state,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(context, MaterialPageRoute(
                builder: (context) => const AddQrTechnical()
            ));

            if (result == true) {

              showDialog(context: context, builder: (context) =>
              const SuccessDialog(message: 'QR registrado.'));

              loadQrTechnical();
            }
          },
          backgroundColor: Colors.tealAccent.shade700,
          child: const Icon(Icons.add, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}