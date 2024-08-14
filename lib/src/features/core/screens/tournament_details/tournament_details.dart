import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:x_arena/src/common_widgets/loading.dart';
import 'package:x_arena/src/constants/icon_strings.dart';
import 'package:x_arena/src/constants/image_strings.dart';
import 'package:x_arena/src/features/core/screens/account/child_screens/linked_accounts/widgets/pubg_data_form.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/child_screens/customize_tournament/customize_tournament.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/child_screens/upload_results/upload_results.dart';

class TournamentDetails extends StatefulWidget {
  const TournamentDetails({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  State<TournamentDetails> createState() => _TournamentDetailsState();
}

class _TournamentDetailsState extends State<TournamentDetails> {
  bool userRegistered = false;
  int currentPageIndex = 0;
  DateTime? startDate;

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

  TextEditingController pubgNameController = TextEditingController();
  TextEditingController pubgIdController = TextEditingController();

  final tournamentCollection = FirebaseFirestore.instance.collection('Tournaments');
  final userCollection = FirebaseFirestore.instance.collection('Users');
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
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
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.chat,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: StreamBuilder(
          stream: tournamentCollection.doc(widget.tournamentId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final tournamentSnapshot = snapshot.data?.data();
              final tournamentId = snapshot.data?.id;
              Timestamp endDateTimestamp = tournamentSnapshot!['End Date'];
              DateTime endDate = endDateTimestamp.toDate();
              if (tournamentSnapshot.containsKey('Start Date')) {
                Timestamp startDateTimestamp = tournamentSnapshot['Start Date'];
                startDate = startDateTimestamp.toDate();
              }
              List<dynamic> participants = tournamentSnapshot['Participants'];
              int participantsAllowed = int.parse(tournamentSnapshot['Maximum Players']);
              int participantsJoined = participants.length;
              double tournamentFilled = (participantsJoined / participantsAllowed) * 100;
              String entryFee = tournamentSnapshot['Entry Fee'].toString();
              List<dynamic> prizes = tournamentSnapshot['Prizes'];
              int prizePool = 0;
              if (prizes.isNotEmpty) {
                for (int i = 0; i < prizes.length; i++) {
                  prizePool = prizePool + prizes[i] as int;
                }
              } else {
                prizePool = 0;
              }
              final List<Widget> widgets = [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournamentSnapshot['Rules'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: participants.isEmpty
                      ? Text(
                          'No Participant',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : StreamBuilder(
                          stream: userCollection.where(FieldPath.documentId, whereIn: participants).snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Loading();
                            }
                            if (snapshot.hasData) {
                              List<QueryDocumentSnapshot> participantsDocument = [
                                for (String id in participants) snapshot.data!.docs.firstWhere((doc) => doc.id == id),
                              ];
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: participants.length,
                                itemBuilder: (context, index) {
                                  final userSnapshot = participantsDocument[index];
                                  final userData = userSnapshot.data() as Map<String, dynamic>?;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            if (userData != null && userData.containsKey('Image'))
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.05),
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(25),
                                                  child: Image.network(
                                                    userSnapshot['Image'],
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                            else
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(100),
                                                ),
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 30,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 10),
                                            Text(
                                              userSnapshot['Full Name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  );
                                },
                              );
                            } else {
                              return const Loading();
                            }
                          },
                        ),
                ),
              ];
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            double containerWidth = constraints.maxWidth;
                            double containerHeight = constraints.maxWidth / 1.8;
                            return tournamentSnapshot.containsKey('Image')
                                ? Container(
                                    width: containerWidth,
                                    height: containerHeight,
                                    color: Colors.white.withOpacity(0.05),
                                    child: Image.network(tournamentSnapshot['Image'], fit: BoxFit.cover),
                                  )
                                : Container(
                                    width: containerWidth,
                                    height: containerHeight,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF161616),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        appLogo,
                                        height: 40,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.5),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  );
                          },
                        ),
                        if (tournamentSnapshot['Created by'] == user?.uid)
                          Positioned(
                            right: 5,
                            top: 5,
                            child: Column(
                              children: [
                                if (tournamentSnapshot.containsKey('Status') && tournamentSnapshot['Status'] == 'Finalized')
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 5),
                                        const Text(
                                          'Finalized',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: const Icon(
                                            Icons.done_all,
                                            size: 15,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (tournamentSnapshot.containsKey('Status') && tournamentSnapshot['Status'] == 'Finished')
                                  InkWell(
                                    onTap: () {
                                      Get.to(() => UploadResults(tournamentId: widget.tournamentId));
                                    },
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 5),
                                          const Text(
                                            'Upload Results',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: const Icon(
                                              Icons.upload,
                                              size: 15,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else if (tournamentSnapshot.containsKey('Start Date') && startDate!.isBefore(DateTime.now()))
                                  InkWell(
                                    onTap: () async {
                                      await tournamentCollection.doc(widget.tournamentId).update({'Status': 'Finished'});
                                    },
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 5),
                                          const Text(
                                            'Mark as finished',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: const Icon(
                                              Icons.check,
                                              size: 15,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: () {
                                      Get.to(() => CustomizeTournament(tournamentId: tournamentId.toString()));
                                    },
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: const Icon(
                                              Icons.edit_rounded,
                                              size: 15,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          const Text(
                                            'Customize',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournamentSnapshot['Tournament Name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: SvgPicture.asset(
                                        gamepad1Icon,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'PUBG MOBILE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: SvgPicture.asset(
                                        trophyIcon,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    if (tournamentSnapshot.containsKey('Status'))
                                      const Text(
                                        'Finished',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else if (tournamentSnapshot.containsKey('Start Date') && startDate!.isBefore(DateTime.now()))
                                      const Text(
                                        'Started',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else if (endDate.isBefore(DateTime.now()))
                                      const Text(
                                        'Closed',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else
                                      const Text(
                                        'Open',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: SvgPicture.asset(
                                        gameMapIcon,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      tournamentSnapshot['Map'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: SvgPicture.asset(
                                        gamepad2Icon,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      tournamentSnapshot['Tournament Mode'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: SvgPicture.asset(
                                        progressIcon,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${tournamentFilled.toStringAsFixed(1)}% Full',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: SvgPicture.asset(
                                        participantIcon,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${participantsJoined.toString()} Participants',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (tournamentSnapshot.containsKey('Start Date') && startDate!.isBefore(DateTime.now()))
                            const SizedBox()
                          else
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: SvgPicture.asset(
                                        timerIcon,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    if (endDate.isBefore(DateTime.now()))
                                      const Text(
                                        'Registration Closed',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    else if (endDate.isBefore(DateTime.now().add(const Duration(hours: 24))))
                                      Row(
                                        children: [
                                          const Text(
                                            'Registration ends in ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          CountdownTimer(
                                            endTime: endDate.millisecondsSinceEpoch,
                                            textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                            endWidget: const Text(
                                              '00 : 00 : 00',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Text(
                                        'Registration ends on ${DateFormat('dd MMMM, hh:mm a').format(endDate)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          if (tournamentSnapshot.containsKey('Status') && tournamentSnapshot['Status'] == 'Finalized')
                            const SizedBox()
                          else if (tournamentSnapshot.containsKey('Status') && tournamentSnapshot['Status'] == 'Finished')
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: SvgPicture.asset(
                                        resultsIcon,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Text(
                                      'Results pending',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 25,
                                      child: SvgPicture.asset(
                                        battleOutlinedIcon,
                                        height: 20,
                                        colorFilter: ColorFilter.mode(
                                          Colors.white.withOpacity(0.8),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    if (tournamentSnapshot.containsKey('Start Date'))
                                      if (startDate!.isBefore(DateTime.now()))
                                        const Text(
                                          'Match Started',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      else if (startDate!.isBefore(DateTime.now().add(const Duration(hours: 24))))
                                        Row(
                                          children: [
                                            const Text(
                                              'Match starts in ',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                            CountdownTimer(
                                              endTime: startDate?.millisecondsSinceEpoch,
                                              textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                              endWidget: const Text(
                                                '00 : 00 : 00',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Text(
                                          'Match starts on ${DateFormat('dd MMMM, hh:mm a').format(startDate!)}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                        )
                                    else
                                      const Text(
                                        'Match start date not specified yet',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(height: 20),
                          StreamBuilder(
                            stream: userCollection.doc(tournamentSnapshot['Created by']).snapshots(),
                            builder: (context, snapshot) {
                              final userSnapshot = snapshot.data?.data();
                              final userId = snapshot.data?.id;
                              if (snapshot.hasData) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (userSnapshot!.containsKey('Image'))
                                      Container(
                                        width: 40,
                                        height: 40,
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
                                      )
                                    else
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 30,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Organized By',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              userSnapshot['Full Name'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            if (userId == 'y51CavvPBfazecLCzyzOb9AbwZT2')
                                              const Icon(
                                                Icons.verified,
                                                size: 14,
                                                color: Colors.green,
                                              )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              } else {
                                return Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 14,
                                          color: Colors.white.withOpacity(0.05),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          width: 150,
                                          height: 16,
                                          color: Colors.white.withOpacity(0.05),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ],
                      ),
                    ),
                    if (tournamentSnapshot.containsKey('Status') && tournamentSnapshot['Status'] == 'Finalized')
                      participants.isEmpty
                          ? Text(
                              'No Participant',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Results:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  StreamBuilder(
                                    stream: userCollection.where(FieldPath.documentId, whereIn: participants).snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        List<QueryDocumentSnapshot> participantsDocument = [
                                          for (String id in participants) snapshot.data!.docs.firstWhere((doc) => doc.id == id),
                                        ];
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: participants.length,
                                          itemBuilder: (context, index) {
                                            participantsDocument.sort((a, b) {
                                              String rankA = '';
                                              String rankB = '';
                                              if (tournamentSnapshot.containsKey('Tournament Record')) {
                                                List<Map<String, String>> previousTournamentRecord = (tournamentSnapshot['Tournament Record'] as List<dynamic>).map((record) => Map<String, String>.from(record)).toList();
                                                final playerRecordIndexA = previousTournamentRecord.indexWhere((record) => record['Player ID'] == a.id);
                                                final playerRecordIndexB = previousTournamentRecord.indexWhere((record) => record['Player ID'] == b.id);
                                                if (playerRecordIndexA != -1) {
                                                  rankA = previousTournamentRecord[playerRecordIndexA]['Rank']!;
                                                }
                                                if (playerRecordIndexB != -1) {
                                                  rankB = previousTournamentRecord[playerRecordIndexB]['Rank']!;
                                                }
                                              }
                                              return rankA.compareTo(rankB);
                                            });
                                            final userSnapshot = participantsDocument[index];
                                            final userData = userSnapshot.data() as Map<String, dynamic>?;
                                            String rank = '';
                                            String winPrize = '';
                                            if (tournamentSnapshot.containsKey('Tournament Record')) {
                                              List<Map<String, String>> previousTournamentRecord = (tournamentSnapshot['Tournament Record'] as List<dynamic>).map((record) => Map<String, String>.from(record)).toList();
                                              final playerRecordIndex = previousTournamentRecord.indexWhere((record) => record['Player ID'] == userSnapshot.id);
                                              if (playerRecordIndex != -1) {
                                                rank = previousTournamentRecord[playerRecordIndex]['Rank']!;
                                                winPrize = previousTournamentRecord[playerRecordIndex]['Win Prize']!;
                                              }
                                            }
                                            return Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 30,
                                                        child: FittedBox(
                                                          child: Text(
                                                            '$rank${getOrdinalIndicator(int.parse(rank))}',
                                                            style: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 18,
                                                              fontStyle: FontStyle.italic,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 10),
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            if (userData != null && userData.containsKey('Image'))
                                                              Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white.withOpacity(0.05),
                                                                  borderRadius: BorderRadius.circular(100),
                                                                ),
                                                                child: ClipRRect(
                                                                  borderRadius: BorderRadius.circular(25),
                                                                  child: Image.network(
                                                                    userSnapshot['Image'],
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              )
                                                            else
                                                              Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                  color: Colors.white.withOpacity(0.1),
                                                                  borderRadius: BorderRadius.circular(100),
                                                                ),
                                                                child: const Center(
                                                                  child: Icon(
                                                                    Icons.person,
                                                                    size: 30,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                            const SizedBox(width: 10),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  userSnapshot['Full Name'],
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 14,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                if (winPrize != '0')
                                                                  Text(
                                                                    'PKR $winPrize',
                                                                    style: TextStyle(
                                                                      color: Colors.green.withOpacity(0.8),
                                                                      fontSize: 12,
                                                                      fontWeight: FontWeight.bold,
                                                                      fontStyle: FontStyle.italic,
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                              ],
                                            );
                                          },
                                        );
                                      } else {
                                        return const Loading();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            )
                    else
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.green,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: prizePool == 0
                                                  ? Row(
                                                      children: [
                                                        const SizedBox(width: 10),
                                                        Text(
                                                          'NO PRIZE POOL',
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(
                                                            color: Colors.white.withOpacity(0.8),
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Row(
                                                      children: [
                                                        const SizedBox(width: 10),
                                                        Expanded(
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'TOTAL PRIZE POOL',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Colors.white.withOpacity(0.8),
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                              Text(
                                                                'PKR $prizePool',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Colors.white.withOpacity(0.8),
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              Text(
                                                                'SEE MORE DETAILS',
                                                                textAlign: TextAlign.center,
                                                                style: TextStyle(
                                                                  color: Colors.white.withOpacity(0.8),
                                                                  fontSize: 10,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.navigate_next,
                                                          color: Colors.white.withOpacity(0.8),
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
                                    const SizedBox(width: 10),
                                    StreamBuilder(
                                      stream: userCollection.doc(user?.uid).snapshots(),
                                      builder: (context, snapshot) {
                                        final userSnapshot = snapshot.data?.data();
                                        if (snapshot.hasData) {
                                          for (int i = 0; i < participants.length; i++) {
                                            if (participants[i] == user?.uid) {
                                              userRegistered = true;
                                            }
                                          }
                                          if (endDate.isBefore(DateTime.now()) && userRegistered == false) {
                                            return Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color: Colors.red,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(width: 10),
                                                          Text(
                                                            'REGISTRATION\nCLOSED',
                                                            textAlign: TextAlign.start,
                                                            style: TextStyle(
                                                              color: Colors.white.withOpacity(0.8),
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.bold,
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
                                            );
                                          } else {
                                            return Expanded(
                                              child: userRegistered == true
                                                  ? ClipRRect(
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: Stack(
                                                        children: [
                                                          Container(
                                                            height: 50,
                                                            width: double.infinity,
                                                            decoration: BoxDecoration(
                                                              color: Colors.red,
                                                              borderRadius: BorderRadius.circular(10),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                const SizedBox(width: 10),
                                                                Text(
                                                                  'REGISTERED',
                                                                  style: TextStyle(
                                                                    color: Colors.white.withOpacity(0.8),
                                                                    fontSize: 16,
                                                                    fontWeight: FontWeight.bold,
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
                                                    )
                                                  : InkWell(
                                                      onTap: () async {
                                                        if (userRegistered == false) {
                                                          if (userSnapshot!.containsKey('PUBG Account')) {
                                                            participants.add(user?.uid);
                                                            await tournamentCollection.doc(widget.tournamentId).update({'Participants': participants});
                                                          } else {
                                                            showDialog(
                                                              context: context,
                                                              barrierDismissible: false,
                                                              builder: (BuildContext context) {
                                                                return PUBGDataForm(
                                                                  title: 'LINK PUBG ACCOUNT',
                                                                  pubgNameController: pubgNameController,
                                                                  pubgIdController: pubgIdController,
                                                                  userCollection: userCollection,
                                                                  buttonText: 'Link',
                                                                  completionMessage: 'Linked Successfully',
                                                                  userId: user?.uid,
                                                                );
                                                              },
                                                            );
                                                          }
                                                        }
                                                      },
                                                      borderRadius: BorderRadius.circular(10),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: Stack(
                                                          children: [
                                                            Ink(
                                                              height: 50,
                                                              decoration: BoxDecoration(
                                                                color: Colors.red,
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              child: entryFee == 'Free Entry'
                                                                  ? Row(
                                                                      children: [
                                                                        const SizedBox(width: 10),
                                                                        Text(
                                                                          'FREE ENTRY',
                                                                          textAlign: TextAlign.center,
                                                                          style: TextStyle(
                                                                            color: Colors.white.withOpacity(0.8),
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      children: [
                                                                        const SizedBox(width: 10),
                                                                        Expanded(
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                'ENTRY FEE',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  color: Colors.white.withOpacity(0.8),
                                                                                  fontSize: 10,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                'PKR $entryFee',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  color: Colors.white.withOpacity(0.8),
                                                                                  fontSize: 16,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              Text(
                                                                                'CLICK HERE TO JOIN',
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  color: Colors.white.withOpacity(0.8),
                                                                                  fontSize: 10,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Icon(
                                                                          Icons.navigate_next,
                                                                          color: Colors.white.withOpacity(0.8),
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
                                            );
                                          }
                                        } else {
                                          return Expanded(
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.05),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            currentPageIndex = 0;
                                          });
                                        },
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: currentPageIndex == 0 ? Colors.green : Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'RULES',
                                              style: TextStyle(
                                                color: currentPageIndex == 0 ? Colors.black : Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            currentPageIndex = 1;
                                          });
                                        },
                                        child: Container(
                                          height: 30,
                                          decoration: BoxDecoration(
                                            color: currentPageIndex == 1 ? Colors.green : Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'PARTICIPANTS',
                                              style: TextStyle(
                                                color: currentPageIndex == 1 ? Colors.black : Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          widgets[currentPageIndex],
                        ],
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
