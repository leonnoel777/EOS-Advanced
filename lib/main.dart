import 'package:eos_advance_login/firebase_options.dart';
import 'package:eos_advance_login/screens/home_screen.dart';
import 'package:eos_advance_login/service/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:eos_advance_login/screens/login_screen.dart';
import 'package:eos_advance_login/theme/light_theme.dart';
import 'package:eos_advance_login/theme/foundation/app_theme.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// ✅ Kakao SDK 초기화 (네이티브 앱 키 입력)
  KakaoSdk.init(
      nativeAppKey: '81b5d20eb689889707f0fd3c4e56cb5f'); // ← 여기에 네이티브 앱 키 입력

  /// ✅ Firebase 초기화
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase 초기화 성공');
  } catch (e) {
    print('❗️ Firebase 초기화 오류: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

/// 앱 루트 위젯
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = LightTheme();

    return MaterialApp(
      title: 'EOS Advance Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: theme.color.primary),
        useMaterial3: true,
        fontFamily: 'Pretendard',
      ),
      home: StreamBuilder<firebase_auth.User?>(
        stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
