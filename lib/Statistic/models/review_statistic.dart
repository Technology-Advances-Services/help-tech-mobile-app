class ReviewStatistic {

  Map<int, int> scores;
  int averageScore;

  ReviewStatistic({
    required this.scores,
    required this.averageScore
  });

  factory ReviewStatistic.fromJson(Map<String, dynamic> json) {
    int average = json['AverageScore'];
    Map<int, int> scoreMap = {};
    json.forEach((key, value) {
      if (key != 'AverageScore') {
        scoreMap[int.parse(key)] = value;
      }
    });
    return ReviewStatistic(scores: scoreMap, averageScore: average);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    scores.forEach((key, value) {
      data[key.toString()] = value;
    });
    data['AverageScore'] = averageScore;
    return data;
  }
}