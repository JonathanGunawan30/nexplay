import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get cloudinaryUploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static String get cloudinaryApiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get cloudinaryApiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  static const String usersCollection = 'users';
  static const String gamesCollection = 'games';
  static const String favoriteGamesCollection = 'favorite_games';
  static const String commentsCollection = 'comments';
}
