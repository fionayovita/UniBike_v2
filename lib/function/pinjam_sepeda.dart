import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unibike/model/bike_model2.dart';
import 'package:unibike/widgets/confirmation_dialog.dart';
import 'package:unibike/widgets/custom_dialog.dart';

class PinjamSepeda {
  int? statusPinjam;
  bool onDebt;
  BuildContext context;
  ConnectivityResult connectionStatus;
  final ListSepeda bike;
  String sisaJam;
  final firebase = FirebaseAuth.instance;
  final _store = FirebaseFirestore.instance;
  final CollectionReference sepeda =
      FirebaseFirestore.instance.collection('data_sepeda');
  final String? fakultas;
  final Function(bool, DateTime) onPressedPinjam;
  Function setState;

  PinjamSepeda(
      {required this.statusPinjam,
      required this.onDebt,
      required this.context,
      required this.connectionStatus,
      required this.bike,
      required this.sisaJam,
      required this.fakultas,
      required this.onPressedPinjam,
      required this.setState});

  MeminjamSepeda() async {
    String emailUser = firebase.currentUser!.email.toString();
    String docId = bike.name.replaceAll(
        'projects/unibike-13780/databases/(default)/documents/data_sepeda/',
        '');
    print("masuk sini ga");
    statusPinjam == 0
        ? onDebt
            ? showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomDialog(
                    title: 'Anda memiliki denda waktu peminjaman!',
                    descriptions:
                        'Anda telat mengembalikan sepeda di peminjaman sebelumnya, sehingga tidak dapat meminjam sepeda selama satu hari.',
                    text: 'OK',
                  );
                },
              )
            : showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ConfirmationDialog(
                      text: "Apakah kamu yakin ingin meminjam sepeda ini?",
                      onPressedPinjam: () {
                        if (connectionStatus != ConnectivityResult.none) {
                          try {
                            final jenisSepeda = bike.fields.jenisSepeda.value;
                            var today = DateTime.now();

                            var sisaJamSplit = sisaJam.split(':');
                            var sisaJamInDate = new DateTime(
                                today.year,
                                today.month,
                                today.day,
                                int.parse(sisaJamSplit[0]),
                                int.parse(sisaJamSplit[1]),
                                0);

                            var formattedTime = new DateTime(
                                today.year, today.month, today.day, 0, 0, 0);

                            Duration timeDifference =
                                sisaJamInDate.difference(formattedTime);

                            var kembali = today.add(Duration(
                                seconds: sisaJam != "4:00:00"
                                    ? timeDifference.inSeconds
                                    : 14400));

                            _store
                                .collection('data_peminjaman')
                                .doc(firebase.currentUser?.uid)
                                .set(
                              {
                                'id_sepeda': docId,
                                'jenis_sepeda': jenisSepeda,
                                'email_peminjam': emailUser,
                                'waktu_pinjam': today,
                                'waktu_kembali': kembali,
                                'fakultas': fakultas
                              },
                            );

                            sepeda.doc(docId).update(
                              {'status': 'Tidak Tersedia'},
                            );

                            onPressedPinjam(true, today);

                            return showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return CustomDialog(
                                  title: 'Sukses Pinjam Sepeda!',
                                  descriptions:
                                      'Silahkan cek status peminjaman di halaman Status Pinjam untuk melihat lebih detail',
                                  text: 'OK',
                                );
                              },
                            );
                          } catch (e) {
                            return showDialog(
                              context: context,
                              builder: (BuildContext context) {
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
                              fakultas;
                              bike;
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
  }
}
