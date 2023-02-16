import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/function/pinjam_sepeda.dart';
import 'package:unibike/model/bike_model2.dart';
import 'package:unibike/ui/bike_detail_page.dart';

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
    bool isAvailable = widget.bike.fields.status.value == 'Tersedia' ||
        widget.bike.fields.status.value == 'tersedia';

    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, BikeDetailPage.routeName,
            arguments: BikeDetailArgs(
                bike: widget.bike,
                fakultas: widget.fakultas!,
                statusPinjam: widget.statusPinjam,
                sisaJam: widget.sisaJam,
                onDebt: widget.onDebt,
                onPressedPinjam: widget.onPressedPinjam));
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
                    fit: BoxFit.scaleDown)),
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
                      : null),
            )
          ],
        ),
      ),
    );
  }
}
