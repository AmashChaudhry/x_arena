import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:x_arena/src/common_widgets/loading.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/child_screens/customize_tournament/child_widgets/customize_end_date.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/child_screens/customize_tournament/child_widgets/customize_start_date.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/child_screens/customize_tournament/child_widgets/customize_tournament_name.dart';

class CustomizeTournament extends StatefulWidget {
  const CustomizeTournament({
    super.key,
    required this.tournamentId,
  });

  final String tournamentId;

  @override
  State<CustomizeTournament> createState() => _CustomizeTournamentState();
}

class _CustomizeTournamentState extends State<CustomizeTournament> {
  DateTime? tournamentStartDate;
  DateTime? registrationEndDate;

  final tournamentCollection = FirebaseFirestore.instance.collection('Tournaments');
  final userCollection = FirebaseFirestore.instance.collection('Users');
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'Customize Tournament',
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
            final tournamentSnapshot = snapshot.data?.data();
            if (tournamentSnapshot!.containsKey('End Date')) {
              Timestamp registrationEndDateTimestamp = tournamentSnapshot['End Date'];
              registrationEndDate = registrationEndDateTimestamp.toDate();
            }
            if (tournamentSnapshot.containsKey('Start Date')) {
              Timestamp startDateTimestamp = tournamentSnapshot['Start Date'];
              tournamentStartDate = startDateTimestamp.toDate();
            }
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tournament Name',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                tournamentSnapshot['Tournament Name'],
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => TournamentName(tournamentId: widget.tournamentId));
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Ink(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Registration End Date',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                registrationEndDate == null ? 'Specify Registration End Date' : DateFormat('dd MMMM, yyyy | hh : mm a').format(registrationEndDate!),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => RegistrationEndDate(tournamentId: widget.tournamentId));
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Ink(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tournament Start Date',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                tournamentStartDate == null ? 'Specify Tournament Start Date' : DateFormat('dd MMMM, yyyy | hh : mm a').format(tournamentStartDate!),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Get.to(() => TournamentStartDate(tournamentId: widget.tournamentId));
                          },
                          borderRadius: BorderRadius.circular(25),
                          child: Ink(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
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
    );
  }
}
