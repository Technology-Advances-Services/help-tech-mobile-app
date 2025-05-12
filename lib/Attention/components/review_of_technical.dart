import 'package:flutter/material.dart';
import 'package:helptechmobileapp/Attention/services/review_service.dart';
import 'package:helptechmobileapp/IAM/models/technical.dart';
import 'package:helptechmobileapp/Attention/models/review.dart';

class ReviewOfTechnical extends StatefulWidget {

  final Technical technical;

  const ReviewOfTechnical({super.key, required this.technical});

  @override
  _ReviewOfTechnical createState() => _ReviewOfTechnical();
}

class _ReviewOfTechnical extends State<ReviewOfTechnical> {

  final ReviewService _reviewService = ReviewService();

  List<Review> reviews = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final tmpReviews = await _reviewService.reviewsByTechnical(widget.technical.id);
    setState(() {
      reviews = tmpReviews;
      isLoading = false;
    });
  }

  Widget _buildStars(int score) {
    return Row(
      children: List.generate(5, (index) => Icon(
          index < score ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas del Técnico'),
        backgroundColor: Colors.blue.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reviews.isEmpty
          ? const Center(child: Text('Este técnico aún no tiene reseñas.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStars(review.score),
                        const SizedBox(height: 8),
                        Text(
                          review.opinion,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}