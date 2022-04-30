import 'package:flutter/material.dart';

import '../models/contact_model.dart';

class ContactsProvider with ChangeNotifier {
  List<ContactModel> contactsList = [];

  addContact(ContactModel contact) {
    contactsList.add(contact);

    notifyListeners();
  }

  removeContact(ContactModel contact) {
    contactsList.remove(contact);

    notifyListeners();
  }

  updateContact(ContactModel contact) {
    for (var element in contactsList) {
      if (contact.id == element.id) {
        element.contactName = contact.contactName;
        element.phoneNumber = contact.phoneNumber;
      }
    }

    notifyListeners();
  }
}
