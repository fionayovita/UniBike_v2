import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/widgets/list_sepeda.dart';

typedef OnChangeCallback = void Function(dynamic value);

class DropDownMenu2 extends StatefulWidget {
  String fakultasMain = '';

  @override
  State<DropDownMenu2> createState() => DropDownMenuState();
}

class DropDownMenuState extends State<DropDownMenu2> {
  String? fakultas;
  int lengthBike = 1;

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

  int lengthFakultas() {
    int length = lengthBike;
    if (fakultas == 'Teknik') {
      length = 3;
    } else if (fakultas == 'MIPA') {
      length = 6;
    } else if (fakultas == 'Ekonomi') {
      length = 8;
    } else if (fakultas == 'Kedokteran') {
      lengthBike = 5;
    } else if (fakultas == 'Pertanian') {
      lengthBike = 3;
    } else if (fakultas == 'Keguruan dan Ilmu Pendidikan') {
      length = 11;
    } else if (fakultas == 'Ilmu Sosial dan Pemerintahan') {
      length = 4;
    } else if (fakultas == 'Hukum') {
      length = 9;
    }
    lengthBike = length;
    return length;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: 12.0, top: 50.0 + 12.0, right: 12.0, bottom: 10),
          margin: EdgeInsets.only(top: 50.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: primaryColor,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                  color: greyOutline, offset: Offset(0, 10), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  'Fakultas pengembalian sepeda: ${fakultas == null ? '' : fakultas}',
                  style: Theme.of(context).textTheme.headline5),
              SizedBox(
                height: 15,
              ),
              dropdown(context),
              SizedBox(
                height: 22,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Submit',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget dropdown(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
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
                iconEnabledColor: primaryColor,
                dropdownColor: secondaryColor,
                hint: Text("Pilih Fakultas",
                    style: Theme.of(context).textTheme.subtitle2),
                value: fakultas,
                items: _listFakultas.map(
                  (value) {
                    return DropdownMenuItem<String>(
                      child: Text(value,
                          style: Theme.of(context).textTheme.subtitle2),
                      value: value,
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(
                    () {
                      fakultas = value as String;
                      widget.fakultasMain = value;

                      lengthBike = lengthFakultas();
                      ListSepeda(
                          length: lengthBike, gridCount: 4, fakultas: fakultas);
                    },
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 18.0),
      ],
    );
  }
}
