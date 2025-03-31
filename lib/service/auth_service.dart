import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk_talk/kakao_flutter_sdk_talk.dart';
import 'package:http/http.dart' as http;

class AuthService extends ChangeNotifier {
  /// 현재 로그인된 사용자 반환
  firebase_auth.User? currentUser() {
    return firebase_auth.FirebaseAuth.instance.currentUser;
  }

  /// 이메일 회원가입
  void signUp({
    required String email,
    required String password,
    required Function() onSuccess,
    required Function(String err) onError,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      onError('이메일과 비밀번호를 입력해주세요.');
      return;
    }
    try {
      await firebase_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      onSuccess();
    } catch (e) {
      if (e is firebase_auth.FirebaseAuthException) {
        switch (e.code) {
          case 'email-already-in-use':
            onError('이미 사용 중인 이메일입니다.');
            break;
          case 'weak-password':
            onError('비밀번호가 너무 약합니다.');
            break;
          case 'invalid-email':
            onError('유효하지 않은 이메일 형식입니다.');
            break;
          default:
            onError('회원가입 중 오류 발생 (코드: ${e.code})');
            break;
        }
      } else {
        onError('회원가입 중 오류: ${e.toString()}');
      }
    }
  }

  /// 이메일 로그인
  void signIn({
    required String email,
    required String password,
    required Function() onSuccess,
    required Function(String err) onError,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      onError('이메일과 비밀번호를 입력해주세요.');
      return;
    }
    try {
      await firebase_auth.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      onSuccess();
    } catch (e) {
      if (e is firebase_auth.FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-email':
            onError('유효하지 않은 이메일 형식입니다.');
            break;
          case 'wrong-password':
            onError('비밀번호가 일치하지 않습니다.');
            break;
          case 'user-not-found':
            onError('존재하지 않는 이메일입니다.');
            break;
          default:
            onError('로그인 중 오류 발생 (코드: ${e.code})');
            break;
        }
      } else {
        onError('로그인 중 오류 발생.');
      }
    }
  }

  /// 로그아웃
  void signOut() async {
    await firebase_auth.FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    try {
      await UserApi.instance.logout();
    } catch (e) {
      // 카카오 로그인이 아닐 경우 에러 무시
    }
    notifyListeners();
  }

  /// Google 로그인 및 Firebase 연동
  Future<void> signInWithGoogle({
    required Function() onSuccess,
    required Function(String err) onError,
  }) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        onError('구글 로그인 취소됨');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await firebase_auth.FirebaseAuth.instance
          .signInWithCredential(credential);
      onSuccess();
    } catch (e) {
      onError('구글 로그인 실패: ${e.toString()}');
    }
  }

  /// Kakao 로그인 및 Firebase 연동 (Custom Token 방식)
  Future<void> signInWithKakao({
    required Function() onSuccess,
    required Function(String err) onError,
  }) async {
    try {
      OAuthToken token;

      // 카카오톡 설치 여부에 따라 로그인 방법 결정
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          // 사용자가 카카오톡 로그인을 취소한 경우
          if (e is PlatformException && e.code == 'CANCELED') {
            onError('카카오톡 로그인이 취소되었습니다.');
            return;
          }
          // 카카오톡 로그인 실패 → 카카오계정 로그인 시도
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final kakaoAccessToken = token.accessToken;

      // Firebase Functions 호출하여 커스텀 토큰 요청
      final response = await http.post(
        Uri.parse('https://YOUR_CLOUD_FUNCTION_URL/customToken'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': kakaoAccessToken}),
      );

      if (response.statusCode != 200) {
        onError('Firebase 커스텀 토큰 요청 실패: ${response.body}');
        return;
      }

      final customToken = jsonDecode(response.body)['firebase_token'];

      await firebase_auth.FirebaseAuth.instance
          .signInWithCustomToken(customToken);
      onSuccess();
    } catch (e) {
      onError('카카오 로그인 실패: ${e.toString()}');
    }
  }
}
