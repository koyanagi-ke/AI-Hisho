class UserPreferences {
  final List<String> priorityItems;
  final String assistantCharacter;
  final String themeColor;
  final bool tutorialCompleted;

  UserPreferences({
    this.priorityItems = const [],
    this.assistantCharacter = 'card',
    this.themeColor = 'orange',
    this.tutorialCompleted = false,
  });

  UserPreferences copyWith({
    List<String>? priorityItems,
    String? assistantCharacter,
    String? themeColor,
    bool? tutorialCompleted,
  }) {
    return UserPreferences(
      priorityItems: priorityItems ?? this.priorityItems,
      assistantCharacter: assistantCharacter ?? this.assistantCharacter,
      themeColor: themeColor ?? this.themeColor,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priorityItems': priorityItems,
      'assistantCharacter': assistantCharacter,
      'themeColor': themeColor,
      'tutorialCompleted': tutorialCompleted,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      priorityItems: List<String>.from(json['priorityItems'] ?? []),
      assistantCharacter: json['assistantCharacter'] ?? 'card',
      themeColor: json['themeColor'] ?? 'orange',
      tutorialCompleted: json['tutorialCompleted'] ?? false,
    );
  }
}
