import 'package:flutter/material.dart';

const ColorScheme scarabColorScheme = ColorScheme(
  primary: Color(0xFF0C9CDE), // Primary Blue (The main armor color)
  primaryContainer: Color.fromARGB(
    255,
    33,
    40,
    142,
  ), // Darker Blue (Armor shading/accents)
  secondary: Color(0xFF97F4FB), // Cyan Accent (Bioluminescent lines/glow)
  secondaryContainer: Color(
    0xFF220099,
  ), // Deep Indigo (Near Black primary base)
  surface: Color(0xFF121212), // App Background/Surface (Dark mode black)
  error: Color(0xFFE50914), // Red Eyes/Error state
  onPrimary: Colors.white, // Text color on primary color
  onSecondary: Colors.black, // Text color on secondary color
  onSurface: Colors.white70, // Text color on surfaces
  onError: Colors.white, // Text color on error color
  brightness: Brightness.dark,
);

final ThemeData scarabTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: scarabColorScheme,
  scaffoldBackgroundColor: const Color(0xFF040608), // Deep "Alien Void" Black
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF0D141C), // Deep Metallic Navy (Armor Plate)
    hintStyle: const TextStyle(
      color: Color(0xFF38B6FF), // Bioluminescent Cyan (Glow effect)
      fontWeight: FontWeight.w300,
    ),
    labelStyle: const TextStyle(color: Color(0xFF00E5FF)),

    // Outer border with the "glowing line" effect
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: const Color(0xFF00E5FF).withValues(alpha: .3),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
);
