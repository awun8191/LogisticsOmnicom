import 'package:flutter/material.dart';
import 'package:logistics/presentation/screens/auth/signin_page.desktop.dart';
import 'package:logistics/presentation/screens/auth/signin_page.mobile.dart';
import 'package:logistics/presentation/widgets/app_layout.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(desktop: DesktopSignINPage(), mobile: MobileSignInPage());
  }
}
