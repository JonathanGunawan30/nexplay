import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'core/constants/constants.dart';
import 'firebase_options.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/success_screen.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/games/screens/main_screen.dart';
import 'features/games/providers/game_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/games/providers/premium_game_provider.dart';
import 'features/games/providers/comment_provider.dart';
import 'features/social/providers/social_provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Initialize Stripe safely
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    try {
      Stripe.publishableKey = AppConstants.stripePublishableKey;
      await Stripe.instance.applySettings();
    } catch (e) {
      debugPrint('Stripe initialization failed: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => PremiumGameProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
      ],
      child: const NexPlayApp(),
    ),
  );
}

class NexPlayApp extends StatelessWidget {
  const NexPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'NexPlay',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
          surface: const Color(0xFFF8FAFC),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
          surface: const Color(0xFF0F172A),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSuccess = false;
  bool? _wasAuthenticated;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAuthenticated = authProvider.isAuthenticated;

    if (_wasAuthenticated != null && _wasAuthenticated == false && isAuthenticated) {
      _showSuccess = true;
    }
    _wasAuthenticated = isAuthenticated;

    if (_showSuccess) {
      return SuccessScreen(
        onFinished: () {
          setState(() {
            _showSuccess = false;
          });
        },
      );
    }

    return isAuthenticated ? const MainScreen() : const LoginScreen();
  }
}
