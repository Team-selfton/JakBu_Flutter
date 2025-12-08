import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../models/auth_models.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLoginComplete;

  const AuthScreen({super.key, required this.onLoginComplete});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _accountIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(ApiClient());
  }

  @override
  void dispose() {
    _accountIdController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_accountIdController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError('Account ID와 비밀번호를 입력해주세요');
      return;
    }

    if (!_isLogin && _nameController.text.trim().isEmpty) {
      _showError('이름을 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _authService.login(
          LoginRequest(
            accountId: _accountIdController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        );
      } else {
        await _authService.signup(
          SignupRequest(
            accountId: _accountIdController.text.trim(),
            password: _passwordController.text.trim(),
            name: _nameController.text.trim(),
          ),
        );
      }
      if (mounted) {
        widget.onLoginComplete();
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1e2a3f),
              Color(0xFF1a2332),
              Color(0xFF0f1520),
            ],
          ),
        ),
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Logo and Title
                      const Text(
                        '👊',
                        style: TextStyle(fontSize: 72),
                      ),
                      const SizedBox(height: 16),
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF6b9bd8), Color(0xFF5b8dd5)],
                        ).createShader(bounds),
                        child: const Text(
                          'JakBu',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '작심삼일 부수기',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Auth Form Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Column(
                          children: [
                            // Login/Signup Toggle
                            Row(
                              children: [
                                Expanded(
                                  child: _buildToggleButton('로그인', true),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildToggleButton('회원가입', false),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Form Fields
                            if (!_isLogin) ...[
                              _buildTextField(
                                controller: _nameController,
                                hintText: '이름',
                                textInputType: TextInputType.name,
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildTextField(
                              controller: _accountIdController,
                              hintText: 'Account ID',
                              textInputType: TextInputType.text,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              hintText: '비밀번호',
                              obscureText: true,
                            ),
                            const SizedBox(height: 24),

                            // Submit Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF5b8dd5), Color(0xFF4a7bc0)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5b8dd5).withValues(alpha: 0.5),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _isLoading ? null : _handleSubmit,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _isLogin ? '로그인' : '회원가입',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Text
              Text(
                '로그인하면 서비스 약관에 동의하게 됩니다',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isLoginButton) {
    final isActive = _isLogin == isLoginButton;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isLogin = isLoginButton;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF5b8dd5), Color(0xFF4a7bc0)],
                )
              : null,
          color: isActive ? null : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF5b8dd5).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType textInputType = TextInputType.text,
  }) {
    return Material(
      color: Colors.transparent,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: textInputType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
          ),
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF5b8dd5),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}
