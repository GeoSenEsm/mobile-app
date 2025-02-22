import 'package:flutter/material.dart';

class NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;

  const NavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = Colors.transparent,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        width: double.infinity,
        color: backgroundColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}
