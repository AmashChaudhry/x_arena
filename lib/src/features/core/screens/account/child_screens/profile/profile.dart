import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_arena/src/common_widgets/loading.dart';
import 'package:x_arena/src/features/core/screens/account/child_screens/profile/email/user_email.dart';
import 'package:x_arena/src/features/core/screens/account/child_screens/profile/name/user_name.dart';
import 'package:x_arena/src/features/core/screens/account/child_screens/profile/password/user_password.dart';
import 'package:x_arena/src/features/core/screens/account/child_screens/profile/widgets/user_data_tile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isLoading = false;
  File? selectedImage;

  User? user = FirebaseAuth.instance.currentUser;
  final userCollection = FirebaseFirestore.instance.collection('Users');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          forceMaterialTransparency: true,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            'Profile',
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
        body: SingleChildScrollView(
          child: StreamBuilder(
            stream: userCollection.doc(user?.uid).snapshots(),
            builder: (context, snapshot) {
              final userSnapshot = snapshot.data?.data();
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          if (userSnapshot!.containsKey('Image'))
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      contentPadding: const EdgeInsets.all(0),
                                      titlePadding: const EdgeInsets.all(0),
                                      content: Image.network(userSnapshot['Image']),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.network(
                                    userSnapshot['Image'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          else
                            Container(
                              width: 120,
                              height: 120,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.person,
                                  size: 80,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          Positioned(
                            left: 5,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () async {
                                final image = await ImagePicker().pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  setState(() {
                                    selectedImage = File(image.path);
                                  });
                                }
                                final previousImage = FirebaseStorage.instance.ref().child('UserProfileImage/${user?.email}/');
                                final userStorageReference = FirebaseStorage.instance.ref().child('UserProfileImage/${user?.email}/${DateTime.now()}.jpg');
                                if (selectedImage != null) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  final previousData = await previousImage.listAll();
                                  for (final item in previousData.items) {
                                    await item.delete();
                                  }
                                  await userStorageReference.putFile(selectedImage!);
                                  final imageUrl = await userStorageReference.getDownloadURL();
                                  await userCollection.doc(user?.uid).update({'Image': imageUrl});
                                  setState(() {
                                    isLoading = false;
                                    selectedImage = null;
                                  });
                                }
                              },
                              child: Container(
                                height: 30,
                                width: 30,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: isLoading
                                    ? const Center(
                                        child: SizedBox(
                                          width: 10,
                                          height: 10,
                                          child: CircularProgressIndicator(
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.edit_rounded,
                                        size: 20,
                                        color: Colors.black,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      UserDataTile(
                        title: 'Name',
                        subtitle: userSnapshot['Full Name'],
                        icon: Icons.person_outline,
                        onTap: () {
                          Get.to(() => const UserName());
                        },
                      ),
                      UserDataTile(
                        title: 'Email',
                        subtitle: userSnapshot['Email'],
                        icon: Icons.email_outlined,
                        onTap: () {
                          Get.to(() => const UserEmail());
                        },
                      ),
                      UserDataTile(
                        title: 'Password',
                        subtitle: '********',
                        icon: Icons.lock_outline,
                        onTap: () {
                          Get.to(() => const UserPassword());
                        },
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
      ),
    );
  }
}
