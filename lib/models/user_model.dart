class User {
  String id;
  final String name;
  final String email;
  List<Map<String, dynamic>>? erContacts;
  List<Map<String, dynamic>>? fallsHistory;

  User({
    this.id = '',
    required this.name,
    required this.email,
    required this.erContacts,
    required this.fallsHistory,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'erContact': erContacts,
        'fallsHistory': fallsHistory,
      };

  User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        erContacts: json['erContacts'],
        fallsHistory: json['fallsHistory'],
      );
}
