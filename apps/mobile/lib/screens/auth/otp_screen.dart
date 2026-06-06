import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../providers/app_provider.dart';
import '../../services/haptic_service.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  final VoidCallback onSuccess;

  const OtpScreen({super.key, required this.phone, required this.verificationId, required this.onSuccess});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _codes = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  late String _verificationId;
  bool _isVerifying = false;
  int _resendTime = 60;
  bool _canResend = false;
  Timer? _resendTimer;

  AuthService get _auth => context.read<AppProvider>().auth;

  @override
  void initState() {
    super.initState();
    _verificationId = widget.verificationId;
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final c in _codes) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTime = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendTime--);
      if (_resendTime <= 0) {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  Future<void> _verify() async {
    final code = _codes.map((c) => c.text).join();
    if (code.length != 6) return;
    setState(() => _isVerifying = true);
    try {
      await _auth.verifyOtp(_verificationId, code);
      if (mounted) widget.onSuccess();
    } on FirebaseAuthException catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Invalid OTP'),
            backgroundColor: AppColors.bgOverlay,
          ),
        );
      }
    } catch (e) {
      setState(() => _isVerifying = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.bgOverlay),
        );
      }
    }
  }

  Future<void> _resend() async {
    if (!_canResend) return;
    try {
      await _auth.sendOtp(
        '+91${widget.phone}',
        onCodeSent: (verId, _) {
          _verificationId = verId;
        },
      );
      _startResendTimer();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.bgOverlay),
        );
      }
    }
  }

  String _formatPhone() {
    final p = widget.phone;
    if (p.length >= 10) return '+91 ${p.substring(0, 5)} ${p.substring(5)}';
    return '+91 $p';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.videocam, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 32),
              const Text('Enter OTP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Sent to ${_formatPhone()}', style: const TextStyle(fontSize: 15, color: AppColors.foregroundSecondary)),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) => SizedBox(
                  width: 48, height: 56,
                  child: TextField(
                    controller: _codes[i],
                    focusNode: _focusNodes[i],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                    ),
                    onChanged: (v) {
                      if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                      if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                      if (v.isNotEmpty && i == 5) _verify();
                    },
                  ),
                )),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : () { HapticService.trigger(HapticLevel.medium); _verify(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isVerifying
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Verify', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Didn't receive?", style: TextStyle(fontSize: 13, color: AppColors.foregroundSecondary)),
                    TextButton(
                      onPressed: _canResend ? () { HapticService.trigger(HapticLevel.light); _resend(); } : null,
                      child: Text(
                        _canResend ? 'Resend' : 'Resend in ${_resendTime}s',
                        style: TextStyle(
                          fontSize: 13,
                          color: _canResend ? AppColors.primary : AppColors.foregroundMuted,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
