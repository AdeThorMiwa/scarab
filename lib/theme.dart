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
