import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.veryLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    const SizedBox(height: 48),
                    const SanadLogo(size: 100),
                    const SizedBox(height: 12),
                    const Text('Sanad', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: Color(0xFF5E86B5))),
                    const Text('Smart Support. Safer Tomorrow.', style: TextStyle(color: C.text2)),
                    const SizedBox(height: 24),
                    const Text('AI-powered smart cane for\nfall detection and emergency alerts.', textAlign: TextAlign.center, style: TextStyle(color: C.text2, height: 1.5)),
                    const SizedBox(height: 28),
                    const _CaneIllustration(),
                  ]),
                ),
              ),
              PrimaryButton('Get Started', onPressed: () => Navigator.pushNamed(context, '/signup')),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('I already have an account', style: TextStyle(color: C.text2))),
            ]),
          ),
        ),
      );
}

class _CaneIllustration extends StatelessWidget {
  const _CaneIllustration();
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Illustration of a smart cane',
        child: SizedBox(
          height: 190,
          child: Stack(alignment: Alignment.center, children: [
            Container(width: 190, height: 190, decoration: const BoxDecoration(color: C.softBlue, shape: BoxShape.circle)),
            const Positioned(left: 70, bottom: 10, child: Icon(Icons.eco_rounded, color: C.green, size: 56)),
            Transform.rotate(angle: .12, child: Container(width: 14, height: 170, decoration: BoxDecoration(color: const Color(0xFF51647F), borderRadius: BorderRadius.circular(8)))),
            const Positioned(right: 80, top: 28, child: Icon(Icons.wifi_rounded, color: C.blue, size: 34)),
            Positioned(top: 40, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: C.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
          ]),
        ),
      );
}

class AuthScreen extends StatefulWidget {
  final bool signup;
  const AuthScreen({super.key, this.signup = false});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _id = TextEditingController(), _pw = TextEditingController(), _name = TextEditingController();
  bool _hide = true, _remember = true;
  String? _err;

  void _submit() {
    // Phase 4: replace with FirebaseAuth.signInWithEmailAndPassword / createUserWithEmailAndPassword.
    if (_id.text.trim().isEmpty || _pw.text.length < 4 || (widget.signup && _name.text.trim().isEmpty)) {
      setState(() => _err = 'Please fill in all fields (password: 4+ characters).');
      return;
    }
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.signup;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(padding: const EdgeInsets.symmetric(horizontal: 24), children: [
              const Center(child: SanadLogo(size: 64)),
              const Center(child: Text('Sanad', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF5E86B5)))),
              const SizedBox(height: 24),
              Text(s ? 'Create account' : 'Welcome back!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
              Text(s ? 'Sign up to start monitoring' : 'Log in to your account', style: const TextStyle(color: C.text2)),
              const SizedBox(height: 20),
              if (s) ...[
                TextField(controller: _name, decoration: const InputDecoration(hintText: 'Full name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 14),
              ],
              TextField(controller: _id, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(hintText: 'Email or phone number', prefixIcon: Icon(Icons.mail_outline))),
              const SizedBox(height: 14),
              TextField(
                controller: _pw, obscureText: _hide,
                decoration: InputDecoration(hintText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(tooltip: 'Show or hide password', icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _hide = !_hide))),
              ),
              if (_err != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_err!, style: const TextStyle(color: C.red, fontSize: 13))),
              if (!s)
                Row(children: [
                  Checkbox(value: _remember, activeColor: C.blue, onChanged: (v) => setState(() => _remember = v ?? false)),
                  const Text('Remember me', style: TextStyle(fontSize: 13)),
                  const Spacer(),
                  TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset arrives with Firebase Auth (Phase 4).'))), child: const Text('Forgot password?')),
                ])
              else
                const SizedBox(height: 16),
              PrimaryButton(s ? 'Sign Up' : 'Log In', onPressed: _submit),
              const SizedBox(height: 20),
              const Center(child: Text('Or continue with', style: TextStyle(color: C.text2, fontSize: 13))),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(child: _Social('Google', Icons.g_mobiledata_rounded, _submit)),
                const SizedBox(width: 12),
                Expanded(child: _Social('Apple', Icons.apple, _submit)),
              ]),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, s ? '/login' : '/signup'),
                  child: Text.rich(TextSpan(text: s ? 'Already have an account? ' : "Don't have an account? ", style: const TextStyle(color: C.text2), children: [
                    TextSpan(text: s ? 'Log In' : 'Sign Up', style: const TextStyle(color: Color(0xFF3F7FC4), fontWeight: FontWeight.w600)),
                  ])),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class _Social extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _Social(this.label, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onTap, icon: Icon(icon, size: 26, color: C.text), label: Text(label, style: const TextStyle(color: C.text)),
          style: OutlinedButton.styleFrom(side: const BorderSide(color: C.border), backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
        ),
      );
}
