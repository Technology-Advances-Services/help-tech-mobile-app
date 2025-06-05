import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/review.dart';
import '../services/review_service.dart';

class AddReview extends StatefulWidget {

  final String technicalId;

  const AddReview({super.key, required this.technicalId});

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {

  final _formKey = GlobalKey<FormState>();

  final ReviewService _reviewService = ReviewService();

  final _opinionController = TextEditingController();

  int selectedScore = 0;
  bool isLoading = false;

  Future<void> submitReview() async {

    if (!_formKey.currentState!.validate() ||
        selectedScore == 0 ||
        _opinionController.text.isEmpty) {

      Navigator.of(context).pop(false);

      return;
    }

    setState(() => isLoading = true);

    final review = Review(
      technicalId: widget.technicalId,
      score: selectedScore,
      opinion: _opinionController.text,
    );

    final result = await _reviewService.addReviewToJob(review);

    setState(() => isLoading = false);

    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _opinionController.dispose();
    super.dispose();
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
          title: const Text('Agregar Reseña'),
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
                          'Califica al técnico',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),

                        buildStarRating(),
                        const SizedBox(height: 24),

                        TextFormField(
                          controller: _opinionController,
                          maxLines: 5,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Escribe tu opinión...',
                            labelStyle: const TextStyle(color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide
                                (color: Colors.white.withOpacity(0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        isLoading ? const CircularProgressIndicator
                          (color: Colors.white) :
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.send),
                            label: const Text('Enviar Reseña'),
                            onPressed: submitReview,
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

  Widget buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedScore = index + 1;
            });
          },
          child: Icon(
            index < selectedScore ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 36,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(1, 1),
                blurRadius: 4,
              ),
            ],
          ),
        );
      }),
    );
  }
}