import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

  List _listSepeda = [];

  List<ListSepeda> newfilteredList = [];
  List<dynamic> favFakultas = [];
  List<ListSepeda> filteredList = [];
  int statusPinjam = 0;
  bool isOnDebt = false;
  bool isFiltered = false;

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

  String convertFakultas(String chosenFakultas) {
    var result;
    if (chosenFakultas == "Teknik") {
      result = 'ft';
      return result;
    } else if (chosenFakultas == "MIPA") {
      result = 'fmipa';
      return result;
    } else if (chosenFakultas == "Ekonomi") {
      result = 'feb';
      return result;
    } else if (chosenFakultas == "Kedokteran") {
      result = 'fk';
      return result;
    } else if (chosenFakultas == "Pertanian") {
      result = 'fp';
      return result;
    } else if (chosenFakultas == "Keguruan dan Ilmu Pendidikan") {
      result = 'fkip';
      return result;
    } else if (chosenFakultas == "Ilmu Sosial dan Pemerintahan") {
      result = 'fisip';
      return result;
    } else if (chosenFakultas == "Hukum") {
      result = 'fh';
      return result;
    } else {
      return 'ft';
    }
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
              if (timeDifference.inDays >= 1) {
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
              var oneDay = new DateTime(peminjamanTerakhir.year,
                  peminjamanTerakhir.month, peminjamanTerakhir.day, 24);
              final today = DateTime.now();
              Duration timeDifference = today.difference(oneDay);

              if (timeDifference.inDays >= 1) {
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
            List? favIsEmpty() {
              return _listFakultas.where((e) {
                return favFakultas.contains(e);
              }).toList();
            }

            if (favIsEmpty()?.length != 0) {
              favIsEmpty()!.forEach((element) {
                _listFakultas.removeWhere((fakultas) => fakultas == element);
                _listFakultas.insert(0, element);
              });
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
                    Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        margin:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        decoration: BoxDecoration(
                          color: lightBlue,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${statusPinjam == 1 ? 'Sedang Meminjam' : (statusPinjam == 0 && isOnDebt) ? "Denda Pinjam" : dataSnapshot['sisa_jam'] == "0:00:00" ? "Waktu Habis" : dataSnapshot['sisa_jam'].split('.')[0]}",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                      color: primaryColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                            ),
                            SizedBox(width: 5),
                            CircleAvatar(
                              maxRadius: 8,
                              backgroundColor: statusPinjam == 1
                                  ? secondaryColor
                                  : (statusPinjam == 0 && isOnDebt)
                                      ? Colors.red
                                      : (dataSnapshot['sisa_jam'] == "0:00:00")
                                          ? Colors.grey
                                          : Colors.green,
                            )
                          ],
                        ))),
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
                  child: Scrollbar(
                      thickness: 5,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SafeArea(
                          child: LayoutBuilder(
                            builder: (BuildContext context,
                                BoxConstraints constraints) {
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
                      )),
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
            var sepeda = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(bottom: (statusPinjam != 0) ? 70.0 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // SizedBox(
                    //     height: dataSnapshot['sisa_jam'] != '4:00:00' ? 10 : 0),
                    Text(
                      "Pilih shelter peminjaman",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Dimana kamu mau meminjam sepeda?",
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: 6.0),
                    SizedBox(
                      height: 65,
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (BuildContext context, int index) {
                            List listSepeda = [
                              "Sepeda Gunung",
                              "Sepeda Fixie",
                              "Sepeda Lipat"
                            ];
                            return Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                margin: const EdgeInsets.all(0),
                                width: 150,
                                child: Card(
                                  color: _listSepeda.contains(listSepeda[index])
                                      ? secondaryColor
                                      : lightBlue,
                                  shadowColor: greyOutline,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10.0),
                                    ),
                                  ),
                                  elevation: 3,
                                  child: ListTile(
                                      onTap: () {
                                        if (_listSepeda
                                            .contains(listSepeda[index])) {
                                          setState(() {
                                            _listSepeda
                                                .remove(listSepeda[index]);
                                            var filteredJenisSepeda =
                                                sepeda.where(((bike) {
                                              return bike.fields.jenisSepeda
                                                      .value ==
                                                  listSepeda[index];
                                            })).toList();
                                            newfilteredList = newfilteredList
                                                .where((i) =>
                                                    !filteredJenisSepeda
                                                        .contains(i))
                                                .toList();
                                          });
                                        } else {
                                          setState(() {
                                            _listSepeda.add(listSepeda[index]);
                                            newfilteredList = [];
                                            _listSepeda.forEach((spd) {
                                              var filteredJenisSepeda =
                                                  sepeda.where(((bike) {
                                                return bike.fields.jenisSepeda
                                                        .value ==
                                                    spd;
                                              })).toList();
                                              newfilteredList
                                                  .addAll(filteredJenisSepeda);
                                            });
                                          });
                                        }
                                      },
                                      title: Text(
                                        listSepeda[index],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                            textStyle: TextStyle(
                                                color: primaryColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                      )),
                                ));
                          }),
                    ),
                    SizedBox(height: 8.0),
                    isFiltered
                        ? CircularProgressIndicator()
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            itemCount: _listFakultas.length,
                            itemBuilder: (context, index) {
                              if (_listSepeda.length == 0) {
                                filteredList = sepeda.where(((bike) {
                                  return bike.fields.fakultas.value ==
                                      convertFakultas(_listFakultas[index]);
                                })).toList();
                                totalSepeda.add(filteredList.length);
                              } else {
                                filteredList = newfilteredList.where(((bike) {
                                  return bike.fields.fakultas.value ==
                                      convertFakultas(_listFakultas[index]);
                                })).toList();
                                totalSepeda.add(filteredList.length);
                              }
                              List fixedList = [];
                              filteredList.forEach((spd) {
                                fixedList.add(spd.fields.kodeSepeda.value);
                              });

                              bool alreadySaved =
                                  favFakultas.contains(_listFakultas[index]);

                              return Card(
                                color: mediumBlue,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 4.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16.0),
                                  ),
                                ),
                                elevation: 6,
                                child: ListTile(
                                  title: Text(
                                      'Fakultas ${_listFakultas[index]}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6),
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
                                          String currentUser = firebase
                                              .currentUser!.uid
                                              .toString();
                                          if (!alreadySaved) {
                                            favFakultas
                                                .add(_listFakultas[index]);
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
                                          bike: fixedList,
                                          isFiltered: _listSepeda.length != 0,
                                          totalSepeda: totalSepeda[index],
                                          fakultas: _listFakultas[index],
                                          fakultasDb: convertFakultas(
                                              _listFakultas[index]),
                                          statusPinjam: statusPinjam)),
                                ),
                              );
                            },
                          ),
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
