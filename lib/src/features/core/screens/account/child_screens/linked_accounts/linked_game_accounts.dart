import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:x_arena/src/common_widgets/loading.dart';
import 'package:x_arena/src/constants/image_strings.dart';
import 'package:x_arena/src/features/core/screens/account/child_screens/linked_accounts/widgets/pubg_data_form.dart';

class LinkedGameAccounts extends StatefulWidget {
  const LinkedGameAccounts({super.key});

  @override
  State<LinkedGameAccounts> createState() => _LinkedGameAccountsState();
}

class _LinkedGameAccountsState extends State<LinkedGameAccounts> {
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> pubgAccount = {};

    TextEditingController pubgNameController = TextEditingController();
    TextEditingController pubgIdController = TextEditingController();

    final userCollection = FirebaseFirestore.instance.collection('Users');
    User? user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'Linked Accounts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: StreamBuilder(
          stream: userCollection.doc(user?.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Loading();
            }
            final userSnapshot = snapshot.data?.data();
            if (userSnapshot!.containsKey('PUBG Account')) {
              pubgAccount = userSnapshot['PUBG Account'];
              pubgIdController.text = pubgAccount['PUBG ID'];
              pubgNameController.text = pubgAccount['PUBG Name'];
            }
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userSnapshot.containsKey('PUBG Account'))
                      InkWell(
                        onTap: () {
                          setState(() {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return PUBGDataForm(
                                  title: 'UPDATE PUBG ACCOUNT',
                                  pubgNameController: pubgNameController,
                                  pubgIdController: pubgIdController,
                                  userCollection: userCollection,
                                  buttonText: 'Update',
                                  completionMessage: 'Updated Successfully',
                                  userId: user?.uid,
                                );
                              },
                            );
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ColorFiltered(
                                    colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.4),
                                      BlendMode.srcOver,
                                    ),
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                          topLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Image.asset(
                                            pubgLogo,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Center(
                                      child: Text(
                                        'PUBG\nMOBILE',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'PUBG Name:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        pubgAccount['PUBG Name'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'PUBG ID:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        pubgAccount['PUBG ID'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            } else {
              return const Loading();
            }
          },
        ),
      ),
    );
  }
}
