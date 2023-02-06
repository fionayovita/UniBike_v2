import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/function/kembalikan_sepeda.dart';
import 'package:unibike/ui/status_pinjam_page.dart';
import 'package:unibike/widgets/custom_dialog.dart';

class BottomSheetWidget extends StatefulWidget {
  String fakultasState = '';
  bool statusPinjam = false;
  final Function onPressedPinjam;

  BottomSheetWidget({required this.onPressedPinjam});

  @override
  _BottomSheetState createState() => _BottomSheetState();
}

class _BottomSheetState extends State<BottomSheetWidget> {
  final firebase = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  var dataSnapshot;
  final CollectionReference dataPeminjaman =
      FirebaseFirestore.instance.collection('data_peminjaman');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  String? fakultas;
  List _listFakultas = [
    "Teknik",
    "MIPA",
    "Ekonomi",
    "Kedokteran",
    "Pertanian",
    "Keguruan dan Ilmu Pendidikan",
    "Ilmu Sosial dan Pemerintahan",
    "Hukum"
  ];
  late final StreamSubscription<DocumentSnapshot> _subscription;
  List _fakultasDb = ["ft", "fmipa", "feb", "fk", "fp", "fkip", "fisip", "fh"];
  Timer? countdownTimer;
  var myDuration = Duration(seconds: 0);
  var sisaJamUpdated;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    checkIfDocExists();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
      if (result != ConnectivityResult.none) {
        // dataLoadFunction();
      }
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status ${e}');
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  Future<int?> get getCountdownValue async {
    final prefs = await SharedPreferences.getInstance();
    var timestamp = prefs.getInt('countdownTimer');

    return timestamp;
  }

  Future<bool> checkIfDocExists() async {
    try {
      String currentUser = firebase.currentUser!.uid.toString();
      var doc = await dataPeminjaman.doc('$currentUser').get();
      final prefs = await SharedPreferences.getInstance();
      if (doc.exists) {
        final Stream<DocumentSnapshot> stream =
            dataPeminjaman.doc('$currentUser').snapshots();
        _subscription = stream.listen((data) {
          if (mounted) {
            var currentTime = DateTime.now();
            var timestamp = prefs.getInt('countdownTimer');
            DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp!);

            var sisaJamSplit = prefs.getString('sisa_jam')?.split(':');
            var sisaJamInDate = new DateTime(
                currentTime.year,
                currentTime.month,
                currentTime.day,
                int.parse(sisaJamSplit![0]),
                int.parse(sisaJamSplit[1]),
                0);
            Duration timeDifference = currentTime.difference(dateTime);
            var formattedTime = new DateTime(
                currentTime.year, currentTime.month, currentTime.day, 0, 0, 0);
            Duration sisajam = sisaJamInDate.difference(formattedTime);

            setState(() {
              dataSnapshot = data;
              myDuration = Duration(
                  seconds: timeDifference.inSeconds >= 5
                      ? timeDifference.inSeconds >= 14400
                          ? 0
                          : sisaJamSplit[0] != '4'
                              ? sisajam.inSeconds - timeDifference.inSeconds
                              : 14400 - timeDifference.inSeconds
                      : sisaJamSplit[0] != '4'
                          ? sisajam.inSeconds
                          : 14400);
            });

            startTimer();
          }
        });
      } else {
        return false;
      }
      return doc.exists;
    } catch (e) {
      print('error ${e}');
      // throw e;
      return false;
    }
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    if (this.mounted) {
      setState(() {
        final seconds = myDuration.inSeconds - reduceSecondsBy;
        if (seconds < 0) {
          countdownTimer!.cancel();
          print("the time stopped you are running out of time");
        } else {
          myDuration = Duration(seconds: seconds);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final hours = strDigits(myDuration.inHours.remainder(24));
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    String currentUser = firebase.currentUser!.uid.toString();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, StatusPinjamPage.routeName),
      child: Container(
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        height: 85,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Peminjaman sepeda anda",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  "Sisa Waktu:  $hours:$minutes:$seconds",
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 15),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: lightBlue),
                child: Text(
                  'Kembalikan',
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: primaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onPressed: KembalikanSepeda(
                        context: context,
                        data: dataSnapshot,
                        setState: setState,
                        currentUser: currentUser,
                        connectionStatus: _connectionStatus)
                    .mengembalikanSepeda),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
