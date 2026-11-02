import 'package:flutter/material.dart';
import '../repository.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoggedIn;
  const LoginScreen({super.key, required this.onLoggedIn});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  bool _otpSent = false;
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    if (!_otpSent) {
      final ok = await repo.sendOtp(_phone.text.trim());
      setState(() {
        _busy = false;
        _otpSent = ok;
        _error = ok ? null : 'Sahi 10-digit mobile number daalo';
      });
    } else {
      final ok = await repo.verifyOtp(_phone.text.trim(), _otp.text.trim());
      if (ok) {
        widget.onLoggedIn();
      } else {
        setState(() {
          _busy = false;
          _error = '6-digit OTP daalo';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Image.asset('assets/logo.png', height: 170)),
              const SizedBox(height: 8),
              const Center(child: Text('Manager', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: TB.greenDark))),
              const SizedBox(height: 6),
              const Center(child: Text('Apne saare ventures ek hi app mein sambhalo', style: TextStyle(color: TB.muted), textAlign: TextAlign.center)),
              const SizedBox(height: 32),
              TextField(
                controller: _phone,
                enabled: !_otpSent,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: const InputDecoration(hintText: 'Mobile number', prefixText: '+91  ', counterText: ''),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _otp,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(hintText: '6-digit OTP', counterText: ''),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!, style: const TextStyle(color: TB.red)),
              ],
              const SizedBox(height: 20),
              BigButton(label: _otpSent ? 'Verify karke aage badho' : 'OTP bhejo', busy: _busy, onPressed: _submit),
              const SizedBox(height: 24),
              const Center(child: Text('Demo mode: koi bhi 10-digit number aur 6-digit OTP chalega', style: TextStyle(color: TB.muted, fontSize: 12), textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}
