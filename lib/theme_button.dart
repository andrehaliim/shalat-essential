import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shalat_essential/themedata.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return IconButton(
      onPressed: () => Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => RotationTransition(turns: animation, child: child),
        child: Icon(
          isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
          key: ValueKey<bool>(isDark),
          color: Theme.of(context).iconTheme.color,
        ),
      ),
    );
  }
}