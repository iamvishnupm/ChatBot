import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "dart:convert";

import "package:frontend/config.dart";
import "package:frontend/components/theme_button.dart";
import "package:frontend/components/text_input.dart";
import "package:frontend/components/button0.dart";

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController unameInputController = TextEditingController();
  final TextEditingController emailInputController = TextEditingController();
  final TextEditingController passInputController = TextEditingController();

  Future<void> registerUser() async {
    final response = await http.post(
      Uri.parse('$baseURL/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': unameInputController.text,
        'email': emailInputController.text,
        'password': passInputController.text,
      }),
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Register Failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [ThemeButton()],
        //
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),

          SizedBox(height: 25),

          Text(
            "Let's setup an account for you!",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),

          SizedBox(height: 25),

          TextInputField(
            hintText: "Email",
            obscureText: false,
            controller: emailInputController,
            //
          ),

          SizedBox(height: 10),

          TextInputField(
            hintText: "Username",
            obscureText: false,
            controller: unameInputController,
            //
          ),

          SizedBox(height: 10),

          TextInputField(
            hintText: "Password",
            obscureText: true,
            controller: passInputController,
            //
          ),

          SizedBox(height: 25),

          Button0(label: "Register", onTap: registerUser),

          SizedBox(height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Already have an account ? ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  //
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }
                },
                child: Text(
                  "Login",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    unameInputController.dispose();
    emailInputController.dispose();
    passInputController.dispose();
    super.dispose();
  }
}
