import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:x_arena/src/features/core/screens/account/child_screens/profile/widgets/message_box.dart';

class PUBGDataForm extends StatefulWidget {
  const PUBGDataForm({
    super.key,
    required this.title,
    required this.pubgNameController,
    required this.pubgIdController,
    required this.userCollection,
    required this.buttonText,
    required this.completionMessage,
    required this.userId,
  });

  final String title;
  final TextEditingController pubgNameController;
  final TextEditingController pubgIdController;
  final CollectionReference<Map<String, dynamic>> userCollection;
  final String buttonText;
  final String completionMessage;
  final String? userId;

  @override
  State<PUBGDataForm> createState() => _PUBGDataFormState();
}

class _PUBGDataFormState extends State<PUBGDataForm> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void successMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return MessageBox(
          errorText: widget.completionMessage,
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'We request you to accurately copy and paste your PUBG ID and Name from the game. Please be advised that providing incorrect PUBG ID and Name details may result in your disqualification from the tournament or removal from the match.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'PUBG Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: widget.pubgNameController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  isCollapsed: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 0.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 0.5,
                    ),
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'PUBG Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              const Text(
                'PUBG ID',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              TextFormField(
                controller: widget.pubgIdController,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  filled: true,
                  isCollapsed: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.5),
                      width: 0.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 0.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(
                      color: Colors.red,
                      width: 0.5,
                    ),
                  ),
                ),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'PUBG ID is required';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Cancel'),
        ),
        isLoading
            ? TextButton(
                onPressed: () {},
                child: const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    color: Colors.green,
                  ),
                ))
            : TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    Map<String, String> pubgAccount = {'PUBG Name': widget.pubgNameController.text, 'PUBG ID': widget.pubgIdController.text};
                    await widget.userCollection.doc(widget.userId).update({'PUBG Account': pubgAccount});
                    setState(() {
                      isLoading = false;
                    });
                    Get.back();
                    successMessage();
                  }
                },
                child: Text(widget.buttonText),
              ),
      ],
    );
  }
}
