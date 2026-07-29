import 'package:flutter/material.dart';

class ClientSignUpForm extends StatelessWidget {
  const ClientSignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey("client"),
      children: [
        Text("Client Sign Up"),
      ],
    );
  }
}