import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/widgets/list_sepeda.dart';

// typedef OnChangeCallback = void Function(dynamic value);

class DropDownMenu extends StatefulWidget {
  String fakultasMain = '';

  @override
  State<DropDownMenu> createState() => DropDownMenuState();
}

class DropDownMenuState extends State<DropDownMenu> {
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
        Container(
          child: fakultas == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Pilih fakultas untuk melihat jumlah sepeda',
                        style: Theme.of(context).textTheme.subtitle1),
                    SizedBox(height: 40.0),
                    Image.asset("assets/logoBulet.png", width: 250, height: 250)
                  ],
                )
              : Column(
                  children: [
                    Text(
                        'Sepeda yang tersedia di fakultas $fakultas: $lengthBike',
                        style: Theme.of(context).textTheme.subtitle1,
                        textAlign: TextAlign.center),
                    SizedBox(height: 15.0),
                    LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        if (constraints.maxWidth <= 700) {
                          return ListSepeda(
                            length: lengthBike,
                            gridCount: 2,
                            fakultas: fakultas,
                          );
                        } else if (constraints.maxWidth <= 1100) {
                          return ListSepeda(
                              length: lengthBike,
                              gridCount: 3,
                              fakultas: fakultas);
                        } else {
                          return ListSepeda(
                              length: lengthBike,
                              gridCount: 5,
                              fakultas: fakultas);
                        }
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
