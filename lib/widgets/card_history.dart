import 'package:flutter/material.dart';
import 'package:unibike/common/styles.dart';

class CardHistory extends StatelessWidget {
  final String jenisSepeda;
  final String fakultasPinjam;
  final String fakultasKembali;
  final String waktuPinjam;
  final String waktuKembali;

  const CardHistory(
      {required this.jenisSepeda,
      required this.fakultasPinjam,
      required this.fakultasKembali,
      required this.waktuPinjam,
      required this.waktuKembali});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: const EdgeInsets.symmetric(vertical: 13, horizontal: 13),
      elevation: 2,
      shadowColor: greyButton,
      color: whiteBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Jenis Sepeda',
              style: TextStyle(fontSize: 15.0, color: greyOutline),
            ),
            Text(jenisSepeda, style: Theme.of(context).textTheme.headline5),
            SizedBox(height: 8),
            Text(
              'Fakultas Pinjam: $fakultasPinjam',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 6),
            Text(
              'Fakultas Pengembalian: $fakultasKembali',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            SizedBox(height: 6),
            Text('Waktu Pinjam: $waktuPinjam',
                style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 6),
            Text('Waktu Pengembalian: $waktuKembali',
                style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}
