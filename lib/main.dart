import 'package:eos_advance_login/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:eos_advance_login/screens/login_screen.dart';
import 'package:eos_advance_login/theme/light_theme.dart';
import 'package:eos_advance_login/theme/foundation/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*
 * Firebase 설정 및 초기화 - 완료
 * - Firebase 프로젝트 생성 및 설정 완료
 * - 필요한 패키지 설치 완료
 * - Firebase 초기화 구현 완료
 */

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

/// 애플리케이션의 루트 위젯
/// - 앱의 전체 테마 및 초기 화면을 설정합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppTheme theme = LightTheme();

    /*
     * 인증 상태 관리 - 완료
     * - FirebaseAuth.instance.authStateChanges()로 로그인 상태 모니터링
     * - 로그인 상태: HomeScreen 표시
     * - 로그아웃 상태: LoginScreen 표시
     */

    return MaterialApp(
      title: 'EOS Advance Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: theme.color.primary),
        useMaterial3: true,
        fontFamily: 'Pretendard', // 프리텐다드 폰트 기본 적용
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
    );
  }
}
