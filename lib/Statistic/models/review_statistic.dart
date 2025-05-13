class ReviewStatistic {

  Map<int, int> scores;
  int averageScore;

  ReviewStatistic({
    required this.scores,
    required this.averageScore
  });

  factory ReviewStatistic.fromJson(Map<String, dynamic> json) {

    final int average = (json['AverageScore'] as num?)?.toInt() ?? 0;

    final Map<int, int> scoreMap = {};

    json.forEach((key, value) {
      if (key != 'AverageScore') {
        final intKey = int.tryParse(key);
        final intValue = (value as num?)?.toInt() ?? 0;
        if (intKey != null) {
          scoreMap[intKey] = intValue;
        }
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