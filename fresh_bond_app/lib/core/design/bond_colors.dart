import 'package:flutter/material.dart';

/// Bond Design System - Color System
/// 
/// A comprehensive color system based on emotional connection psychology
/// for the Bond application. Includes primary, neutral, and semantic colors.
class BondColors {
  BondColors._(); // Private constructor to prevent instantiation

  // Primary Colors
  static const Color bondTeal = Color(0xFF0ABAB5);
  static const Color connectionPurple = Color(0xFF6E44FF);
  static const Color warmthOrange = Color(0xFFFF7D3B);
  static const Color trustBlue = Color(0xFF2D7FF9);

  // Neutral Colors
  static const Color night = Color(0xFF121F2B);
  static const Color slate = Color(0xFF334155);
  static const Color mist = Color(0xFF94A3B8);
  static const Color cloud = Color(0xFFE2E8F0);
  static const Color snow = Color(0xFFF8FAFC);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Gradient Definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bondTeal, trustBlue],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [connectionPurple, warmthOrange],
  );

  // Glass Effect Colors
  static const Color glassBackground = Color(0xB3FFFFFF); // ~70% opacity white
  static const Color glassBorder = Color(0x4DFFFFFF); // ~30% opacity white
  static const Color glassShadow = Color(0x1A000000); // ~10% opacity black

  // Dark Mode Glass Effect Colors
  static const Color darkGlassBackground = Color(0x99121F2B); // ~60% opacity night
  static const Color darkGlassBorder = Color(0x33334155); // ~20% opacity slate
  static const Color darkGlassShadow = Color(0x40000000); // ~25% opacity black
}
