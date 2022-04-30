import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contact_model.dart';
import '../providers/contacts_provider.dart';
import '../repositories/firestore_repository.dart';
import '../widgets/contacts_form_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin<ProfilePage> {
  @override
  bool get wantKeepAlive => true;
  User? user;

  bool allowEdit = false;

  void contactBottomSheet(ContactModel? contact) {
    showModalBottomSheet<void>(
      context: context,
      //useRootNavigator: true,
      enableDrag: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
          ),
          child: ContactFormsWidget(contact: contact),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    FirestoreRepository.readErContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
        centerTitle: true,
      ),
      // bottomNavigationBar: Container(height: 300),
      body: user == null
          ? const Center(
              child: Text("Please sign in!"),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                CircleAvatar(
                  radius: 70,
                  backgroundImage: NetworkImage(user!.photoURL!),
                ),
                const SizedBox(height: 20),
                Text(
                  "Welcome: " + user!.displayName!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Email: " + user!.email!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Divider(endIndent: 20, indent: 20, thickness: 1.5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (allowEdit) {
                            allowEdit = false;
                          } else {
                            allowEdit = true;
                          }
                        });
                      },
                      icon: Icon(
                        allowEdit ? Icons.check_circle : Icons.edit_note,
                        size: 32,
                      ),
                      label: Text(allowEdit ? "Done" : "Edit contacts"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        shape: const StadiumBorder(),
                      ),
                    ),
                    if (!allowEdit)
                      ElevatedButton.icon(
                        onPressed: () => contactBottomSheet(null),
                        icon: const Icon(
                          Icons.add_circle,
                          size: 32,
                        ),
                        label: const Text("Add contact"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          shape: const StadiumBorder(),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirestoreRepository.readErContacts(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasData) {
                        List<ContactModel> contacts = snapshot.data;

                        if (contacts.isEmpty) {
                          return const Center(
                            child: Text(
                              "Please add contacts",
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                            separatorBuilder: (context, index) {
                              return const Divider(
                                indent: 15,
                                endIndent: 15,
                                thickness: 1.3,
                              );
                            },
                            itemCount: contacts.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person, size: 40),
                                ),
                                title: Text(contacts[index].contactName),
                                subtitle: Text("+1- " + contacts[index].phoneNumber),
                                trailing: allowEdit
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {
                                              contactBottomSheet(contacts[index]);
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.green.shade400,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                FirestoreRepository.removeErContact(contacts[index]),
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red.shade400,
                                            ),
                                          ),
                                        ],
                                      )
                                    : null,
                              );
                            });
                      } else {
                        return const Center(
                          child: Text(
                            "Please add contacts",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  // Consumer<ContactsProvider>(
                  //   builder: (context, contactsProvider, _) {
                  //     if (contactsProvider.contactsList.isEmpty) {
                  //       return Center(
                  //         child: Text(
                  //           "Please add contacts",
                  //           style: TextStyle(
                  //             fontSize: 22,
                  //             color: Colors.grey,
                  //           ),
                  //         ),
                  //       );
                  //     }
                  //     return ListView.separated(
                  //         separatorBuilder: (context, index) {
                  //           return Divider(
                  //             indent: 15,
                  //             endIndent: 15,
                  //             thickness: 1.3,
                  //           );
                  //         },
                  //         itemCount: contactsProvider.contactsList.length,
                  //         shrinkWrap: true,
                  //         itemBuilder: (context, index) {
                  //           return ListTile(
                  //             leading: CircleAvatar(
                  //               child: Icon(Icons.person, size: 40),
                  //             ),
                  //             title: Text(contactsProvider.contactsList[index].contactName),
                  //             subtitle: Text("+1- " + contactsProvider.contactsList[index].phoneNumber),
                  //             trailing: allowEdit
                  //                 ? Row(
                  //                     mainAxisSize: MainAxisSize.min,
                  //                     children: [
                  //                       IconButton(
                  //                         onPressed: () {
                  //                           editContactBottomSheet(contactsProvider.contactsList[index]);
                  //                         },
                  //                         icon: Icon(
                  //                           Icons.edit,
                  //                           color: Colors.green.shade400,
                  //                         ),
                  //                       ),
                  //                       IconButton(
                  //                         onPressed: () {
                  //                           contactsProvider
                  //                               .removeContact(contactsProvider.contactsList[index]);
                  //                         },
                  //                         icon: Icon(
                  //                           Icons.delete,
                  //                           color: Colors.red.shade400,
                  //                         ),
                  //                       ),
                  //                     ],
                  //                   )
                  //                 : null,
                  //           );
                  //         });
                  //   },
                  // ),
                ),
              ],
            ),
    );
  }
}
