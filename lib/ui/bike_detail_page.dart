import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/function/pinjam_sepeda.dart';
import 'package:unibike/model/bike_model2.dart';

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
                'Waktu peminjaman sepeda adalah 4 jam. Jika telat mengembalikan, maka anda tidak dapat meminjam sepeda selama satu hari berikutnya.',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              SizedBox(height: 30),
              Container(
                width: width,
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Text('Pinjam',
                      style: Theme.of(context).textTheme.headline6),
                  style: ElevatedButton.styleFrom(minimumSize: Size(width, 50)),
                  onPressed: isAvail
                      ? PinjamSepeda(
                              statusPinjam: widget.statusPinjam,
                              onDebt: widget.onDebt,
                              context: context,
                              connectionStatus: _connectionStatus,
                              bike: widget.bike,
                              sisaJam: widget.sisaJam,
                              fakultas: widget.fakultas,
                              onPressedPinjam: widget.onPressedPinjam,
                              setState: setState)
                          .MeminjamSepeda
                      : null,
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
}
