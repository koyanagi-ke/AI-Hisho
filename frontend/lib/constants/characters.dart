class Character {
  final String id;
  final String name;
  final String imagePath;

  const Character({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}

class CharactersList {
  static const List<Character> all = [
    Character(
      id: 'normal',
      name: 'ノーマル',
      imagePath: 'assets/images/characters/normal.png',
    ),
    Character(
      id: 'robot',
      name: 'マシン',
      imagePath: 'assets/images/characters/robot.png',
    ),
    Character(
      id: 'boy',
      name: 'ボーイ',
      imagePath: 'assets/images/characters/boy.png',
    ),
    Character(
      id: 'girl',
      name: 'ガール',
      imagePath: 'assets/images/characters/girl.png',
    ),
  ];

  static Character getById(String id) {
    return all.firstWhere(
      (character) => character.id == id,
      orElse: () => all.first,
    );
  }
}
