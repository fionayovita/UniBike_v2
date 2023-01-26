import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/ui/login_page.dart';
import 'package:unibike/widgets/appbar.dart';

class ProfilePage extends StatefulWidget {
  static const routeName = 'profile_page';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final firebase = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  FirebaseStorage storage = FirebaseStorage.instance;
  var _image;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(text: "Profile"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth <= 700) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17.0, vertical: 20.0),
                    child: _profilePage(context));
              } else if (constraints.maxWidth <= 1100) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100.0, vertical: 20.0),
                    child: _profilePage(context));
              } else {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 550.0, vertical: 20.0),
                    child: _profilePage(context));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _profilePage(BuildContext context) {
    String text = 'nama';
    String currentUser = firebase.currentUser!.uid.toString();
    var width = MediaQuery.of(context).size.width;

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc('$currentUser').get(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Text("Document does not exist");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          var nama = data['nama'];
          text = nama;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                color: secondaryColor,
                width: width,
                height: width,
                child: Stack(
                  children: <Widget>[
                    FutureBuilder<String>(
                      future: loadImage(),
                      builder:
                          (BuildContext context, AsyncSnapshot<String> image) {
                        if (image.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: Icon(
                              Icons.person,
                              color: primaryColor,
                              size: 200,
                            ),
                          );
                        }
                        if (image.hasError) {
                          return Center(
                              child: Text('Failed to load picture',
                                  style:
                                      Theme.of(context).textTheme.subtitle1));
                        }
                        if (image.hasData) {
                          return Image.network(
                            image.data.toString(),
                            fit: BoxFit.cover,
                            width: width,
                            height: width,
                          );
                        } else {
                          return Text('No Picture',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1); // placeholder
                        }
                      },
                    ),
                    Positioned(
                      top: 10.0,
                      left: 10.0,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((builder) => popUpOption()),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 15),
                          child: CircleAvatar(
                            backgroundColor: mediumBlue,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back, color: primaryColor),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20.0,
                      right: 20.0,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: ((builder) => popUpOption()),
                          );
                        },
                        child: Icon(
                          Icons.camera_alt,
                          color: primaryColor,
                          size: 28.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 25.0),
              Center(
                child: Text(
                  '${data['nama']}',
                  style: TextStyle(
                      fontSize: 28.0,
                      color: darkPrimaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                width: width,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                    color: whiteBackground,
                    borderRadius: BorderRadius.circular(15.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email: ',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: greyOutline,
                      ),
                    ),
                    Text(
                      '${data['email']}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'NPM: ',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: greyOutline,
                      ),
                    ),
                    Text(
                      '${data['npm']}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Program Studi: ',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: greyOutline,
                      ),
                    ),
                    Text(
                      '${data['prodi']}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Fakultas: ',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: greyOutline,
                      ),
                    ),
                    Text(
                      '${data['fakultas']}',
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              MaterialButton(
                child: Text('Log Out',
                    style: Theme.of(context).textTheme.headline6),
                color: secondaryColor,
                height: 53,
                minWidth: width,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onPressed: () async {
                  await firebase.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginPage.routeName,
                    (route) => false,
                  );
                },
              ),
            ],
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget popUpOption() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          Text('Pilih Foto Profile',
              style: Theme.of(context).textTheme.headline5),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    takePhoto(ImageSource.camera);
                    loadImage();
                    print(_image);
                    Navigator.pop(context);
                  });
                },
                icon: Icon(Icons.camera_alt),
                label: Text('Camera'),
              ),
              SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    takePhoto(ImageSource.gallery);
                    loadImage();
                    print(_image);
                    Navigator.pop(context);
                  });
                },
                icon: Icon(Icons.photo_size_select_actual_outlined),
                label: Text('Gallery'),
              )
            ],
          )
        ],
      ),
    );
  }

  Future<void> uploadFile() async {
    String currentUser = firebase.currentUser!.uid.toString();
    try {
      await FirebaseStorage.instance
          .ref()
          .child('profile_picture')
          .child('$currentUser')
          .putFile(_image);

      print('current user: $currentUser');
      setState(() {
        loadImage();
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<String>? loadImage() async {
    String currentUser = firebase.currentUser!.uid.toString();
    print('current user: $currentUser');
    var url = null ??
        'https://firebasestorage.googleapis.com/v0/b/unibike-13780.appspot.com/o/profile_picture%2Favatar.png?alt=media&token=ee107873-773f-4683-b2f7-572c16e1a494';
    try {
      Reference ref = await FirebaseStorage.instance
          .ref()
          .child('profile_picture')
          .child('$currentUser');

      url = await ref.getDownloadURL();
      print('url foto profile: $url');
    } on FirebaseException catch (e) {
      Text('error loading picture');
      print(e);
    }
    return url;
  }

  void takePhoto(ImageSource source) async {
    var pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        print(_image);
        uploadFile();
        loadImage();
      });
    }
  }
}
