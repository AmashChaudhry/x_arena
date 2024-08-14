import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavBarItem extends StatefulWidget {
  const BottomNavBarItem({
    super.key,
    required this.onTap,
    required this.currentIndex,
    required this.index,
    required this.icon,
    required this.activeIcon,
    required this.name,
  });

  final VoidCallback onTap;
  final int currentIndex;
  final int index;
  final String icon;
  final String activeIcon;
  final String name;

  @override
  State<BottomNavBarItem> createState() => _BottomNavBarItemState();
}

class _BottomNavBarItemState extends State<BottomNavBarItem> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: widget.currentIndex == widget.index
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    widget.activeIcon,
                    height: 25,
                    colorFilter: const ColorFilter.mode(
                      Colors.green,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    widget.icon,
                    height: 25,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.4),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
