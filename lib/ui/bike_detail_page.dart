import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/model/bike_model2.dart';
import 'package:unibike/provider/alarm_provider.dart';
import 'package:unibike/provider/preferences_provider.dart';
import 'package:unibike/widgets/confirmation_dialog.dart';
import 'package:unibike/widgets/custom_dialog.dart';

class BikeDetailArgs {
  final ListSepeda bike;
  final String fakultas;
  int? statusPinjam;
  final Function(bool, DateTime) onPressedPinjam;
  bool onDebt;
  String sisaJam;
  BikeDetailArgs(
      {required this.bike,
      required this.fakultas,
      required this.statusPinjam,
      required this.onPressedPinjam,
      required this.onDebt,
      required this.sisaJam});
}

class BikeDetailPage extends StatefulWidget {
  static const routeName = 'detail_page';

  final firebase = FirebaseAuth.instance;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference dataPeminjaman =
      FirebaseFirestore.instance.collection('data_peminjaman');
  final CollectionReference dataSepeda =
      FirebaseFirestore.instance.collection('data_sepeda');

  final ListSepeda bike;
  final String fakultas;
  int? statusPinjam;
  final Function(bool, DateTime) onPressedPinjam;
  bool onDebt;
  String sisaJam;
  BikeDetailPage(
      {required this.bike,
      required this.fakultas,
      required this.statusPinjam,
      required this.onPressedPinjam,
      required this.onDebt,
      required this.sisaJam});

  @override
  State<BikeDetailPage> createState() => _BikeDetailPageState();
}

class _BikeDetailPageState extends State<BikeDetailPage> {
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isLoading = false;

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

  pinjamSepedaFunction(value) async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });

    String currentUser = widget.firebase.currentUser!.uid.toString();
    widget.users.doc(currentUser).update(
      {'status': 1},
    );
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('countdownTimer', value.millisecondsSinceEpoch);
    prefs.setString('sisa_jam', widget.sisaJam);
    setState(() {
      widget.statusPinjam = 1;
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: SingleChildScrollView(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth <= 700) {
              return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                  child: _textField(context));
            } else if (constraints.maxWidth <= 1100) {
              return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 70.0, vertical: 20.0),
                  child: _textField(context));
            } else {
              return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100.0, vertical: 20.0),
                  child: _textField(context));
            }
          },
        ),
      ),
    );
  }

  Widget _textField(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final _user = widget.bike;
    String docId = _user.name.replaceAll(
        'projects/unibike-13780/databases/(default)/documents/data_sepeda/',
        '');
    var isAvail = widget.bike.fields.status.value == "tersedia" ||
        widget.bike.fields.status.value == "Tersedia";
    String emailUser = widget.firebase.currentUser!.email.toString();

    return Stack(
      children: [
        Container(
          width: width,
          height: 400,
          child: Hero(
            tag: widget.bike.fields.fotoSepeda.value!,
            child: Image.network(
              widget.bike.fields.fotoSepeda.value!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
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
        Container(
          margin: const EdgeInsets.only(top: 380),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 25),
          decoration: BoxDecoration(
              color: whiteBackground,
              borderRadius: BorderRadius.circular(25.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.bike.fields.jenisSepeda.value ?? '-',
                style: Theme.of(context).textTheme.headline2,
              ),
              Divider(color: darkPrimaryColor),
              SizedBox(height: 30),
              Text(
                'Id Sepeda: $docId',
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 5),
              Text(
                'Jenis Sepeda: ${widget.bike.fields.jenisSepeda.value ?? "-"}',
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(height: 80),
              Text(
                'Keterangan:',
                style: Theme.of(context).textTheme.subtitle1,
              ),
              SizedBox(height: 5),
              Text(
                'Waktu peminjaman sepeda adalah 3 jam. Jika telat mengembalikan, maka jam peminjaman sepeda anda selanjutnya akan dipotong.',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(height: 30),
              Container(
                width: width,
                alignment: Alignment.center,
                child: Consumer<PreferencesProvider>(
                  builder: (context, provider, child) {
                    return Consumer<SchedulingProvider>(
                      builder: (context, scheduled, child) {
                        return ElevatedButton(
                          child: Text('Pinjam',
                              style: Theme.of(context).textTheme.headline6),
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(width, 50)),
                          onPressed: isAvail
                              ? (() {
                                  widget.statusPinjam == 0
                                      ? widget.onDebt
                                          ? showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return CustomDialog(
                                                  title:
                                                      'Anda memiliki denda waktu peminjaman!',
                                                  descriptions:
                                                      'Anda telat mengembalikan sepeda di peminjaman sebelumnya, sehingga tidak dapat meminjam sepeda selama satu hari.',
                                                  text: 'OK',
                                                );
                                              },
                                            )
                                          : showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return dialogAsk(context, () {
                                                  if (_connectionStatus !=
                                                      ConnectivityResult.none) {
                                                    try {
                                                      final jenisSepeda = widget
                                                          .bike
                                                          .fields
                                                          .jenisSepeda
                                                          .value;
                                                      var today =
                                                          DateTime.now();

                                                      var sisaJamSplit = widget
                                                          .sisaJam
                                                          .split(':');
                                                      var sisaJamInDate =
                                                          new DateTime(
                                                              today.year,
                                                              today.month,
                                                              today.day,
                                                              int.parse(
                                                                  sisaJamSplit[
                                                                      0]),
                                                              int.parse(
                                                                  sisaJamSplit[
                                                                      1]),
                                                              0);

                                                      var formattedTime =
                                                          new DateTime(
                                                              today.year,
                                                              today.month,
                                                              today.day,
                                                              0,
                                                              0,
                                                              0);

                                                      Duration timeDifference =
                                                          sisaJamInDate
                                                              .difference(
                                                                  formattedTime);

                                                      var kembali = today.add(
                                                          Duration(
                                                              seconds: widget
                                                                          .sisaJam !=
                                                                      "4:00:00"
                                                                  ? timeDifference
                                                                      .inSeconds
                                                                  : 14400));

                                                      widget.dataPeminjaman
                                                          .doc(widget.firebase
                                                              .currentUser?.uid)
                                                          .set(
                                                        {
                                                          'id_sepeda': docId,
                                                          'jenis_sepeda':
                                                              jenisSepeda,
                                                          'email_peminjam':
                                                              emailUser,
                                                          'waktu_pinjam': today,
                                                          'waktu_kembali':
                                                              kembali,
                                                          'fakultas':
                                                              widget.fakultas
                                                        },
                                                      );

                                                      widget.dataSepeda
                                                          .doc(docId)
                                                          .update(
                                                        {
                                                          'status':
                                                              'Tidak Tersedia'
                                                        },
                                                      );
                                                      pinjamSepedaFunction(
                                                          today);

                                                      return showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return CustomDialog(
                                                            title:
                                                                'Sukses Pinjam Sepeda!',
                                                            descriptions:
                                                                'Silahkan cek status peminjaman di halaman Status Pinjam untuk melihat lebih detail',
                                                            text: 'OK',
                                                          );
                                                        },
                                                      );
                                                    } catch (e) {
                                                      return showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return CustomDialog(
                                                            title:
                                                                'Peminjaman Gagal',
                                                            descriptions:
                                                                'Error: ${e.toString()}. Silahkan coba lagi beberapa saat kemudian!',
                                                            text: 'OK',
                                                          );
                                                        },
                                                      );
                                                    } finally {
                                                      setState(() {
                                                        widget.fakultas;
                                                        widget.bike;
                                                        // isAvail = false;
                                                      });
                                                    }
                                                  } else {
                                                    return showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return CustomDialog(
                                                          title:
                                                              'Peminjaman Gagal',
                                                          descriptions:
                                                              'Error, silahkan coba lagi beberapa saat kemudian!',
                                                          text: 'OK',
                                                        );
                                                      },
                                                    );
                                                  }
                                                });
                                              })
                                      : showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return CustomDialog(
                                              title:
                                                  'Anda sedang meminjam sepeda',
                                              descriptions:
                                                  'Satu akun hanya boleh meminjam satu sepeda di waktu yang sama.',
                                              text: 'OK',
                                            );
                                          },
                                        );
                                })
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
              height: MediaQuery.of(context).size.height + 25,
              child: Opacity(
                opacity: 0.8,
                child: ModalBarrier(dismissible: false, color: Colors.black),
              )),
        if (_isLoading)
          Container(
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator(),
              )),
      ],
    );
  }

  Widget dialogAsk(BuildContext context, Function onPressedPinjam) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: ConfirmationDialog(
          onPressedPinjam: onPressedPinjam,
          text: "Apakah kamu yakin ingin meminjam sepeda ini?",
        ),
      ),
    );
  }
}
