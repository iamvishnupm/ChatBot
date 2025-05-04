import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:frontend/controllers/theme_controller.dart";

class ThemeButton extends StatelessWidget {
  const ThemeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeControl = Provider.of<ThemeControl>(context);
    return IconButton(
      icon: Icon(
        themeControl.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      onPressed: themeControl.toggleTheme,
    );
  }
}
