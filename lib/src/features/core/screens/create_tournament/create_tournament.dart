import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:x_arena/src/constants/icon_strings.dart';
import 'package:x_arena/src/features/core/screens/account/child_screens/profile/widgets/message_box.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/tournament_details.dart';

List<String> tournamentMode = ['Solo', 'Duo', 'Squad'];
List<String> tournamentMap = ['Erangel', 'Livik', 'Miramar', 'Sanhok', 'Vikendi', 'Karakin', 'Nusa'];

class CreateTournament extends StatefulWidget {
  const CreateTournament({super.key});

  @override
  State<CreateTournament> createState() => _CreateTournamentState();
}

class _CreateTournamentState extends State<CreateTournament> {
  String tournamentModeDropdownValue = tournamentMode.last;
  String tournamentMapDropdownValue = tournamentMap.first;
  Color switchedContentColor = Colors.transparent;
  double switchedContentPadding = 0;
  DateTime startDate = DateTime.now();
  bool prizePoolSwitch = false;
  bool entryFeeSwitch = false;
  bool isLoading = false;
  List<Widget> textFields = [];
  List<String> participants = [];
  List<int> prizes = [0];
  int prizeCounter = 1;
  File? selectedImage;
  DateTime endDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day + 1,
    12,
  );

  String getOrdinalIndicator(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  TextEditingController tournamentNameController = TextEditingController();
  TextEditingController maximumPlayersController = TextEditingController();
  TextEditingController entryFeeController = TextEditingController();
  List<TextEditingController> prizeControllers = [];
  TextEditingController tournamentRulesController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  final tournamentCollection = FirebaseFirestore.instance.collection('Tournaments');
  final tournamentStorageReference = FirebaseStorage.instance.ref().child('TournamentPosters/${DateTime.now()}.jpg');

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

  void createAnotherWinner() {
    prizeControllers.add(TextEditingController());
    setState(() {
      textFields.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Text(
              '$prizeCounter${getOrdinalIndicator(prizeCounter)} Prize*',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 5),
            TextFormField(
              controller: prizeControllers.last,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                filled: true,
                isCollapsed: true,
                fillColor: Colors.black.withOpacity(0.4),
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
                  return 'Prize amount is required';
                }
                return null;
              },
            ),
          ],
        ),
      );
      prizeCounter++;
    });
  }

  void resetForm() {
    tournamentNameController.clear();
    setState(() {
      selectedImage = null;
      tournamentModeDropdownValue = tournamentMode.last;
      tournamentMapDropdownValue = tournamentMap.first;
    });
    maximumPlayersController.clear();
    entryFeeController.clear();
    for (var controller in prizeControllers) {
      controller.clear();
    }
    textFields.clear();
    prizeCounter = 1;
    tournamentRulesController.clear();
    prizePoolSwitch = false;
    entryFeeSwitch = false;
    switchedContentColor = Colors.transparent;
    switchedContentPadding = 0;
  }

  void successMessage() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const MessageBox(
          errorText: 'Tournament Created Successfully',
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
        );
      },
    );
  }

  void pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            'Create Tournament',
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
          child: Form(
            key: formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            pickImage();
                          },
                          child: LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints) {
                              double containerWidth = constraints.maxWidth;
                              double containerHeight = constraints.maxWidth / 1.8;
                              return Container(
                                width: containerWidth,
                                height: containerHeight,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    width: 0.1,
                                    color: Colors.white,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: selectedImage != null
                                      ? Image.file(
                                          selectedImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              uploadIcon,
                                              width: 40,
                                              colorFilter: const ColorFilter.mode(
                                                Colors.white,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                            const Text(
                                              'Upload Image',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Tournament Name*',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: tournamentNameController,
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
                            return 'Tournament name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Tournament Mode',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      PopupMenuButton(
                        elevation: 0,
                        color: const Color(0xFF161616),
                        offset: const Offset(0, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.white,
                              width: 0.1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tournamentModeDropdownValue,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
                        onSelected: (String? value) {
                          setState(() {
                            tournamentModeDropdownValue = value!;
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return tournamentMode.map<PopupMenuItem<String>>((String value) {
                            return PopupMenuItem(
                              value: value,
                              child: SizedBox(
                                width: 200,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList();
                        },
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Tournament Map',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      PopupMenuButton(
                        elevation: 0,
                        color: const Color(0xFF161616),
                        offset: const Offset(0, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.white,
                              width: 0.1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  tournamentMapDropdownValue,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
                        onSelected: (String? value) {
                          setState(() {
                            tournamentMapDropdownValue = value!;
                          });
                        },
                        itemBuilder: (BuildContext context) {
                          return tournamentMap.map<PopupMenuItem<String>>((String value) {
                            return PopupMenuItem(
                              value: value,
                              child: SizedBox(
                                width: 200,
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList();
                        },
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Maximum Players*',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: maximumPlayersController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                            return 'Maximum players for registration is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Tournament Registration',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'End Date*',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      GestureDetector(
                        onTap: () {
                          dateTimePicker(
                            Theme(
                              data: ThemeData.dark(),
                              child: CupertinoDatePicker(
                                initialDateTime: endDate,
                                use24hFormat: false,
                                onDateTimeChanged: (DateTime newDateTime) {
                                  setState(() => endDate = newDateTime);
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.white,
                              width: 0.1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  DateFormat('dd MMMM, yyyy | hh : mm a').format(endDate),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.access_time,
                                color: Colors.green,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: switchedContentColor,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: switchedContentPadding, left: 15, right: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Text(
                                    'Prizes ',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  Text(
                                    '(Enter prizes for winners)',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: prizePoolSwitch,
                                inactiveThumbColor: Colors.white,
                                activeTrackColor: Colors.green,
                                inactiveTrackColor: Colors.white.withOpacity(0.1),
                                trackOutlineColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.transparent;
                                  }
                                  return Colors.transparent;
                                }),
                                onChanged: (value) {
                                  setState(() {
                                    prizePoolSwitch = value;
                                    switchedContentColor = Colors.white.withOpacity(0.1);
                                    switchedContentPadding = 15;
                                    createAnotherWinner();
                                    if (!value) {
                                      prizeCounter = 1;
                                      textFields.clear();
                                      prizeControllers.clear();
                                      prizes.clear();
                                      entryFeeSwitch = false;
                                      entryFeeController.text = '';
                                      switchedContentColor = Colors.transparent;
                                      switchedContentPadding = 0;
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: prizePoolSwitch,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Tournament Entry Fee',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: Switch(
                                          value: entryFeeSwitch,
                                          inactiveThumbColor: Colors.white,
                                          activeTrackColor: Colors.green,
                                          inactiveTrackColor: Colors.white.withOpacity(0.1),
                                          trackOutlineColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                            if (states.contains(MaterialState.disabled)) {
                                              return Colors.transparent;
                                            }
                                            return Colors.transparent;
                                          }),
                                          onChanged: (value) {
                                            setState(() {
                                              entryFeeSwitch = value;
                                              if (!value) {
                                                entryFeeController.text = '';
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Visibility(
                                    visible: entryFeeSwitch,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Entry Fee*',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        TextFormField(
                                          controller: entryFeeController,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          decoration: InputDecoration(
                                            filled: true,
                                            isCollapsed: true,
                                            fillColor: Colors.black.withOpacity(0.4),
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
                                              return 'Entry fee is required';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        Divider(color: Colors.black.withOpacity(0.4)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: textFields.map((textField) => textField).toList(),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            GestureDetector(
                              onTap: () {
                                createAnotherWinner();
                              },
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 20,
                                      width: 20,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.add,
                                          size: 15,
                                          color: Colors.black.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Add Another Winner',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tournament Rules*',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: tournamentRulesController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        maxLines: 4,
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
                            return 'Please enter tournament rules';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
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
                                  if (formKey.currentState!.validate()) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    prizes.clear();
                                    for (var prizeController in prizeControllers) {
                                      final prizeValue = prizeController.text;
                                      if (prizeValue.isNotEmpty) {
                                        prizes.add(int.parse(prizeValue));
                                      }
                                    }
                                    if (selectedImage != null) {
                                      await tournamentStorageReference.putFile(selectedImage!);
                                      final imageUrl = await tournamentStorageReference.getDownloadURL();
                                      final tournamentData = {
                                        'Tournament Name': tournamentNameController.text,
                                        'Tournament Mode': tournamentModeDropdownValue,
                                        'Map': tournamentMapDropdownValue,
                                        'Maximum Players': maximumPlayersController.text,
                                        'End Date': endDate,
                                        'Entry Fee': entryFeeSwitch ? int.parse(entryFeeController.text) : 'Free Entry',
                                        'Prizes': prizes,
                                        'Rules': tournamentRulesController.text,
                                        'Participants': participants,
                                        'Created by': user?.uid,
                                        'Image': imageUrl,
                                      };
                                      final doc = await tournamentCollection.add(tournamentData);
                                      final documentId = doc.id;
                                      resetForm();
                                      setState(() {
                                        isLoading = false;
                                      });
                                      successMessage();
                                      await Future.delayed(const Duration(seconds: 3));
                                      Get.back();
                                      Get.to(() => TournamentDetails(tournamentId: documentId));
                                    } else {
                                      final tournamentData = {
                                        'Tournament Name': tournamentNameController.text,
                                        'Tournament Mode': tournamentModeDropdownValue,
                                        'Map': tournamentMapDropdownValue,
                                        'Maximum Players': maximumPlayersController.text,
                                        'End Date': endDate,
                                        'Entry Fee': entryFeeSwitch ? int.parse(entryFeeController.text) : 'Free Entry',
                                        'Prizes': prizes,
                                        'Rules': tournamentRulesController.text,
                                        'Participants': participants,
                                        'Created by': user?.uid,
                                      };
                                      final doc = await tournamentCollection.add(tournamentData);
                                      final documentId = doc.id;
                                      resetForm();
                                      setState(() {
                                        isLoading = false;
                                      });
                                      successMessage();
                                      await Future.delayed(const Duration(seconds: 3));
                                      Get.back();
                                      Get.to(() => TournamentDetails(tournamentId: documentId));
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: const Text(
                                  'Create Tournament',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
