import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';

import '../models/contact_model.dart';
import '../models/fall_detect_model.dart';
import '../models/user_model.dart';

class FirestoreRepository {
  static List<FallDetectModel> fallDetectList = [];
  static List<ContactModel> erContactList = [];
  static fb.User? user = fb.FirebaseAuth.instance.currentUser;

  // add new fall detection
  static addFallDetected() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    List<Map> list = [];

    for (var element in fallDetectList) {
      Map contact = element.toJson();
      list.add(contact);
    }

    docUser.update({'fallsHistory': FieldValue.arrayUnion(list)});
  }

  // get fall detections
  static Stream<List<FallDetectModel>> readFallDectected() {
    try {
      return FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots().map((snapshot) {
        fallDetectList.clear();
        Map<String, dynamic>? data = snapshot.data();

        for (var data in data!['fallsHistory']) {
          fallDetectList.add(FallDetectModel(
            id: data['id'],
            latitude: data['latitude'],
            longitude: data['longitude'],
            dataTime: DateTime.parse(data['dataTime'].toDate().toString()),
          ));
        }

        if (kDebugMode) {
          print(fallDetectList);
        }

        return fallDetectList;
      });
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
      }
      if (kDebugMode) {
        print(s);
      }
      rethrow;
    }
  }

  // get er contacts
  static Stream<List<ContactModel>> readErContacts() =>
      FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots().map((snapshot) {
        erContactList.clear();
        Map<String, dynamic>? data = snapshot.data();

        for (var data in data!['erContact']) {
          erContactList.add(ContactModel(
            id: data['id'],
            phoneNumber: data['phoneNumber'],
            contactName: data['contactName'],
          ));
        }
        if (kDebugMode) {
          print(erContactList);
        }

        return erContactList;
      });

  static Future<List<ContactModel>> readErContactsOnce() => readErContacts().first;

  // add new er contact
  static removeErContact(ContactModel contact) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    erContactList.remove(contact);

    List<Map> list = [];

    for (var element in erContactList) {
      Map json = element.toJson();
      list.add(json);
    }

    docUser.update({'erContact': FieldValue.delete()});
    docUser.update({'erContact': FieldValue.arrayUnion(list)});
  }

  // add new er contact
  static updateErContact(ContactModel contact) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    List<Map> list = [];

    for (var element in erContactList) {
      if (contact.id == element.id) {
        element.contactName = contact.contactName;
        element.phoneNumber = contact.phoneNumber;
      }
      Map json = element.toJson();
      list.add(json);
    }

    docUser.update({'erContact': FieldValue.delete()});
    docUser.update({'erContact': FieldValue.arrayUnion(list)});
  }

  // add new er contact
  static addErContact() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    List<Map> list = [];

    for (var element in erContactList) {
      Map json = element.toJson();
      list.add(json);
    }

    docUser.update({'erContact': FieldValue.arrayUnion(list)});
  }

  // creat a new user
  static createUser() async {
    final docUser = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    final User newUser = User(
      id: user!.uid,
      name: user!.displayName!,
      email: user!.email!,
      erContacts: null,
      fallsHistory: null,
    );

    final json = newUser.toJson();

    //Stream <List<Fb.User>> data = FirebaseFirestore.instance.collection('users').snapshots().map((snapshot) => snapshot.);
    QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance.collection('users').get();

    bool isUserExist = data.docs.any((document) {
      if (document.id == user!.uid) return true;
      return false;
    });

    if (isUserExist) {
      if (kDebugMode) {
        print("User found! ID => " + user!.uid);
      }
    } else {
      if (kDebugMode) {
        print("A new user created! ID => " + user!.uid);
      }
      await docUser.set(json);
    }
  }
}
