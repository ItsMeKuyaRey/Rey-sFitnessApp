// lib/features/auth/presentation/register_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _register() async {
    if (_name.text.trim().isEmpty || _email.text.trim().isEmpty || _pass.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields – password 6+ chars")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // THIS WILL NOW WORK because Email/Password is enabled
      UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _pass.text.trim(),
      );

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'role': 'client',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registered successfully!"), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? "Unknown error";
      if (e.code == 'email-already-in-use') msg = "Email already exists";
      if (e.code == 'weak-password') msg = "Password too weak";
      if (e.code == 'operation-not-allowed') msg = "Email/Password sign-in is disabled in Firebase console!";

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
    ),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.fitness_center, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 20),
          const Text('Join FitTrack', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          TextField(controller: _name, decoration: const InputDecoration(labelText: "Name", prefixIcon: Icon(Icons.person), border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email), border: OutlineInputBorder())),
          const SizedBox(height: 16),
          TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: "Password (6+ chars)", prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _register,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text("CREATE ACCOUNT", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}