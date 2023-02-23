import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/widgets/custom_dialog.dart';

class KembalikanSepeda {
  BuildContext context;
  final firebase = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;
  var data;
  Function setState;
  String currentUser;
  final CollectionReference status =
      FirebaseFirestore.instance.collection('data_peminjaman');
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  ConnectivityResult connectionStatus;

  String? fakultas;
  String fakultasState = '';
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

  KembalikanSepeda(
      {required this.context,
      required this.data,
      required this.setState,
      required this.currentUser,
      required this.connectionStatus});

  mengembalikanSepeda() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return new SimpleDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              elevation: 0,
              title: new Text('Fakultas pengembalian sepeda: ',
                  style: Theme.of(context).textTheme.headline5),
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                    decoration: BoxDecoration(
                      color: secondaryColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: 3,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                        child: DropdownButton(
                          isExpanded: true,
                          iconEnabledColor: primaryColor,
                          dropdownColor: secondaryColor,
                          hint: Text("Pilih Fakultas",
                              style: Theme.of(context).textTheme.subtitle2),
                          value: fakultas,
                          items: _listFakultas.map(
                            (value) {
                              return DropdownMenuItem<String>(
                                child: Text(value,
                                    style:
                                        Theme.of(context).textTheme.subtitle2),
                                value: value,
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            setState(
                              () {
                                fakultas = value as String;
                                var idx = _listFakultas.indexOf(value);
                                fakultasState = _fakultasDb[idx];
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                        child: Text(
                          'Kirim',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        onPressed: fakultas == null
                            ? () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomDialog(
                                      title: 'Pilih shelter terlebih dahulu!',
                                      descriptions:
                                          'Silahkan pilih salah satu shelter dimana anda mau mengembalikan sepeda yang anda pinjam.',
                                      text: 'OK',
                                    );
                                  },
                                )
                            : () async {
                                var batasWaktu = data['waktu_kembali'].toDate();
                                var waktuKembali = DateTime.now();
                                var selisihJam =
                                    batasWaktu.difference(waktuKembali);
                                var selisihJamNegatif = selisihJam
                                    .toString()
                                    .replaceAll(RegExp('-'), '');

                                if (connectionStatus !=
                                    ConnectivityResult.none) {
                                  try {
                                    status
                                        .doc(firebase.currentUser?.uid)
                                        .delete()
                                        .catchError((error) => print(
                                            "Failed to return bike: $error"));

                                    firestore
                                        .collection('history_peminjaman')
                                        .doc(firebase.currentUser?.uid)
                                        .collection('user_history')
                                        .doc()
                                        .set(
                                      {
                                        'id_sepeda': data['id_sepeda'],
                                        'jenis_sepeda': data['jenis_sepeda'],
                                        'email_peminjam':
                                            data['email_peminjam'],
                                        'waktu_pinjam': data['waktu_pinjam'],
                                        'waktu_kembali': waktuKembali,
                                        'fakultas_pinjam': data['fakultas'],
                                        'fakultas_kembali': fakultas
                                      },
                                    );

                                    firestore
                                        .collection('data_sepeda')
                                        .doc('${data['id_sepeda']}')
                                        .update(
                                      {
                                        'status': 'Tersedia',
                                        'fakultas': fakultasState
                                      },
                                    );
                                    if (selisihJam.isNegative) {
                                      users.doc(currentUser).update(
                                        {
                                          'status': 0,
                                          'sisa_jam': '0:00:00',
                                          'peminjaman_terakhir': waktuKembali,
                                          'denda_pinjam': selisihJamNegatif
                                        },
                                      );
                                    } else {
                                      users.doc(currentUser).update(
                                        {
                                          'status': 0,
                                          'sisa_jam': selisihJam.toString(),
                                          'peminjaman_terakhir': waktuKembali
                                        },
                                      );
                                    }
                                    Navigator.of(context).pop();
                                    return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialog(
                                          title: 'Sukses!',
                                          descriptions:
                                              'Berhasil mengembalikan sepeda, peminjaman sepeda anda selesai.',
                                          text: 'OK',
                                        );
                                      },
                                    );
                                  } catch (e) {
                                    return showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return CustomDialog(
                                          title: 'Pengembalian Gagal',
                                          descriptions:
                                              'Error, silahkan coba lagi beberapa saat kemudian!',
                                          text: 'OK',
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  return showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return CustomDialog(
                                        title: 'Pengembalian Gagal',
                                        descriptions:
                                            'Error, silahkan cek koneksi anda dan coba lagi beberapa saat kemudian!',
                                        text: 'OK',
                                      );
                                    },
                                  );
                                }
                              }),
                  ),
                )
              ],
            );
          });
        }).then((value) {
      setState(() {});
    });
  }
}
