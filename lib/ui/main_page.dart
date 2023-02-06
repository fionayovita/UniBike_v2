import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unibike/api/api_service.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/model/bike_model2.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:unibike/ui/history_peminjaman_page.dart';
import 'package:unibike/ui/list_bike_page.dart';
import 'package:unibike/ui/profile_page.dart';
import 'package:unibike/widgets/bottom_sheet.dart';

class MainPage extends StatefulWidget {
  static const routeName = 'main_page';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final firebase = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference dataSepeda =
      FirebaseFirestore.instance.collection('data_sepeda');
  bool _isLoading = true;
  var dataSnapshot;
  var dbSepeda;

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
  List<dynamic> favFakultas = [];
  List<ListSepeda> filteredList = [];
  int statusPinjam = 0;
  bool isOnDebt = false;

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
        dataLoadFunction();
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

  dataLoadFunction() async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });
    dbSepeda = ApiService.fetchDataSepeda();
    setState(() {
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }

  @override
  Widget build(BuildContext context) {
    String currentUser = firebase.currentUser!.uid.toString();
    return StreamBuilder<DocumentSnapshot>(
        stream: users.doc('$currentUser').snapshots(),
        builder: (_, snapshot) {
          if (snapshot.hasError) return Text('Error = ${snapshot.error}');

          if (snapshot.hasData) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            dataSnapshot = data;
            favFakultas = data['favorite'];
            statusPinjam = data['status'];
            isOnDebt = data.containsKey('denda_pinjam');
            var nama = data['nama'].split(" ") ?? 'bikers';

            if (isOnDebt) {
              var peminjamanTerakhir = data['peminjaman_terakhir'].toDate();
              final today = DateTime.now();
              Duration timeDifference = today.difference(peminjamanTerakhir);
              if (timeDifference.inHours >= 24) {
                users
                    .doc('$currentUser')
                    .update(
                      {
                        'denda_pinjam': FieldValue.delete(),
                        'sisa_jam': "4:00:00"
                      },
                    )
                    .whenComplete(() => print("field deleted"))
                    .catchError(
                        (error) => print("Failed to return bike: $error"));
              }
            } else {
              var peminjamanTerakhir = data['peminjaman_terakhir'].toDate();
              final today = DateTime.now();
              if (peminjamanTerakhir.year != today.year &&
                  peminjamanTerakhir.day != today.day &&
                  peminjamanTerakhir.month != today.month) {
                users
                    .doc('$currentUser')
                    .update(
                      {'sisa_jam': "4:00:00"},
                    )
                    .whenComplete(
                        () => print("sisa jam returned to 4 hours a day"))
                    .catchError(
                        (error) => print("Failed to return bike: $error"));
              }
            }
            return Scaffold(
                backgroundColor: whiteBackground,
                appBar: AppBar(
                  leadingWidth: 0,
                  foregroundColor: primaryColor,
                  backgroundColor: primaryColor,
                  automaticallyImplyLeading: false,
                  title: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Image.asset(
                          'assets/logo_new.png',
                          width: 40,
                          height: 40,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Halo, ${nama[0]}!",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(4.0),
                    child: Container(
                      color: underline,
                      height: 1.0,
                    ),
                  ),
                  actions: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, HistoryPeminjamanPage.routeName);
                        },
                        child: Icon(
                          Icons.history,
                          color: lightBlue,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, ProfilePage.routeName);
                        },
                        child: Icon(
                          Icons.account_circle,
                          color: lightBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                body: RefreshIndicator(
                  onRefresh: () async {
                    onRefresh();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SafeArea(
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          if (constraints.maxWidth <= 700) {
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 17.0, vertical: 20.0),
                                child: _content(context));
                          } else if (constraints.maxWidth <= 1100) {
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 80.0, vertical: 20.0),
                                child: _content(context));
                          } else {
                            return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 550.0, vertical: 20.0),
                                child: _content(context));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                bottomSheet: (statusPinjam != 0)
                    ? BottomSheetWidget(onPressedPinjam: ((bool isPressed) {
                        isPressed ? dataLoadFunction() : null;
                      }))
                    : null);
          }
          return Container();
        });
  }

  Widget _content(BuildContext context) {
    List totalSepeda = [];

    return FutureBuilder<List<ListSepeda>>(
        future: dbSepeda,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/errorstate.png',
                    width: 250,
                    height: 250,
                  ),
                  Text(
                    "Terjadi error. Silahkan muat ulang halaman.",
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.none &&
              _connectionStatus == ConnectivityResult.none) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/errorstate.png',
                  width: 250,
                  height: 250,
                ),
                Text(
                  "Tidak ada koneksi. Silahkan muat ulang halaman.",
                  style: Theme.of(context).textTheme.headline5,
                  textAlign: TextAlign.center,
                ),
              ],
            ));
          } else if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(bottom: (statusPinjam != 0) ? 85.0 : 0),
                height: (statusPinjam != 0)
                    ? (MediaQuery.of(context).size.height * 0.78)
                    : (MediaQuery.of(context).size.height * 0.85),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    statusPinjam == 0 && dataSnapshot['sisa_jam'] != '4:00:00'
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 17),
                            decoration: BoxDecoration(
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/gradientBg.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                dataSnapshot['sisa_jam'] == '0:00:00'
                                    ? Text(
                                        "Anda tidak memiliki sisa waktu pinjam hari ini",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Sisa waktu peminjaman hari ini:",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2,
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            "${dataSnapshot['sisa_jam'].split(':')[0]} Jam ${dataSnapshot['sisa_jam'].split(':')[1]} Menit",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                          SizedBox(height: 7),
                                        ],
                                      ),
                                isOnDebt
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Denda waktu peminjaman anda:",
                                            style: Theme.of(context)
                                                .textTheme
                                                .subtitle2,
                                          ),
                                          SizedBox(height: 3),
                                          Text(
                                            "${dataSnapshot['denda_pinjam'].split(':')[0]} Jam ${dataSnapshot['denda_pinjam'].split(':')[1]} Menit ${dataSnapshot['denda_pinjam'].split(':')[2].split('.')[0]} detik",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6,
                                          ),
                                        ],
                                      )
                                    : Text(
                                        "Anda tidak memiliki denda waktu peminjaman",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      )
                              ],
                            ),
                          )
                        : SizedBox(height: 0),
                    SizedBox(height: statusPinjam == 0 ? 17 : 0),
                    Text(
                      "Pilih shelter peminjaman",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Dimana kamu mau meminjam sepeda?",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 20.0),
                    Expanded(
                        child: ListView.builder(
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      itemCount: _listFakultas.length,
                      itemBuilder: (context, index) {
                        var sepeda = snapshot.data!;
                        filteredList = sepeda.where(((bike) {
                          return bike.fields.fakultas.value ==
                              _fakultasDb[index];
                        })).toList();
                        bool alreadySaved =
                            favFakultas.contains(_listFakultas[index]);
                        totalSepeda.add(filteredList.length);

                        return Card(
                          color: mediumBlue,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(16.0),
                            ),
                          ),
                          elevation: 6,
                          child: ListTile(
                            title: Text('Fakultas ${_listFakultas[index]}',
                                style: Theme.of(context).textTheme.headline6),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: primaryColor,
                                  maxRadius: 15,
                                  child: Text('${totalSepeda[index]}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1),
                                ),
                                SizedBox(width: 5),
                                IconButton(
                                  icon: Icon(
                                      !alreadySaved
                                          ? Icons.star_border
                                          : Icons.star,
                                      color: !alreadySaved
                                          ? whiteBackground
                                          : secondaryColor,
                                      size: 30),
                                  onPressed: () async {
                                    String currentUser =
                                        firebase.currentUser!.uid.toString();
                                    if (!alreadySaved) {
                                      favFakultas.add(_listFakultas[index]);
                                      firestore
                                          .collection('users')
                                          .doc('${currentUser}')
                                          .update(
                                        {'favorite': favFakultas},
                                      );
                                    } else {
                                      favFakultas.removeWhere((fakultas) {
                                        return fakultas ==
                                            "${_listFakultas[index]}";
                                      });
                                      firestore
                                          .collection('users')
                                          .doc('${currentUser}')
                                          .update(
                                        {'favorite': favFakultas},
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                            onTap: () => Navigator.pushNamed(
                                context, ListBikePage.routeName,
                                arguments: ListBikeArgs(
                                    bike: filteredList,
                                    totalSepeda: totalSepeda[index],
                                    fakultas: _listFakultas[index],
                                    fakultasDb: _fakultasDb[index],
                                    statusPinjam: statusPinjam)),
                          ),
                        );
                      },
                    )),
                    SizedBox(height: 15.0),
                  ],
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator());
        });
  }

  Future<void> onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await dataLoadFunction();
    setState(() {
      _isLoading = false;
    });
  }
}
