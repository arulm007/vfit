import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../main_tab/main_tab_view.dart';

class WelcomeView extends StatefulWidget {
  final int userId;
  const WelcomeView({super.key, required this.userId});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  String firstName = "";

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  Future<void> fetchUserDetails() async {
    final response = await http.post(
      Uri.parse('http://172.25.91.241/fitness/get_user_details.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'id': widget.userId.toString(),
      }),
    );

    final responseData = jsonDecode(response.body);

    if (responseData['status'] == 'success') {
      setState(() {
        firstName = responseData['data']['first_name'];
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Container(
          width: media.width,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: media.width * 0.1,
              ),
              Image.asset(
                "assets/img/welcome.png",
                width: media.width * 0.75,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
              Text(
                "Welcome, $firstName",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                "You are all set now, let’s reach your\ngoals together with us",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.gray, fontSize: 12),
              ),
              const Spacer(),
              RoundButton(
                  title: "Go To Home",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MainTabView(userId: widget.userId)));
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
