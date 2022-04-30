import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/contact_model.dart';
import '../repositories/firestore_repository.dart';

class ContactFormsWidget extends StatefulWidget {
  final ContactModel? contact;

  const ContactFormsWidget({this.contact, Key? key}) : super(key: key);

  @override
  State<ContactFormsWidget> createState() => _ContactFormsWidgetState();
}

class _ContactFormsWidgetState extends State<ContactFormsWidget> {
  final _formKey = GlobalKey<FormState>();

  late FocusNode focusNodeName;
  late FocusNode focusNodePhoneNumber;

  late TextEditingController nameController;
  late TextEditingController phoneNumberController;

  bool shwoPrefix = false;
  bool allowEdit = false;

  void updataContact() {
    if (_formKey.currentState!.validate()) {
      if (kDebugMode) {
        print(nameController.text);
      }
      if (kDebugMode) {
        print(phoneNumberController.text);
      }

      widget.contact!.contactName = nameController.text;
      widget.contact!.phoneNumber = phoneNumberController.text;

      FirestoreRepository.erContactList.add(widget.contact!);
      FirestoreRepository.updateErContact(widget.contact!);

      nameController.text = "";
      phoneNumberController.text = "";

      Navigator.pop(context);
    }
  }

  void addContact() {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.

      // Retrieve the text the user has entered by using the
      // TextEditingController.

      if (kDebugMode) {
        print(nameController.text);
      }
      if (kDebugMode) {
        print(phoneNumberController.text);
      }

      ContactModel contact = ContactModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        contactName: nameController.text,
        phoneNumber: phoneNumberController.text,
      );

      if (FirestoreRepository.erContactList.length < 5) {
        FirestoreRepository.erContactList.add(contact);
        FirestoreRepository.addErContact();
      } else {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('AlertDialog'),
            content: const Text('You cannot add more contacts'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }

      shwoPrefix = false;
      nameController.text = "";
      phoneNumberController.text = "";

      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    FirestoreRepository.readErContacts();

    focusNodeName = FocusNode();
    focusNodePhoneNumber = FocusNode();

    nameController = TextEditingController();
    phoneNumberController = TextEditingController();

    if (widget.contact != null) {
      nameController.text = widget.contact!.contactName;
      phoneNumberController.text = widget.contact!.phoneNumber;
    }
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    focusNodeName.dispose();
    focusNodePhoneNumber.dispose();
    nameController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(
                  onPressed: () {
                    shwoPrefix = false;
                    nameController.text = "";
                    phoneNumberController.text = "";
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 18),
                  )),
              Text(
                widget.contact == null ? 'Add contact' : 'Edit contact',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              TextButton(
                  onPressed: widget.contact == null ? addContact : updataContact,
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.grey.shade800, fontSize: 18),
                  ))
            ],
          ),
          const Divider(indent: 15, endIndent: 15, thickness: 1.5),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      focusNode: focusNodeName,
                      maxLength: 50,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                      onTap: () {
                        if (phoneNumberController.text == "") {
                          setState(() {
                            shwoPrefix = false;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                        counterText: "", // will hide the maxLenght counter
                        hintText: "Enter name",
                        hintStyle: TextStyle(color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name!';
                        }
                        // TODO: add more validators
                        // if (isAlphanumeric(value) == false && isAscii(value) == false) {
                        //   return 'Please enter a valid name!';
                        // }
                        return null;
                      },
                    ),
                    const SizedBox(height: 17),
                    TextFormField(
                      controller: phoneNumberController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      focusNode: focusNodePhoneNumber,
                      maxLength: 10,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                      ),
                      onChanged: (text) {
                        if (text == "") {
                          setState(() {
                            shwoPrefix = true;
                          });
                        }
                      },
                      onTap: () {
                        setState(() {
                          shwoPrefix = true;
                        });
                      },
                      decoration: InputDecoration(
                        counterText: "", // will hide the maxLenght counter
                        hintText: "Enter phone #",
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixText: shwoPrefix ? "+1-" : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: BorderSide(
                            color: Colors.grey,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10.0),
                          ),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone #!';
                        }
                        // TODO: add more validators
                        // if (isAlphanumeric(value) == false && isAscii(value) == false) {
                        //   return 'Please enter a valid name!';
                        // }
                        return null;
                      },
                    ),
                    const SizedBox(height: 17),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
