import "package:flutter/material.dart";

import "dart:convert";
import "package:http/http.dart" as http;
import "package:shared_preferences/shared_preferences.dart";

import "package:frontend/config.dart";
import "package:frontend/components/button0.dart";
import "package:frontend/components/text_input.dart";
import "package:frontend/components/theme_button.dart";

class LoginPage extends StatefulWidget {
  final void Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController unameInputController = TextEditingController();
  final TextEditingController passInputController = TextEditingController();

  Future<void> loginUser() async {
    final response = await http.post(
      Uri.parse('$baseURL/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': unameInputController.text,
        'password': passInputController.text,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setString("user", unameInputController.text);

      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Failed")));
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.message,
            size: 60,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 50),
          Text(
            "Welcome back, Nice to see you again!",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(height: 25),
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
          Button0(
            label: "Login",
            onTap: loginUser,
            //
          ),
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Not a Member ? ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (widget.onTap != null) {
                    widget.onTap!();
                  }
                },
                child: Text(
                  "Register Now",
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
    passInputController.dispose();
    super.dispose();
  }
}
