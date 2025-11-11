import 'package:flutter/foundation.dart';

@immutable
class ComfortTip {
  const ComfortTip({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.focus,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final String focus;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
      'focus': focus,
    };
  }

  factory ComfortTip.fromJson(Map<String, dynamic> json) {
    return ComfortTip(
      id: json['id'] as String,
      titleKey: json['titleKey'] as String,
      descriptionKey: json['descriptionKey'] as String,
      focus: json['focus'] as String,
    );
  }
}
