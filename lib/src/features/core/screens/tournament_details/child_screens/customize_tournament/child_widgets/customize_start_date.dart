import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:x_arena/src/common_widgets/loading.dart';
import 'package:x_arena/src/constants/icon_strings.dart';
import 'package:x_arena/src/features/core/screens/account/child_screens/profile/widgets/message_box.dart';

class TournamentStartDate extends StatefulWidget {
  const TournamentStartDate({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  State<TournamentStartDate> createState() => _TournamentStartDateState();
}

class _TournamentStartDateState extends State<TournamentStartDate> {
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  DateTime? tournamentStartDate;

  final tournamentCollection = FirebaseFirestore.instance.collection('Tournaments');
  final userCollection = FirebaseFirestore.instance.collection('Users');
  User? user = FirebaseAuth.instance.currentUser;

  void dateTimePicker(Widget child) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Color(0xFF161616),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: child,
      ),
    );
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(vertical: 45, horizontal: 0),
        content: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void successMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const MessageBox(
          errorText: 'Successfully Updated',
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Start Date',
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
        stream: tournamentCollection.doc(widget.tournamentId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Update Tournament Start Date',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              dateTimePicker(
                                Theme(
                                  data: ThemeData.dark(),
                                  child: CupertinoDatePicker(
                                    initialDateTime: tournamentStartDate,
                                    use24hFormat: false,
                                    onDateTimeChanged: (DateTime newDateTime) {
                                      setState(() => tournamentStartDate = newDateTime);
                                    },
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    padding: const EdgeInsets.only(left: 10),
                                    color: Colors.green,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tournamentStartDate == null ? 'Select new date & time' : DateFormat('dd MMMM, yyyy | hh : mm a').format(tournamentStartDate!),
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          'Click here to select date & time',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    right: -5,
                                    bottom: 0,
                                    child: SvgPicture.asset(
                                      xIcon,
                                      height: 40,
                                      colorFilter: ColorFilter.mode(
                                        Colors.white.withOpacity(0.2),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      width: double.infinity,
                      child: isLoading
                          ? Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                      height: 10,
                                      child: CircularProgressIndicator(
                                        color: Colors.black,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Loading...',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () async {
                                if (tournamentStartDate == null) {
                                  errorMessage('Please select date & time');
                                } else {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  await tournamentCollection.doc(widget.tournamentId).update({'Start Date': tournamentStartDate});
                                  setState(() {
                                    isLoading = false;
                                  });
                                  Get.back();
                                  successMessage();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Loading();
          }
        },
      ),
    );
  }
}
