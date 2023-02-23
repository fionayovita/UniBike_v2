import 'package:flutter/material.dart';

class InfoContainer extends StatelessWidget {
  final bool isOnDebt;
  final dynamic dataSnapshot;

  InfoContainer({required this.isOnDebt, required this.dataSnapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 17),
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
                  style: Theme.of(context).textTheme.headline6,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sisa waktu peminjaman hari ini:",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    SizedBox(height: 3),
                    Text(
                      "${dataSnapshot['sisa_jam'].split(':')[0]} Jam ${dataSnapshot['sisa_jam'].split(':')[1]} Menit",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    SizedBox(height: 7),
                  ],
                ),
          isOnDebt
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Denda waktu peminjaman anda:",
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    SizedBox(height: 3),
                    Text(
                      "${dataSnapshot['denda_pinjam'].split(':')[0]} Jam ${dataSnapshot['denda_pinjam'].split(':')[1]} Menit ${dataSnapshot['denda_pinjam'].split(':')[2].split('.')[0]} detik",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                )
              : Text(
                  "Anda tidak memiliki denda waktu peminjaman",
                  style: Theme.of(context).textTheme.headline6,
                )
        ],
      ),
    );
  }
}
