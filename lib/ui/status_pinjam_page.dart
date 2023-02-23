import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/function/kembalikan_sepeda.dart';
import 'package:unibike/widgets/appbar.dart';

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
      appBar: CustomAppBar(
          text: "Status Peminjaman", listBike: false, onPressedFilter: () {}),
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
                  MaterialButton(
                    child: Text('Kembalikan Sepeda',
                        style: Theme.of(context).textTheme.headline5),
                    color: primaryColor,
                    height: 53,
                    minWidth: MediaQuery.of(context).size.width,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onPressed: KembalikanSepeda(
                            context: context,
                            data: data,
                            setState: setState,
                            currentUser: currentUser,
                            connectionStatus: _connectionStatus)
                        .mengembalikanSepeda,
                  )
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
