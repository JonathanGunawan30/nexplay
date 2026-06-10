import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get cloudinaryCloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get cloudinaryUploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
  static String get cloudinaryApiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  static String get cloudinaryApiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'pk_test_51TdmcJ1lZTrDRPh8L7p96OidrWp0S7A5uC8M1oQ9eRj8V7p96OidrWp0S7A5uC8M1oQ9eRj8V';

  static const String usersCollection = 'users';
  static const String gamesCollection = 'games';
  static const String favoriteGamesCollection = 'favorite_games';
  static const String commentsCollection = 'comments';
}
