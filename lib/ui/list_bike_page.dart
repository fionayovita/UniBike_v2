import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unibike/api/api_service.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/model/bike_model2.dart';
import 'package:unibike/widgets/bottom_sheet.dart';
import 'package:unibike/widgets/card_sepeda.dart';

class ListBikeArgs {
  final List<ListSepeda> bike;
  final String? fakultas;
  int statusPinjam = 0;
  int totalSepeda;
  final String? fakultasDb;

  ListBikeArgs({
    required this.bike,
    required this.fakultas,
    required this.statusPinjam,
    required this.fakultasDb,
    required this.totalSepeda,
  });
}

class ListBikePage extends StatefulWidget {
  static const routeName = 'list_bike_page';
  final List<ListSepeda> bike;
  final String? fakultas;
  int statusPinjam;
  int totalSepeda;
  final String? fakultasDb;

  ListBikePage(
      {required this.bike,
      required this.totalSepeda,
      required this.fakultas,
      required this.statusPinjam,
      required this.fakultasDb});

  @override
  _ListBikePageState createState() => _ListBikePageState();
}

class _ListBikePageState extends State<ListBikePage> {
  final firebase = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  final CollectionReference status =
      FirebaseFirestore.instance.collection('data_peminjaman');
  final CollectionReference dbSepeda =
      FirebaseFirestore.instance.collection('data_sepeda');
  late StreamSubscription<DocumentSnapshot> _subscription;
  Future<List<ListSepeda>>? dataSepeda;
  bool _isLoading = true;
  var dataUser;
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
      result = await _connectivity.checkConnectivity().then((value) {
        if (value != ConnectivityResult.none) {
          dataSepeda = ApiService.fetchDataSepeda();
          dataLoadFunction();
          streamStatusPinjam();
        } else {
          print("ga ada koneksi");
          setState(() {
            _isLoading = false;
          });
        }
        return value;
      }).timeout(const Duration(seconds: 5));
      ;
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status ${e}');
      return;
    } on TimeoutException catch (e) {}
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
    // if (_connectionStatus != ConnectivityResult.none) {
    //   dataLoadFunction();
    // }
  }

  dataLoadFunction() async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });
    dataSepeda = ApiService.fetchDataSepeda();
    setState(() {
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }

  pinjamSepedaFunction() async {
    setState(() {
      _isLoading = true; // your loader has started to load
    });
    dataLoadFunction();

    streamStatusPinjam();
    String currentUser = firebase.currentUser!.uid.toString();
    users.doc(currentUser).update(
      {'status': 1},
    );
    setState(() {
      widget.statusPinjam = 1;
      _isLoading = false; // your loder will stop to finish after the data fetch
    });
  }

  streamStatusPinjam() async {
    setState(() {
      _isLoading = true;
    });
    try {
      String currentUser = firebase.currentUser!.uid.toString();
      final Stream<DocumentSnapshot> userStream =
          users.doc('$currentUser').snapshots();
      _subscription = userStream.listen((data) {
        Map<String, dynamic> data_user = data.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            dataUser = data ?? [];
            isOnDebt = data_user.containsKey('denda_pinjam');
            widget.statusPinjam = data['status'];
          });
        }
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
//
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      body: RefreshIndicator(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth <= 700) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 17.0, vertical: 20.0),
                      child: _content(context, 2));
                } else if (constraints.maxWidth <= 1100) {
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80.0, vertical: 20.0),
                      child: _content(context, 3));
                } else {
                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 550.0, vertical: 20.0),
                      child: _content(context, 5));
                }
              },
            ),
          ),
        ),
        onRefresh: () async {
          onRefresh();
        },
      ),
      bottomSheet: (widget.statusPinjam != 0)
          ? BottomSheetWidget(onPressedPinjam: ((bool isPressed) {
              isPressed ? dataLoadFunction() : null;
            }))
          : null,
    );
  }

  Widget _content(BuildContext context, int gridCount) {
    double widthText = MediaQuery.of(context).size.width - 120;
    var size = MediaQuery.of(context).size;
    final double itemHeight = (size.height - kToolbarHeight - 24) / 3;
    final double itemWidth = size.width / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 15),
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
            SizedBox(
                width: widthText,
                child: Text(
                  "Shelter Fakultas ${widget.fakultas}",
                  style: Theme.of(context).textTheme.headline5,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ))
          ],
        ),
        SizedBox(height: 2),
        Divider(color: underline),
        SizedBox(height: 5),
        _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : FutureBuilder<List<ListSepeda>>(
                future: dataSepeda,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'assets/logoBulet.png',
                            width: 250,
                            height: 250,
                          ),
                          Text("Terjadi error, silahkan refresh halaman.",
                              style: Theme.of(context).textTheme.headline5)
                        ],
                      ),
                    );
                  } else if (snapshot.connectionState == ConnectionState.none &&
                      _connectionStatus == ConnectivityResult.none) {
                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          child: Icon(Icons.wifi_off, color: primaryColor),
                          backgroundColor: secondaryColor,
                        ),
                        Text('Tidak ada koneksi',
                            style: TextStyle(color: Colors.black))
                      ],
                    ));
                  } else if (snapshot.hasData &&
                      snapshot.connectionState == ConnectionState.done) {
                    var filteredList = snapshot.data!.where(((bike) {
                      return bike.fields.fakultas.value == widget.fakultasDb;
                    })).toList();
                    return filteredList.length == 0
                        ? Center(
                            child: Column(
                              children: <Widget>[
                                Image.asset(
                                  'assets/logoBulet.png',
                                  width: 250,
                                  height: 250,
                                ),
                                Text(
                                    "Tidak ada sepeda yang tersedia di shelter ini",
                                    style:
                                        Theme.of(context).textTheme.headline5)
                              ],
                            ),
                          )
                        : GridView.count(
                            physics: ScrollPhysics(),
                            crossAxisCount: gridCount,
                            childAspectRatio: (itemWidth / itemHeight),
                            shrinkWrap: true,
                            children: List.generate(
                              filteredList.length,
                              (index) {
                                return CardSepeda(
                                  bike: filteredList[index],
                                  fakultas: widget.fakultas,
                                  onDebt: isOnDebt,
                                  statusPinjam: widget.statusPinjam,
                                  onPressedPinjam: ((bool isPressed) {
                                    isPressed ? pinjamSepedaFunction() : null;
                                  }),
                                );
                              },
                            ),
                          );
                  }
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }),
      ],
    );
  }

  Future<void> onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    print("isrefreshing");
    await dataLoadFunction();
    setState(() {
      _isLoading = false;
    });
  }
}