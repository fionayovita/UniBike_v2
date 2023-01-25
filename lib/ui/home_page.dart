import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/ui/history_peminjaman_page.dart';
import 'package:unibike/ui/main_page.dart';
import 'package:unibike/ui/profile_page.dart';
import 'package:unibike/ui/status_pinjam_page.dart';

class HomePage extends StatefulWidget {
  static const routeName = 'home_page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;

  List<Widget> _listPages() => [
        MainPage(),
        StatusPinjamPage(),
        HistoryPeminjamanPage(),
        ProfilePage(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _listPages()[_bottomNavIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: primaryColor,
        buttonBackgroundColor: secondaryColor,
        color: secondaryColor,
        height: 60,
        items: <Widget>[
          Icon(
            Icons.home,
            size: 30,
            color: primaryColor,
          ),
          Icon(
            Icons.note_alt_outlined,
            size: 30,
            color: primaryColor,
          ),
          Icon(
            Icons.history,
            size: 30,
            color: primaryColor,
          ),
          Icon(
            Icons.person_sharp,
            size: 30,
            color: primaryColor,
          ),
        ],
        onTap: (selected) {
          setState(() {
            _bottomNavIndex = selected;
          });
        },
      ),
    );
  }
}
