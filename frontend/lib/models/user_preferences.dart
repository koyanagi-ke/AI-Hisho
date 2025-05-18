class UserPreferences {
  final String assistantCharacter;
  final String themeColor;
  final bool tutorialCompleted;

  UserPreferences({
    this.assistantCharacter = 'normal',
    this.themeColor = 'orange',
    this.tutorialCompleted = false,
  });

  UserPreferences copyWith({
    String? assistantCharacter,
    String? themeColor,
    bool? tutorialCompleted,
  }) {
    return UserPreferences(
      assistantCharacter: assistantCharacter ?? this.assistantCharacter,
      themeColor: themeColor ?? this.themeColor,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assistantCharacter': assistantCharacter,
      'themeColor': themeColor,
      'tutorialCompleted': tutorialCompleted,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      assistantCharacter: json['assistantCharacter'] ?? 'normal',
      themeColor: json['themeColor'] ?? 'orange',
      tutorialCompleted: json['tutorialCompleted'] ?? false,
    );
  }
}
