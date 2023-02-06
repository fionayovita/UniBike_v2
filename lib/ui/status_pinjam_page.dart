import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/provider/alarm_provider.dart';
import 'package:unibike/provider/preferences_provider.dart';
import 'package:unibike/widgets/appbar.dart';
import 'package:unibike/widgets/custom_dialog.dart';

class StatusPinjamPage extends StatefulWidget {
  static const routeName = 'status_pinjam_page';

  String fakultasState = '';

  @override
  State<StatusPinjamPage> createState() => _StatusPinjamPageState();
}

class _StatusPinjamPageState extends State<StatusPinjamPage> {
  final firebase = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  bool statusPinjam = false;

  final CollectionReference status =
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

  List _fakultasDb = ["ft", "fmipa", "feb", "fk", "fp", "fkip", "fisip", "fh"];

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      appBar: CustomAppBar(text: "Status Peminjaman"),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth <= 700) {
                  return _contentPinjam(context, 350);
                } else if (constraints.maxWidth <= 1100) {
                  return _contentPinjam(context, 500);
                } else {
                  return _contentPinjam(context, 700);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _contentPinjam(BuildContext context, double width) {
    statusPinjam = true;
    String currentUser = firebase.currentUser!.uid.toString();
    return Center(
      child: FutureBuilder<DocumentSnapshot>(
        future: status.doc(firebase.currentUser?.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/errorstate.png',
                    width: 250,
                    height: 250,
                  ),
                  Text(
                      "Terjadi kesalahan, silahkan kembali ke halaman sebelumnya.",
                      style: Theme.of(context).textTheme.headline5)
                ],
              ),
            );
          } else if (snapshot.hasData && !snapshot.data!.exists) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: <Widget>[
                    Image.asset(
                      'assets/emptystate.png',
                      width: 250,
                      height: 250,
                    ),
                    SizedBox(height: 15.0),
                    Text('Anda belum meminjam sepeda',
                        style: Theme.of(context).textTheme.headline5)
                  ],
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            DateTime dtPinjam = (data['waktu_pinjam'] as Timestamp).toDate();
            final dateFormatPinjam =
                DateFormat('EEE d MMM, HH:mm').format(dtPinjam);
            DateTime dtKembali = (data['waktu_kembali'] as Timestamp).toDate();
            final dateFormatKembali =
                DateFormat('EEE d MMM, HH:mm').format(dtKembali);

            return Container(
              width: width,
              margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID Sepeda',
                    style: TextStyle(fontSize: 15.0, color: greyOutline),
                  ),
                  Text(
                    '${data['id_sepeda']}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 22),
                  Text(
                    'Jenis Sepeda',
                    style: TextStyle(fontSize: 15.0, color: greyOutline),
                  ),
                  Text(
                    '${data['jenis_sepeda']}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 22),
                  Text(
                    'Email Peminjam',
                    style: TextStyle(fontSize: 15.0, color: greyOutline),
                  ),
                  Text(
                    data['email_peminjam'],
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 22),
                  Text(
                    'Waktu Peminjaman',
                    style: TextStyle(fontSize: 15.0, color: greyOutline),
                  ),
                  Text(
                    '${dateFormatPinjam}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 22),
                  Text(
                    'Batas Waktu Pengembalian',
                    style: TextStyle(fontSize: 15.0, color: greyOutline),
                  ),
                  Text(
                    '${dateFormatKembali}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 22),
                  Text(
                    'Fakultas Peminjaman',
                    style: TextStyle(fontSize: 15.0, color: greyOutline),
                  ),
                  Text(
                    'Fakultas ${data['fakultas']}',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 50),
                  Consumer<PreferencesProvider>(
                    builder: (context, provider, child) {
                      return Consumer<SchedulingProvider>(
                        builder: (context, scheduled, child) {
                          return MaterialButton(
                            child: Text('Kembalikan Sepeda',
                                style: Theme.of(context).textTheme.headline5),
                            color: primaryColor,
                            height: 53,
                            minWidth: MediaQuery.of(context).size.width,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                        builder: (context, setState) {
                                      return new SimpleDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        elevation: 0,
                                        title: new Text(
                                            'Fakultas pengembalian sepeda: ',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5),
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 17, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: secondaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.7),
                                                    spreadRadius: 2,
                                                    blurRadius: 3,
                                                    offset: Offset(0, 3),
                                                  )
                                                ],
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: ButtonTheme(
                                                  child: DropdownButton(
                                                    isExpanded: true,
                                                    iconEnabledColor:
                                                        primaryColor,
                                                    dropdownColor:
                                                        secondaryColor,
                                                    hint: Text("Pilih Fakultas",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle2),
                                                    value: fakultas,
                                                    items: _listFakultas.map(
                                                      (value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          child: Text(value,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .subtitle2),
                                                          value: value,
                                                        );
                                                      },
                                                    ).toList(),
                                                    onChanged: (value) {
                                                      setState(
                                                        () {
                                                          fakultas =
                                                              value as String;
                                                          var idx =
                                                              _listFakultas
                                                                  .indexOf(
                                                                      value);
                                                          widget.fakultasState =
                                                              _fakultasDb[idx];
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: TextButton(
                                                child: Text(
                                                  'Submit',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .subtitle1,
                                                ),
                                                onPressed: () async {
                                                  var batasWaktu =
                                                      data['waktu_kembali']
                                                          .toDate();
                                                  var waktuKembali =
                                                      DateTime.now();
                                                  var selisihJam = batasWaktu
                                                      .difference(waktuKembali);
                                                  var selisihJamNegatif =
                                                      selisihJam
                                                          .toString()
                                                          .replaceAll(
                                                              RegExp('-'), '');

                                                  if (_connectionStatus !=
                                                      ConnectivityResult.none) {
                                                    status
                                                        .doc(firebase
                                                            .currentUser?.uid)
                                                        .delete()
                                                        .catchError((error) =>
                                                            print(
                                                                "Failed to return bike: $error"));

                                                    firestore
                                                        .collection(
                                                            'history_peminjaman')
                                                        .doc(firebase
                                                            .currentUser?.uid)
                                                        .collection(
                                                            'user_history')
                                                        .doc()
                                                        .set(
                                                      {
                                                        'id_sepeda':
                                                            data['id_sepeda'],
                                                        'jenis_sepeda': data[
                                                            'jenis_sepeda'],
                                                        'email_peminjam': data[
                                                            'email_peminjam'],
                                                        'waktu_pinjam': data[
                                                            'waktu_pinjam'],
                                                        'waktu_kembali':
                                                            waktuKembali,
                                                        'fakultas':
                                                            data['fakultas']
                                                      },
                                                    );

                                                    firestore
                                                        .collection(
                                                            'data_sepeda')
                                                        .doc(
                                                            '${data['id_sepeda']}')
                                                        .update(
                                                      {
                                                        'status': 'Tersedia',
                                                        'fakultas':
                                                            widget.fakultasState
                                                      },
                                                    );
                                                    if (selisihJam.isNegative) {
                                                      users
                                                          .doc(currentUser)
                                                          .update(
                                                        {
                                                          'status': 0,
                                                          'sisa_jam': '0:00:00',
                                                          'peminjaman_terakhir':
                                                              waktuKembali,
                                                          'denda_pinjam':
                                                              selisihJamNegatif
                                                        },
                                                      );
                                                    } else {
                                                      users
                                                          .doc(currentUser)
                                                          .update(
                                                        {
                                                          'status': 0,
                                                          'sisa_jam': selisihJam
                                                              .toString(),
                                                          'peminjaman_terakhir':
                                                              waktuKembali
                                                        },
                                                      );
                                                    }
                                                    setState(() {
                                                      statusPinjam = false;
                                                    });
                                                    Navigator.of(context).pop();

                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return CustomDialog(
                                                          title: 'Sukses!',
                                                          descriptions:
                                                              'Berhasil mengembalikan sepeda, peminjaman sepeda anda selesai.',
                                                          text: 'OK',
                                                        );
                                                      },
                                                    );
                                                  } else {
                                                    return showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return CustomDialog(
                                                          title:
                                                              'Pengembalian Gagal',
                                                          descriptions:
                                                              'Error, silahkan coba lagi beberapa saat kemudian!',
                                                          text: 'OK',
                                                        );
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                          )
                                        ],
                                      );
                                    });
                                  }).then((value) {
                                setState(() {});
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
