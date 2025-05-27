import 'dart:ui';

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
          title: const Text('Reseñas del Técnico'),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: isLoading ? const Center(child: CircularProgressIndicator
          (color: Colors.white)) :
        reviews.isEmpty ?
        const Center(
          child: Text(
            'Este técnico aún no tiene reseñas.',
            style: TextStyle(
              color: Colors.white,        // Color blanco
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ) :
        ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reviews.length,
          itemBuilder: (context, index) {

            final review = reviews[index];

            return ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white30,
                        child: Icon
                          (Icons.person, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildStars(review.score),
                            const SizedBox(height: 10),
                            Text(
                              review.opinion,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget buildStars(int score) {
    return Row(
      children: List.generate(5, (index) => Icon(
          index < score ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        ),
      ),
    );
  }
}