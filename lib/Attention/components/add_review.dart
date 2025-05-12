import 'package:flutter/material.dart';
import 'package:helptechmobileapp/Attention/models/review.dart';
import 'package:helptechmobileapp/Attention/services/review_service.dart';

class AddReview extends StatefulWidget {

  final String technicalId;

  const AddReview({super.key, required this.technicalId});

  @override
  _AddReview createState() => _AddReview();
}

class _AddReview extends State<AddReview> {

  final _formKey = GlobalKey<FormState>();
  final ReviewService _reviewService = ReviewService();

  final _opinionController = TextEditingController();
  int selectedScore = 0;
  bool isLoading = false;

  Future<void> _submitReview() async {

    if (!_formKey.currentState!.validate() || selectedScore == 0) {

      Navigator.of(context).pop(false);
    }

    setState(() => isLoading = true);

    final review = Review(
      technicalId: widget.technicalId,
      score: selectedScore,
      opinion: _opinionController.text.trim(),
    );

    final result = await _reviewService.addReviewToJob(review);

    setState(() => isLoading = false);

    Navigator.of(context).pop(result);
  }

  Widget buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < selectedScore ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 32,
          ),
          onPressed: () {
            setState(() {
              selectedScore = index + 1;
            });
          },
        );
      }),
    );
  }

  @override
  void dispose() {
    _opinionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Reseña'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Califica al técnico',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              buildStarRating(),
              const SizedBox(height: 24),
              TextFormField(
                controller: _opinionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Escribe tu opinión',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La opinión es obligatoria.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Enviar Reseña'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _submitReview,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}