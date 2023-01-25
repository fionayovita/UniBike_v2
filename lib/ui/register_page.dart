import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unibike/common/styles.dart';

class RegisterPage extends StatefulWidget {
  static const String routeName = 'register_page';

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _namaController = TextEditingController();
  final _npmController = TextEditingController();
  final _prodiController = TextEditingController();
  final _fakultasController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscureText = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkPrimaryColor,
      body: SingleChildScrollView(
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
    );
  }

  Widget _textField(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _isLoading ? Center(child: CircularProgressIndicator()) : Container(),
          Hero(
            tag: 'UniBike',
            child: Text(
              'UniBike',
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          SizedBox(height: 24.0),
          Text(
            'Buat akun baru',
            style: Theme.of(context).textTheme.subtitle2,
          ),
          SizedBox(height: 8.0),
          TextFormField(
            style: TextStyle(color: primaryColor),
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
              hintText: 'Email',
              hintStyle: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            style: TextStyle(color: primaryColor),
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
              hintText: 'Kata Sandi',
              hintStyle: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            style: TextStyle(color: primaryColor),
            controller: _namaController,
            validator: (text) {
              if (text != null && text.isNotEmpty) {
                return null;
              } else {
                return 'Nama tidak boleh kosong!';
              }
            },
            decoration: InputDecoration(
              hintText: 'Nama',
              hintStyle: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            style: TextStyle(color: primaryColor),
            controller: _npmController,
            validator: (text) {
              if (text != null && text.isNotEmpty) {
                return null;
              } else {
                return 'NPM tidak boleh kosong!';
              }
            },
            decoration: InputDecoration(
              hintText: 'NPM',
              hintStyle: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            style: TextStyle(color: primaryColor),
            controller: _prodiController,
            validator: (text) {
              if (text != null && text.isNotEmpty) {
                return null;
              } else {
                return 'Program Studi tidak boleh kosong!';
              }
            },
            decoration: InputDecoration(
              hintText: 'Program Studi',
              hintStyle: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          SizedBox(height: 8.0),
          TextFormField(
            style: TextStyle(color: primaryColor),
            controller: _fakultasController,
            keyboardType: TextInputType.emailAddress,
            validator: (text) {
              if (text != null && text.isNotEmpty) {
                return null;
              } else {
                return 'Fakultas tidak boleh kosong!';
              }
            },
            decoration: InputDecoration(
              hintText: 'Fakultas',
              hintStyle: Theme.of(context).textTheme.subtitle2,
            ),
          ),
          SizedBox(height: 24.0),
          MaterialButton(
            child: Text('Daftar'),
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
                final nama = _namaController.text;
                final npm = _npmController.text;
                final prodi = _prodiController.text;
                final fakultas = _fakultasController.text;

                await _auth.createUserWithEmailAndPassword(
                    email: email, password: password);

                _store.collection('users').doc(_auth.currentUser?.uid).set({
                  'email': email,
                  'password': password,
                  'nama': nama,
                  'npm': npm,
                  'prodi': prodi,
                  'fakultas': fakultas
                });
                Navigator.pop(context);
              } catch (e) {
                final snackbar = SnackBar(content: Text(e.toString()));
                ScaffoldMessenger.of(context).showSnackBar(snackbar);
              } finally {
                setState(
                  () {
                    _isLoading = false;
                  },
                );
              }
            },
          ),
          TextButton(
            child: Text('Sudah punya akun? Login',
                style: TextStyle(color: secondaryColor)),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
