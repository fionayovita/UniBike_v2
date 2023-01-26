import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/model/bike_model2.dart';
import 'package:unibike/preferences/preferences_helper.dart';
import 'package:unibike/ui/status_pinjam_page.dart';

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

  @override
  void initState() {
    super.initState();
    checkIfDocExists();
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
            Duration timeDifference = currentTime.difference(dateTime);
            print(
                'is countdown timer has been a minute? ${currentTime} ${timestamp} datetime ${dateTime} ${timeDifference.inSeconds} ${timeDifference.inSeconds >= 14400}');
            setState(() {
              dataSnapshot = data;
              myDuration = Duration(
                  seconds: timeDifference.inSeconds >= 5
                      ? timeDifference.inSeconds >= 14400
                          ? 0
                          : 14400 - timeDifference.inSeconds
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
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(builder: (context, setState) {
                        return new SimpleDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                          title: new Text('Fakultas pengembalian sepeda:',
                              style: Theme.of(context).textTheme.headline5),
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              child: Container(
                                // width: MediaQuery.of(context).size.width - 250,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 17, vertical: 5),
                                decoration: BoxDecoration(
                                  color: secondaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.7),
                                      spreadRadius: 2,
                                      blurRadius: 3,
                                      offset: Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: ButtonTheme(
                                    child: DropdownButton(
                                      isExpanded: true,
                                      iconEnabledColor: primaryColor,
                                      dropdownColor: secondaryColor,
                                      hint: Text("Pilih Fakultas",
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle2),
                                      value: fakultas,
                                      items: _listFakultas.map(
                                        (value) {
                                          return DropdownMenuItem<String>(
                                            child: Text(value,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle2),
                                            value: value,
                                          );
                                        },
                                      ).toList(),
                                      onChanged: (String? value) {
                                        print(
                                            "fakultas ${fakultas} value $value");
                                        setState(
                                          () {
                                            fakultas = value as String ?? "";
                                            var idx =
                                                _listFakultas.indexOf(value);
                                            widget.fakultasState =
                                                _fakultasDb[idx];
                                          },
                                        );
                                        print("fakultass ${fakultas}");
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  child: Text(
                                    'Submit',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  ),
                                  onPressed: () async {
                                    var batasWaktu =
                                        dataSnapshot['waktu_kembali'].toDate();
                                    var waktuKembali = DateTime.now();
                                    var selisihJam =
                                        batasWaktu.difference(waktuKembali);
                                    var selisihJamNegatif = selisihJam
                                        .toString()
                                        .replaceAll(RegExp('-'), '');

                                    DateTime sisaJam = DateTime(
                                        waktuKembali.year,
                                        waktuKembali.month,
                                        batasWaktu.day,
                                        selisihJam.inHours % 24,
                                        selisihJam.inMinutes % 60);

                                    dataPeminjaman
                                        .doc(firebase.currentUser?.uid)
                                        .delete()
                                        .then((value) {
                                      setState(() {
                                        widget.statusPinjam = false;
                                      });
                                    }).catchError((error) => print(
                                            "Failed to return bike: $error"));

                                    firestore
                                        .collection('data_sepeda')
                                        .doc('${dataSnapshot['id_sepeda']}')
                                        .update(
                                      {
                                        'status': 'Tersedia',
                                        'fakultas': widget.fakultasState
                                      },
                                    );
                                    if (selisihJam.isNegative) {
                                      users.doc(currentUser).update(
                                        {
                                          'status': 0,
                                          'sisa_jam': '0:00:00',
                                          'peminjaman_terakhir': waktuKembali,
                                          'denda_pinjam': selisihJamNegatif
                                        },
                                      );
                                    } else {
                                      users.doc(currentUser).update(
                                        {
                                          'status': 0,
                                          'sisa_jam': selisihJam.toString(),
                                          'peminjaman_terakhir': waktuKembali
                                        },
                                      );
                                    }
                                    setState(() {
                                      widget.statusPinjam = false;
                                      widget.onPressedPinjam(true);
                                    });
                                    print('set state done');
                                    Navigator.of(context).pop();
                                    print('pop done');
                                  },
                                ),
                              ),
                            )
                          ],
                        );
                      });
                    });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // _subscription.cancel();
    super.dispose();
  }
}
