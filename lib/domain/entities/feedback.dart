class Feedback {
  final String feedbackId;
  final String slotId;
  final String userId;
  final String content;
  final int? rating;
  final DateTime createdAt;

  const Feedback({
    required this.feedbackId,
    required this.slotId,
    required this.userId,
    required this.content,
    this.rating,
    required this.createdAt,
  });

  Feedback copyWith({
    String? feedbackId,
    String? slotId,
    String? userId,
    String? content,
    int? rating,
    DateTime? createdAt,
  }) {
    return Feedback(
      feedbackId: feedbackId ?? this.feedbackId,
      slotId: slotId ?? this.slotId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
