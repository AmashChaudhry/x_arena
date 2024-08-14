import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:x_arena/src/common_widgets/loading.dart';
import 'package:x_arena/src/constants/icon_strings.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/tournament_details.dart';

class RegisteredTournament extends StatefulWidget {
  const RegisteredTournament({super.key});

  @override
  State<RegisteredTournament> createState() => _RegisteredTournamentState();
}

class _RegisteredTournamentState extends State<RegisteredTournament> {
  User? user = FirebaseAuth.instance.currentUser;
  final userCollection = FirebaseFirestore.instance.collection('Users');
  final tournamentCollection = FirebaseFirestore.instance.collection('Tournaments');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: StreamBuilder(
        stream: tournamentCollection.where('Participants', arrayContains: user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final tournamentSnapshot = snapshot.data!.docs[index];
                  List<dynamic> prizes = tournamentSnapshot['Prizes'];
                  int prizePool = 0;
                  if (prizes.isNotEmpty) {
                    for (int i = 0; i < prizes.length; i++) {
                      prizePool = prizePool + prizes[i] as int;
                    }
                  } else {
                    prizePool = 0;
                  }
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -10,
                              bottom: 0,
                              child: SvgPicture.asset(
                                xIcon,
                                height: 150,
                                colorFilter: ColorFilter.mode(
                                  Colors.white.withOpacity(0.05),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            Container(
                              height: 180,
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              color: Colors.white.withOpacity(0.1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        tournamentSnapshot['Tournament Name'].toUpperCase(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '24 July, 08:00 PM',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: SvgPicture.asset(
                                          pubgMobileIcon,
                                          height: 60,
                                          colorFilter: ColorFilter.mode(
                                            Colors.grey.withOpacity(0.8),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              tournamentSnapshot['Map'].toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.green.withOpacity(0.8),
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              tournamentSnapshot['Tournament Mode'].toUpperCase(),
                                              style: TextStyle(
                                                color: Colors.red.withOpacity(0.8),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: SvgPicture.asset(
                                          battleIcon,
                                          height: 50,
                                          colorFilter: ColorFilter.mode(
                                            Colors.grey.withOpacity(0.8),
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.to(() => TournamentDetails(tournamentId: tournamentSnapshot.id));
                                    },
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      height: 35,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(width: 15),
                                          Text(
                                            'More Details',
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_right,
                                            color: Colors.white.withOpacity(0.8),
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
                      const SizedBox(height: 10),
                    ],
                  );
                },
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
