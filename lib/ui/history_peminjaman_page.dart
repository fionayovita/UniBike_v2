import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unibike/widgets/appbar.dart';
import 'package:unibike/widgets/card_history.dart';

class HistoryPeminjamanPage extends StatefulWidget {
  static const routeName = 'history_peminjaman_page';

  @override
  State<HistoryPeminjamanPage> createState() => _HistoryPeminjamanPageState();
}

class _HistoryPeminjamanPageState extends State<HistoryPeminjamanPage> {
  final firebase = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  final CollectionReference history =
      FirebaseFirestore.instance.collection('history_peminjaman');
  bool _isLoading = true;
  bool exist = false;

  Future<bool> checkExist(String? docID) async {
    try {
      await FirebaseFirestore.instance
          .collection('history_peminjaman')
          .doc(docID)
          .collection('user_history')
          .get()
          .then((doc) {
        setState(() {
          exist = doc.docs.isNotEmpty;
          _isLoading = false;
        });
      });

      return exist;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // If any error
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    checkExist(firebase.currentUser?.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          text: "Riwayat Peminjaman", listBike: false, onPressedFilter: () {}),
      body: SafeArea(
        child: Center(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth <= 700) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 17.0, vertical: 20.0),
                    child: _listPinjam(context));
              } else if (constraints.maxWidth <= 1100) {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 70.0, vertical: 20.0),
                    child: _listPinjam(context));
              } else {
                return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 550.0, vertical: 20.0),
                    child: _listPinjam(context));
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _listPinjam(BuildContext context) {
    return Center(
      child: _isLoading
          ? CircularProgressIndicator()
          : exist
              ? StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: history
                      .doc(firebase.currentUser?.uid)
                      .collection('user_history')
                      .orderBy('waktu_pinjam', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                'assets/errorstate.png',
                                width: 250,
                                height: 250,
                              ),
                              SizedBox(height: 15.0),
                              Text(
                                  'Terjadi kesalahan, silahkan kembali ke halaman sebelumnya.',
                                  style: Theme.of(context).textTheme.headline5)
                            ],
                          ),
                        ),
                      );
                    } else if (!snapshot.hasData) {
                      return SingleChildScrollView(
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Image.asset(
                                'assets/emptystate.png',
                                width: 250,
                                height: 250,
                              ),
                              SizedBox(height: 15.0),
                              Text('Tidak ada riwayat peminjaman',
                                  style: Theme.of(context).textTheme.headline5)
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data!.docs[index];
                          final jenisSepeda = data['jenis_sepeda'];
                          final fakultasPinjam = data['fakultas_pinjam'];
                          final fakultasKembali = data['fakultas_kembali'];
                          final waktuPinjam = data['waktu_pinjam'];
                          final waktuKembali = data['waktu_kembali'];
                          var dateFormatPinjam = DateFormat('dd/MM/yyyy HH:mm')
                              .format(waktuPinjam.toDate());
                          var dateFormatKembali = DateFormat('dd/MM/yyyy HH:mm')
                              .format(waktuKembali.toDate());

                          return CardHistory(
                              jenisSepeda: jenisSepeda,
                              fakultasPinjam: fakultasPinjam,
                              fakultasKembali: fakultasKembali == null
                                  ? " "
                                  : fakultasKembali,
                              waktuPinjam: dateFormatPinjam.toString(),
                              waktuKembali: dateFormatKembali.toString());
                        },
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                )
              : SingleChildScrollView(
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Image.asset(
                          'assets/emptystate.png',
                          width: 250,
                          height: 250,
                        ),
                        SizedBox(height: 15.0),
                        Text('Tidak ada riwayat peminjaman.',
                            style: Theme.of(context).textTheme.headline5)
                      ],
                    ),
                  ),
                ),
    );
  }
}
