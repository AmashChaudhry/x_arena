import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:x_arena/src/constants/image_strings.dart';
import 'package:x_arena/src/features/authentications/screens/login/login_screen.dart';
import 'package:x_arena/src/features/authentications/screens/verify_email/verify_email.dart';
import 'package:x_arena/src/features/core/components/bottom_navigation_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void checkAuthentication() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        Get.offAll(() => const BottomNavBar());
      } else {
        Get.offAll(() => const VerifyEmailAddress());
      }
    } else {
      Get.offAll(() => const LoginScreen());
    }

    // final userCollection = FirebaseFirestore.instance.collection('Users');
    // final querySnapshot = await userCollection.where('Email', isEqualTo: user?.email).get();
    //
    // if (querySnapshot.docs.isNotEmpty) {
    //   DocumentSnapshot userDocument = querySnapshot.docs.first;
    //   Map<String, dynamic>? userSnapshot = userDocument.data() as Map<String, dynamic>?;
    //
    //   if (user != null) {
    //     if (user.emailVerified && userSnapshot != null && userSnapshot.containsKey('Phone Number')) {
    //       Get.offAll(() => const BottomNavBar());
    //     } else {
    //       if(!user.emailVerified) {
    //         Get.offAll(() => const VerifyEmailAddress());
    //       } else if(userSnapshot != null && !userSnapshot.containsKey('Phone Number')) {
    //         Get.offAll(() => const VerifyPhoneNumber());
    //       }
    //     }
    //   } else {
    //     Get.offAll(() => const LoginScreen());
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      checkAuthentication();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SizedBox(
          height: 60,
          child: SvgPicture.asset(
            appLogo,
            colorFilter: const ColorFilter.mode(
              Colors.green,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
