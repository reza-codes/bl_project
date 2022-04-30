class ContactModel {
  String id;
  String contactName;
  String phoneNumber;

  ContactModel({
    required this.id,
    required this.contactName,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'contactName': contactName,
        'phoneNumber': phoneNumber,
      };

  ContactModel fromJson(Map<String, dynamic> json) => ContactModel(
        id: json['id'],
        contactName: json['contactName'],
        phoneNumber: json['phoneNumber'],
      );
}
