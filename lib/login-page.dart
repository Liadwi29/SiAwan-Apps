import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:presensi/home-page.dart';
import 'package:http/http.dart' as myHttp;
import 'package:presensi/models/login-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:presensi/models/cons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Future<String> _name, _token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
    checkToken(_token, _name);
  }

  checkToken(token, name) async {
    String tokenStr = await token;
    String nameStr = await name;
    if (tokenStr != "" && nameStr !="") {
      Future.delayed(Duration(seconds: 1), () async {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => HomePage()))
            .then((value) {
              setState(() {
              });
        });
      });
    }
  }

  Future login(email, password) async {
    LoginResponseModel? loginResponseModel;
    Map<String, String> body = {"email": email, "password": password};
    var response = await myHttp.post(
      Uri.parse('$BASE_URL/api/login'),
      body: body);
    if (response.statusCode == 401) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Email dan password salah!!")));
    }  else {
      loginResponseModel = LoginResponseModel.fromJson(json.decode(response.body));
      print('HASIL' +response.body);
      saveUser(loginResponseModel.data.token, loginResponseModel.data.name, loginResponseModel.data.email);
    }
  }

  Future saveUser(token, name,email) async {
    try {
      print("LEWAT SINI" + token + " | " +name);
      final SharedPreferences pref = await _prefs;
      pref.setString("name", name);
      pref.setString("token", token);
      pref.setString("email", email);
      Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => const HomePage()))
    .then((value) {
      setState(() { });
    });
    } catch (err) {
      print('ERROR:' + err.toString());
      ScaffoldMessenger.of(context)
    .showSnackBar(SnackBar(content: Text(err.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Center(child: Text("Login")),
                const SizedBox(height: 20),
                const Text("Email"),
                TextField(
                  controller: emailController,
                ),
                const SizedBox(height: 20),
                const Text("Password"),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(onPressed: () {
                  login(emailController.text, passwordController.text);
                }, child: const Text("Masuk"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
