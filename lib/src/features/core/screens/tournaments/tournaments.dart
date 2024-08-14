import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:x_arena/src/common_widgets/loading.dart';
import 'package:x_arena/src/constants/image_strings.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/tournament_details.dart';

class Tournaments extends StatefulWidget {
  const Tournaments({super.key});

  @override
  State<Tournaments> createState() => _TournamentsState();
}

class _TournamentsState extends State<Tournaments> {
  User? user = FirebaseAuth.instance.currentUser;
  final userCollection = FirebaseFirestore.instance.collection('Users');
  final tournamentCollection = FirebaseFirestore.instance.collection('Tournaments');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: const Text(
            'PUBG MOBILE',
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
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: StreamBuilder(
            stream: tournamentCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final tournamentSnapshot = snapshot.data!.docs[index];
                      final userData = tournamentSnapshot.data();
                      Timestamp endDateTimestamp = tournamentSnapshot['End Date'];
                      DateTime endDate = endDateTimestamp.toDate();
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
                          GestureDetector(
                            onTap: () {
                              Get.to(() => TournamentDetails(tournamentId: tournamentSnapshot.id));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                      double containerWidth = constraints.maxWidth;
                                      double containerHeight = constraints.maxWidth / 1.8;
                                      return userData.containsKey('Image')
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
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  tournamentSnapshot['Tournament Name'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  prizePool == 0 ? 'No Prize Pool' : 'Prize Pool PKR $prizePool',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                StreamBuilder(
                                  stream: userCollection.doc(tournamentSnapshot['Created by']).snapshots(),
                                  builder: (context, snapshot) {
                                    final userSnapshot = snapshot.data?.data();
                                    final userId = snapshot.data?.id;
                                    if (snapshot.hasData) {
                                      return Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            userSnapshot!['Full Name'],
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 2),
                                          if (userId == 'y51CavvPBfazecLCzyzOb9AbwZT2')
                                            Icon(
                                              Icons.verified,
                                              size: 12,
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                        ],
                                      );
                                    } else {
                                      return Container(
                                        width: 150,
                                        height: 14,
                                        color: Colors.white.withOpacity(0.05),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
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
        ),
      ),
    );
  }
}
