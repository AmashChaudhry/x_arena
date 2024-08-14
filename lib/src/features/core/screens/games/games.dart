import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:x_arena/src/common_widgets/loading.dart';
import 'package:x_arena/src/constants/image_strings.dart';
import 'package:x_arena/src/features/core/screens/tournament_details/tournament_details.dart';
import 'package:x_arena/src/features/core/screens/tournaments/tournaments.dart';

class Games extends StatefulWidget {
  const Games({super.key});

  @override
  State<Games> createState() => _GamesState();
}

class _GamesState extends State<Games> {
  int currentPage = 0;

  final PageController pageController = PageController();

  User? user = FirebaseAuth.instance.currentUser;
  final userCollection = FirebaseFirestore.instance.collection('Users');
  final tournamentCollection = FirebaseFirestore.instance.collection('Tournaments');

  List<Widget> widgets = [
    Container(
      width: double.infinity,
      height: 150,
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
    ),
    Container(
      width: double.infinity,
      height: 150,
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
    ),
    Container(
      width: double.infinity,
      height: 150,
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
    ),
  ];

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        currentPage = pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double containerWidth = constraints.maxWidth;
              double containerHeight = constraints.maxWidth / 1.8;
              return SizedBox(
                width: containerWidth,
                height: containerHeight,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: widgets.length,
                  itemBuilder: (context, index) {
                    return widgets[index];
                  },
                  onPageChanged: (int index) {
                    currentPage = index;
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widgets.length,
              (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index == currentPage ? Colors.white : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(25),
                  ),
                );
              },
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            'Games',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'See all',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_right,
                          size: 20,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        InkWell(
                          onTap: () {
                            Get.to(() => const Tournaments());
                          },
                          borderRadius: BorderRadius.circular(100),
                          child: Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.asset(
                                pubgLogo,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'PUBG MOBILE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Daily Tournaments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StreamBuilder(
                stream: tournamentCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      height: 210,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
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
                          return Row(
                            children: [
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Get.to(() => TournamentDetails(tournamentId: tournamentSnapshot.id));
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Stack(
                                        children: [
                                          if (userData.containsKey('Image'))
                                            Container(
                                              width: 250,
                                              height: 140,
                                              color: Colors.white.withOpacity(0.05),
                                              child: Image.network(tournamentSnapshot['Image'], fit: BoxFit.cover),
                                            )
                                          else
                                            Container(
                                              width: 250,
                                              height: 140,
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
                                            ),
                                          if (endDate.isBefore(DateTime.now()))
                                            Positioned(
                                              top: 10,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(25),
                                                    bottomLeft: Radius.circular(25),
                                                  ),
                                                ),
                                                child: const Text(
                                                  'Closed',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            )
                                          else if (endDate.isBefore(DateTime.now().add(const Duration(hours: 24))))
                                            Positioned(
                                              top: 10,
                                              right: 0,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(25),
                                                    bottomLeft: Radius.circular(25),
                                                  ),
                                                ),
                                                child: CountdownTimer(
                                                  endTime: endDate.millisecondsSinceEpoch,
                                                  textStyle: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  endWidget: const Text(
                                                    '00 : 00 : 00',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
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
                                  ],
                                ),
                              ),
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
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'All Tournaments',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder(
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
                                                return Stack(
                                                  children: [
                                                    if (userData.containsKey('Image'))
                                                      Container(
                                                        width: containerWidth,
                                                        height: containerHeight,
                                                        color: Colors.white.withOpacity(0.05),
                                                        child: Image.network(tournamentSnapshot['Image'], fit: BoxFit.cover),
                                                      )
                                                    else
                                                      Container(
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
                                                      ),
                                                    if (endDate.isBefore(DateTime.now()))
                                                      Positioned(
                                                        top: 20,
                                                        right: 0,
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                          decoration: const BoxDecoration(
                                                            color: Colors.red,
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(25),
                                                              bottomLeft: Radius.circular(25),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            'Closed',
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    else if (endDate.isBefore(DateTime.now().add(const Duration(hours: 24))))
                                                      Positioned(
                                                        top: 20,
                                                        right: 0,
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                          decoration: const BoxDecoration(
                                                            color: Colors.green,
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(25),
                                                              bottomLeft: Radius.circular(25),
                                                            ),
                                                          ),
                                                          child: CountdownTimer(
                                                            endTime: endDate.millisecondsSinceEpoch,
                                                            textStyle: const TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                            endWidget: const Text(
                                                              '00 : 00 : 00',
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
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
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
