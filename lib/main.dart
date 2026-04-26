import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (kIsWeb) {
      // Cấu hình chuẩn cho Web bạn vừa gửi
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDFdWSpYv9jICoAyLBy2tOUynKfLUocu3Y",
          authDomain: "smart-room-rental-cec92.firebaseapp.com",
          projectId: "smart-room-rental-cec92",
          storageBucket: "smart-room-rental-cec92.firebasestorage.app",
          messagingSenderId: "746081289247",
          appId: "1:746081289247:web:b4d5d6d8117a89eb8b012a",
          measurementId: "G-TL3CJCP9JX",
        ),
      );
      // Tắt persistence trên Web để tránh lỗi 'unavailable'
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
      );
    } else {
      // Khởi tạo mặc định cho Android/iOS (dùng file json/plist)
      await Firebase.initializeApp();
    }
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'The Sanctuary',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
