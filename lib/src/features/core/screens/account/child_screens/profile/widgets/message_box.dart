import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageBox extends StatefulWidget {
  const MessageBox({
    super.key,
    required this.errorText,
    required this.icon,
    required this.iconColor,
  });

  final String errorText;
  final IconData icon;
  final Color iconColor;

  @override
  State<MessageBox> createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  bool animate = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161616),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      titlePadding: const EdgeInsets.only(top: 10, bottom: 5, left: 10, right: 10),
      contentPadding: const EdgeInsets.only(top: 5, bottom: 15, left: 10, right: 10),
      title: Icon(
        widget.icon,
        color: widget.iconColor,
        size: 50,
      ),
      content: Text(
        widget.errorText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
