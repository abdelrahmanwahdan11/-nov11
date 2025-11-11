class WellnessRecommendation {
  const WellnessRecommendation({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.tagKey,
    this.pinned = false,
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final String tagKey;
  final bool pinned;

  WellnessRecommendation copyWith({bool? pinned}) {
    return WellnessRecommendation(
      id: id,
      titleKey: titleKey,
      bodyKey: bodyKey,
      tagKey: tagKey,
      pinned: pinned ?? this.pinned,
    );
  }
}
