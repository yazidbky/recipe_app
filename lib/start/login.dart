import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recipe_app/Cubits/login%20cubit/login_cubit.dart';
import 'package:recipe_app/Cubits/login%20cubit/login_state.dart';
import 'package:recipe_app/constants/colors.dart';
import 'package:recipe_app/components/custom_text_field.dart';
import 'package:recipe_app/components/navigation_bar.dart';
import 'package:recipe_app/start/register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome Back!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text('Please enter your account here',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  )),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: CustomTextField(
                  controller: emailController,
                  hintText: 'Email',
                  prefixIcon: Icon(
                    Icons.email,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10),
                child: CustomTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  obscureText: _obscureText,
                ),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  child: BlocConsumer<LoginCubit, LoginState>(
                    // In your login screen's BlocConsumer
                    listener: (context, state) async {
                      if (state is LoginFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message)),
                        );
                      }
                      if (state is LoginSuccess) {
                        // Ensure we have a valid userId before proceeding
                        if (state.userId.isNotEmpty) {
                          // Store the user ID in SharedPreferences
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString('user_id', state.userId);

                          // Navigate to home and fetch user data
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NavBar(userId: state.userId),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("Login failed - no user ID received")),
                          );
                        }
                      }
                    },
                    builder: (context, state) {
                      return MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        color: primaryColor,
                        onPressed: () {
                          context.read<LoginCubit>().loginUser(
                              emailController.text, passwordController.text);
                        },
                        child: state is LoginLoading
                            ? CircularProgressIndicator()
                            : Text(
                                'Login',
                                style: TextStyle(color: Colors.white),
                              ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text('or continue with',
                  style: TextStyle(fontSize: 15, color: Colors.grey)),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                  width: double.infinity,
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
                    color: secondaryColor,
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Google',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don’t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Register()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(color: primaryColor),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
