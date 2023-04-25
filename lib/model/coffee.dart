class Coffee {
  String coffeeId;
  String title;
  String description;

  Coffee({this.coffeeId = '', required this.title, required this.description});

  factory Coffee.fromJson(Map<String, dynamic> json) {
    return Coffee(title: json['title'], description: json['description']);
  }

  Map<String, Object?> toJson() {
    return {'title': title, 'description': description};
  }
}
