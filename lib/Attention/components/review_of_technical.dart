import 'package:flutter/material.dart';

import '../../IAM/models/technical.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class ReviewOfTechnical extends StatefulWidget {

  final Technical technical;

  const ReviewOfTechnical({super.key, required this.technical});

  @override
  _ReviewOfTechnicalState createState() => _ReviewOfTechnicalState();
}

class _ReviewOfTechnicalState extends State<ReviewOfTechnical> {

  final ReviewService _reviewService = ReviewService();

  List<Review> reviews = [];
  bool isLoading = true;

  Future<void> loadReviews() async {

    final tmpReviews = await _reviewService
        .reviewsByTechnical(widget.technical.id);

    setState(() {
      reviews = tmpReviews;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas del Técnico'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator()) :
      reviews.isEmpty ? const Center(
          child: Text('Este técnico aún no tiene reseñas.')) :
      ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {

          final review = reviews[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.blueGrey,
                    child: Icon(Icons.person, size: 30, color: Colors.white)
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildStars(review.score),
                        const SizedBox(height: 8),
                        Text(
                          review.opinion,
                          style: const TextStyle(fontSize: 16)
                        )
                      ]
                    )
                  )
                ]
              )
            )
          );
        }
      )
    );
  }

  Widget buildStars(int score) {
    return Row(
      children: List.generate(5, (index) => Icon(
        index < score ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 20)
      )
    );
  }
}