import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  // Secondary Colors
  static const Color secondary = Color(0xFFEC4899); // Pink
  static const Color secondaryLight = Color(0xFFF472B6);
  static const Color secondaryDark = Color(0xFFDB2777);

  // Accent Colors
  static const Color accent = Color(0xFF10B981); // Emerald
  static const Color accentLight = Color(0xFF34D399);
  static const Color accentDark = Color(0xFF059669);

  // Neutral Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1F2937);
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Mood Colors (matching Mood entity colors)
  static const Color moodEcstatic = Color(0xFFFFD700); // Gold
  static const Color moodHappy = Color(0xFFFFFF00); // Yellow
  static const Color moodContent = Color(0xFF90EE90); // Light green
  static const Color moodNeutral = Color(0xFFD3D3D3); // Light gray
  static const Color moodSad = Color(0xFF87CEEB); // Sky blue
  static const Color moodAnxious = Color(0xFFFFA500); // Orange
  static const Color moodExcited = Color(0xFFFF69B4); // Hot pink
  static const Color moodPeaceful = Color(0xFF98FB98); // Pale green
  static const Color moodFrustrated = Color(0xFFFF6347); // Tomato red
  static const Color moodGrateful = Color(0xFFDDA0DD); // Plum

  // Privacy Level Colors
  static const Color privacyPrivate = Color(0xFF6B7280); // Gray
  static const Color privacyFriends = Color(0xFFF59E0B); // Amber
  static const Color privacyPublic = Color(0xFF10B981); // Green

  // Weather Colors
  static const Color weatherSunny = Color(0xFFFFD700);
  static const Color weatherCloudy = Color(0xFF9CA3AF);
  static const Color weatherRainy = Color(0xFF3B82F6);
  static const Color weatherSnowy = Color(0xFFE5E7EB);
  static const Color weatherWindy = Color(0xFF6B7280);
  static const Color weatherFoggy = Color(0xFFD1D5DB);

  // Category Colors
  static const Color categoryRestaurant = Color(0xFFEF4444); // Red
  static const Color categoryCafe = Color(0xFF8B5CF6); // Violet
  static const Color categoryBar = Color(0xFFF59E0B); // Amber
  static const Color categoryHotel = Color(0xFF10B981); // Emerald
  static const Color categoryAttraction = Color(0xFFF97316); // Orange
  static const Color categoryPark = Color(0xFF22C55E); // Green
  static const Color categoryMuseum = Color(0xFF6366F1); // Indigo
  static const Color categoryShop = Color(0xFFEC4899); // Pink
  static const Color categoryEvent = Color(0xFF84CC16); // Lime
  static const Color categoryEntertainment = Color(0xFFF59E0B); // Amber
  static const Color categoryNature = Color(0xFF059669); // Teal
  static const Color categoryCultural = Color(0xFF7C3AED); // Purple

  // Utility Colors
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color divider = Color(0xFFE5E7EB);

  // Shadow Colors
  static const Color shadow = Color(0x1F000000); // 12% black
  static const Color shadowLight = Color(0x0F000000); // 6% black

  // Helper method to get mood color by type
  static Color getMoodColor(String moodType) {
    switch (moodType.toLowerCase()) {
      case 'ecstatic':
        return moodEcstatic;
      case 'happy':
        return moodHappy;
      case 'content':
        return moodContent;
      case 'neutral':
        return moodNeutral;
      case 'sad':
        return moodSad;
      case 'anxious':
        return moodAnxious;
      case 'excited':
        return moodExcited;
      case 'peaceful':
        return moodPeaceful;
      case 'frustrated':
        return moodFrustrated;
      case 'grateful':
        return moodGrateful;
      default:
        return moodNeutral;
    }
  }

  // Helper method to get category color
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return categoryRestaurant;
      case 'cafe':
        return categoryCafe;
      case 'bar':
        return categoryBar;
      case 'hotel':
        return categoryHotel;
      case 'attraction':
        return categoryAttraction;
      case 'park':
        return categoryPark;
      case 'museum':
        return categoryMuseum;
      case 'shop':
        return categoryShop;
      case 'event':
        return categoryEvent;
      case 'entertainment':
        return categoryEntertainment;
      case 'nature':
        return categoryNature;
      case 'cultural':
        return categoryCultural;
      default:
        return primary;
    }
  }

  // Helper method to get privacy color
  static Color getPrivacyColor(String privacyLevel) {
    switch (privacyLevel.toLowerCase()) {
      case 'private':
        return privacyPrivate;
      case 'friends':
        return privacyFriends;
      case 'public':
        return privacyPublic;
      default:
        return privacyPrivate;
    }
  }

  // Helper method to get weather color
  static Color getWeatherColor(String weather) {
    switch (weather.toLowerCase()) {
      case 'sunny':
        return weatherSunny;
      case 'cloudy':
        return weatherCloudy;
      case 'rainy':
        return weatherRainy;
      case 'snowy':
        return weatherSnowy;
      case 'windy':
        return weatherWindy;
      case 'foggy':
        return weatherFoggy;
      default:
        return weatherSunny;
    }
  }
}