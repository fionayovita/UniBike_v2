import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/ui/main_page.dart';
import 'package:unibike/widgets/custom_dialog.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login_page';

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: darkBlue,
        body: SafeArea(
            child: Stack(
          children: [
            Center(
              child: Image.asset(
                'assets/sepeda.png',
              ),
            ),
            SingleChildScrollView(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (constraints.maxWidth <= 700) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 20.0),
                        child: _textField(context));
                  } else if (constraints.maxWidth <= 1100) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 120.0, vertical: 20.0),
                        child: _textField(context));
                  } else {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 200.0, vertical: 20.0),
                        child: _textField(context));
                  }
                },
              ),
            ),
          ],
        )));
  }

  Widget _textField(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(bottom: 50.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UniBike,',
                          style: Theme.of(context).textTheme.headline1),
                      Text('get started',
                          style: Theme.of(context).textTheme.headline4),
                    ],
                  ),
                ),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Container(),
                SizedBox(height: 24.0),
                TextFormField(
                  style: Theme.of(context).textTheme.subtitle2,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (text) {
                    if (text != null && text.isNotEmpty) {
                      return null;
                    } else {
                      return 'Email tidak boleh kosong!';
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(
                      color: Colors.red,
                      wordSpacing: 5.0,
                    ),
                    hintText: 'Email',
                    hintStyle: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  style: Theme.of(context).textTheme.subtitle2,
                  cursorColor: primaryColor,
                  controller: _passwordController,
                  obscureText: _obscureText,
                  validator: (text) {
                    if (text != null && text.isNotEmpty) {
                      return null;
                    } else {
                      return 'Kata Sandi tidak boleh kosong!';
                    }
                  },
                  decoration: InputDecoration(
                    filled: true,
                    errorStyle: TextStyle(
                      color: Colors.red,
                      wordSpacing: 5.0,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    hintText: 'Kata Sandi',
                    hintStyle: Theme.of(context).textTheme.subtitle2,
                  ),
                ),
                SizedBox(height: 24.0),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                MaterialButton(
                  child: Text(
                    'Log In',
                    style: GoogleFonts.poppins(
                      textStyle: TextStyle(
                        color: lightBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  color: Theme.of(context).primaryColor,
                  textTheme: ButtonTextTheme.primary,
                  height: 53,
                  minWidth: MediaQuery.of(context).size.width,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                    });
                    try {
                      final email = _emailController.text;
                      final password = _passwordController.text;

                      await _auth.signInWithEmailAndPassword(
                          email: email, password: password);

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        MainPage.routeName,
                        (route) => false,
                      );

                      // Navigator.pushReplacementNamed(
                      //     context, MainPage.routeName);
                    } catch (e) {
                      final snackbar = SnackBar(
                        content: Text(e.toString()),
                      );
                      if (e.toString().contains('network-request-failed')) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                title: 'Login Gagal',
                                descriptions:
                                    'Tidak ada koneksi, mohon cek kembali koneksi anda.',
                                text: 'OK',
                              );
                            });
                      } else if (e.toString().contains('wrong-password') ||
                          e.toString().contains('invalid-email')) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                title: 'Login Gagal',
                                descriptions:
                                    'Gagal melakukan proses autentikasi, mohon cek kembali email dan password anda.',
                                text: 'OK',
                              );
                            });
                      } else if (e.toString().contains('user-not-found')) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return CustomDialog(
                                title: 'Login Gagal',
                                descriptions:
                                    'Maaf kami tidak dapat menemukan akun dengan email dan password yang anda masukkan.',
                                text: 'OK',
                              );
                            });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      }
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
