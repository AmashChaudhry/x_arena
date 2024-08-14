import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:x_arena/src/constants/icon_strings.dart';
import 'package:x_arena/src/constants/image_strings.dart';
import 'package:x_arena/src/features/core/components/widgets/bottom_navbar_item.dart';
import 'package:x_arena/src/features/core/screens/community/community.dart';
import 'package:x_arena/src/features/core/screens/create_tournament/create_tournament.dart';
import 'package:x_arena/src/features/core/screens/games/games.dart';
import 'package:x_arena/src/features/core/screens/account/account.dart';
import 'package:x_arena/src/features/core/screens/registered_tournaments/registered_tournament.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  final List<Widget> tabs = [
    const Games(),
    const RegisteredTournament(),
    const Community(),
    const Account(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.black,
          centerTitle: true,
          title: SizedBox(
            height: 25,
            child: SvgPicture.asset(
              appLogo,
              colorFilter: const ColorFilter.mode(
                Colors.green,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        body: tabs[currentIndex],
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: const Color(0xFF161616),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              builder: (BuildContext context) {
                return Container(
                  height: 150,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.back();
                          Get.to(() => const CreateTournament());
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 120,
                          width: 100,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 40,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              Text(
                                'Create Tournament',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.black),
        ),
        bottomNavigationBar: BottomAppBar(
          height: 50,
          color: const Color(0xFF161616),
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              BottomNavBarItem(
                onTap: () {
                  setState(() {
                    currentIndex = 0;
                  });
                },
                index: 0,
                currentIndex: currentIndex,
                icon: homeFilledIcon,
                activeIcon: homeFilledIcon,
                name: 'Home',
              ),
              BottomNavBarItem(
                onTap: () {
                  setState(() {
                    currentIndex = 1;
                  });
                },
                index: 1,
                currentIndex: currentIndex,
                icon: tournamentFilledIcon,
                activeIcon: tournamentFilledIcon,
                name: 'Registered',
              ),
              const Expanded(child: SizedBox()),
              BottomNavBarItem(
                onTap: () {
                  setState(() {
                    currentIndex = 2;
                  });
                },
                index: 2,
                currentIndex: currentIndex,
                icon: communityFilledIcon,
                activeIcon: communityFilledIcon,
                name: 'Community',
              ),
              BottomNavBarItem(
                onTap: () {
                  setState(() {
                    currentIndex = 3;
                  });
                },
                index: 3,
                currentIndex: currentIndex,
                icon: profileFilledIcon,
                activeIcon: profileFilledIcon,
                name: 'Account',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
