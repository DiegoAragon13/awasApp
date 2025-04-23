import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int notificationCount;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomAppBar({
    super.key,
    this.notificationCount = 0,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: const Text(
        'AWAS',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: false,
      backgroundColor: backgroundColor ?? theme.primaryColor,
      foregroundColor: foregroundColor ?? Colors.white,
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () {
                // Acción al presionar la campanita
              },
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$notificationCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
