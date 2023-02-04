import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/model/bike_model2.dart';
import 'package:unibike/ui/bike_detail_page.dart';
import 'package:unibike/widgets/custom_dialog.dart';

class CardSepedaArgs {
  final ListSepeda bike;
  final String? fakultas;
  int? statusPinjam;
  final Function(bool, DateTime) onPressedPinjam;
  bool onDebt;

  CardSepedaArgs(
      {required this.bike,
      required this.fakultas,
      required this.statusPinjam,
      required this.onPressedPinjam,
      required this.onDebt});
}

class CardSepeda extends StatefulWidget {
  final ListSepeda bike;
  final String? fakultas;
  int? statusPinjam;
  final Function(bool, DateTime) onPressedPinjam;
  bool onDebt;
  String sisaJam;

  CardSepeda(
      {required this.bike,
      required this.fakultas,
      required this.statusPinjam,
      required this.onPressedPinjam,
      required this.onDebt,
      required this.sisaJam});

  @override
  _CardSepedaState createState() => _CardSepedaState();
}

class _CardSepedaState extends State<CardSepeda> {
  final firebase = FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;
  final CollectionReference sepeda =
      FirebaseFirestore.instance.collection('data_sepeda');

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
    return _content(context);
  }

  Widget _content(BuildContext context) {
    print("sisajam nya ${widget.sisaJam}");
    String emailUser = firebase.currentUser!.email.toString();
    bool isAvailable = widget.bike.fields.status.value == 'Tersedia' ||
        widget.bike.fields.status.value == 'tersedia';
    String docId = widget.bike.name.replaceAll(
        'projects/unibike-13780/databases/(default)/documents/data_sepeda/',
        '');

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, BikeDetailPage.routeName,
            arguments:
                BikeDetailArgs(bike: widget.bike, fakultas: widget.fakultas!));
      },
      child: Card(
        elevation: 3,
        semanticContainer: true,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shadowColor: greyButton,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: Image.network(widget.bike.fields.fotoSepeda.value!,
                  fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 3.0, left: 10, right: 10),
              child: Text(
                widget.bike.fields.jenisSepeda.value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                  child: Text('Pinjam',
                      style: Theme.of(context).textTheme.headline6),
                  onPressed: isAvailable
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
                                              final jenisSepeda = widget.bike
                                                  .fields.jenisSepeda.value;
                                              var today = DateTime.now();

                                              var sisaJamSplit =
                                                  widget.sisaJam.split(':');
                                              var sisaJamInDate = new DateTime(
                                                  today.year,
                                                  today.month,
                                                  today.day,
                                                  int.parse(sisaJamSplit[0]),
                                                  int.parse(sisaJamSplit[1]),
                                                  0);

                                              var formattedTime = new DateTime(
                                                  today.year,
                                                  today.month,
                                                  today.day,
                                                  0,
                                                  0,
                                                  0);

                                              Duration timeDifference =
                                                  sisaJamInDate.difference(
                                                      formattedTime);

                                              var kembali = today.add(Duration(
                                                  seconds: widget.sisaJam !=
                                                          "4:00:00"
                                                      ? timeDifference.inSeconds
                                                      : 14400));

                                              _store
                                                  .collection('data_peminjaman')
                                                  .doc(
                                                      firebase.currentUser?.uid)
                                                  .set(
                                                {
                                                  'id_sepeda': docId,
                                                  'jenis_sepeda': jenisSepeda,
                                                  'email_peminjam': emailUser,
                                                  'waktu_pinjam': today,
                                                  'waktu_kembali': kembali,
                                                  'fakultas': widget.fakultas
                                                },
                                              );

                                              sepeda.doc(docId).update(
                                                {'status': 'Tidak Tersedia'},
                                              );

                                              widget.onPressedPinjam(
                                                  true, today);

                                              return showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
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
                                                builder:
                                                    (BuildContext context) {
                                                  return CustomDialog(
                                                    title: 'Peminjaman Gagal',
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
                                              builder: (BuildContext context) {
                                                return CustomDialog(
                                                  title: 'Peminjaman Gagal',
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
                                      title: 'Anda sedang meminjam sepeda',
                                      descriptions:
                                          'Satu akun hanya boleh meminjam satu sepeda di waktu yang sama.',
                                      text: 'OK',
                                    );
                                  },
                                );
                        })
                      : null),
            )
          ],
        ),
      ),
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
        child: contentBox(context, onPressedPinjam),
      ),
    );
  }

  Widget contentBox(BuildContext context, Function onPressedPinjam) {
    print('ada ga yaaaa test');
    return Container(
      padding: EdgeInsets.only(
          left: 12.0, top: 50.0 + 12.0, right: 12.0, bottom: 10),
      margin: EdgeInsets.only(top: 50.0),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: primaryColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(color: greyOutline, offset: Offset(0, 10), blurRadius: 10),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text("Apakah kamu yakin ingin meminjam sepeda ini?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 22,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(120, 50), primary: whiteBackground),
                child: Text(
                  "Tidak",
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onPressedPinjam();
                },
                style: ElevatedButton.styleFrom(minimumSize: Size(120, 50)),
                child: Text("Ya",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.15,
                      color: primaryColor,
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
