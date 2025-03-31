import 'package:eos_advance_login/screens/home_screen.dart';
import 'package:eos_advance_login/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eos_advance_login/theme/res/palette.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:eos_advance_login/theme/light_theme.dart';
import 'package:eos_advance_login/theme/foundation/app_theme.dart';
import 'package:provider/provider.dart';

/// 로그인 화면 - 이메일 로그인과 소셜 로그인 기능 제공
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late final AppTheme theme = LightTheme();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: theme.color.surface,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.only(top: 40, bottom: 24),
                            child: Image.asset(
                              'assets/images/eos_logo.png',
                              width: 360,
                              height: 144,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTextField(
                                  controller: _emailController,
                                  labelText: '이메일',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _passwordController,
                                  labelText: '비밀번호',
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: !_isPasswordVisible,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: theme.color.subtext,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildButton(
                                  text: '로그인',
                                  onPressed: () => _handleEmailLogin(context),
                                  backgroundColor: theme.color.primary,
                                  textColor: theme.color.onPrimary,
                                ),
                                const SizedBox(height: 16),
                                _buildAccountActions(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Material(
                    elevation: 0,
                    color: theme.color.surface,
                    child: _buildSocialLoginSection(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: theme.typo.body1,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: theme.typo.subtitle2.copyWith(color: theme.color.subtext),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.color.hint, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.color.inactive, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.color.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.color.background.withOpacity(0.3),
        prefixIcon: Icon(prefixIcon, color: theme.color.primary),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    Widget? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: backgroundColor == theme.color.surface
                ? BorderSide(color: theme.color.inactiveContainer, width: 1)
                : BorderSide.none,
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: theme.typo.subtitle1.copyWith(
                      color: textColor,
                      fontWeight: theme.typo.medium,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: theme.typo.subtitle1.copyWith(color: textColor),
              ),
      ),
    );
  }

  Widget _buildAccountActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => _resetPassword(context),
          child: Text(
            '비밀번호 재설정',
            style: theme.typo.body1.copyWith(color: theme.color.subtext),
          ),
        ),
        Container(
          height: 16,
          width: 1,
          color: theme.color.hint,
          margin: const EdgeInsets.symmetric(horizontal: 8),
        ),
        TextButton(
          onPressed: () {
            Provider.of<AuthService>(context, listen: false).signUp(
              email: _emailController.text,
              password: _passwordController.text,
              onSuccess: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
              onError: (err) {
                _showLoginMessage(context, '이메일');
              },
            );
          },
          child: Text(
            '회원가입',
            style: theme.typo.body1.copyWith(
              color: theme.color.primary,
              fontWeight: theme.typo.semiBold,
            ),
          ),
        ),
      ],
    );
  }

  void _resetPassword(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('비밀번호 재설정'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(hintText: '이메일 입력'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: emailController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('재설정 이메일을 보냈습니다.')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('오류 발생: ${e.toString()}')),
                );
              }
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: theme.color.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: Divider(color: theme.color.hint)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '간편 로그인',
                  style: theme.typo.body1.copyWith(color: theme.color.hint),
                ),
              ),
              Expanded(child: Divider(color: theme.color.hint)),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSocialButton(
                text: '카카오로 로그인',
                onPressed: () => _handleKakaoLogin(context),
                backgroundColor: const Color(0xFFFEE500),
                textColor: Colors.black,
                iconPath: 'assets/icons/kakao_logo.svg',
              ),
              const SizedBox(height: 12),
              _buildSocialButton(
                text: '구글로 로그인',
                onPressed: () => _handleGoogleLogin(context),
                backgroundColor: theme.color.surface,
                textColor: theme.color.text,
                iconPath: 'assets/icons/google_logo.svg',
              ),
              const SizedBox(height: 12),
              _buildSocialButton(
                text: '애플로 로그인',
                onPressed: () => _handleAppleLogin(context),
                backgroundColor: Colors.black,
                textColor: Colors.white,
                iconPath: 'assets/icons/apple_logo.svg',
                iconColor: Colors.white,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              'ⓘ 로그인하면 이용약관 및 개인정보활용에 동의하게 됩니다.',
              textAlign: TextAlign.center,
              style: theme.typo.body2.copyWith(
                color: theme.color.onHintContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
    required String iconPath,
    Color? iconColor,
  }) {
    return _buildButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      textColor: textColor,
      icon: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
        colorFilter: iconColor != null
            ? ColorFilter.mode(iconColor, BlendMode.srcIn)
            : null,
      ),
    );
  }

  void _handleEmailLogin(BuildContext context) {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요.')),
      );
      return;
    }

    final bool isEmailValid = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text);
    if (!isEmailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 이메일 형식이 아닙니다.')),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비밀번호는 6자 이상이어야 합니다.')),
      );
      return;
    }

    Provider.of<AuthService>(context, listen: false).signIn(
      email: _emailController.text,
      password: _passwordController.text,
      onSuccess: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 성공!')),
        );
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 실패: $err')),
        );
      },
    );
  }

  void _handleKakaoLogin(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    await authService.signInWithKakao(
      onSuccess: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 성공!')),
        );
      },
      onError: (err) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('카카오 로그인 실패: $err')),
        );
      },
    );
  }

  void _handleGoogleLogin(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    await authService.signInWithGoogle(
      onSuccess: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구글 로그인 성공!')),
        );
      },
      onError: (err) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구글 로그인 실패: $err')),
        );
      },
    );
  }

  void _handleAppleLogin(BuildContext context) {
    _showLoginMessage(context, '애플');
  }

  void _showLoginMessage(BuildContext context, String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$provider 로그인 시도 중...')),
    );
  }
}
