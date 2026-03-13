import 'package:cinemanic/services/auth_service.dart';
import 'package:cinemanic/utils/constants.dart';
import 'package:cinemanic/widgets/profile_screen_widgets/logout_button_widget.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  AuthService().currentUser!.photoURL!,
                ),
              ),
              Text(
                AuthService().currentUser!.displayName!,
                style: KTextStyle.headingTextStyle,
              ),
              LogoutButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
