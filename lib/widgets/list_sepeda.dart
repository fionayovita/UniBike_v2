import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unibike/api/api_service.dart';
import 'package:unibike/common/styles.dart';
import 'package:unibike/provider/bike_provider.dart';
import 'package:unibike/widgets/card_sepeda.dart';

class ListSepeda extends StatelessWidget {
  final int length;
  final int gridCount;
  final String? fakultas;
  ListSepeda(
      {required this.length, required this.gridCount, required this.fakultas});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BikeProvider>(
      create: (_) => BikeProvider(apiService: ApiService()).getBikes(),
      child: Consumer<BikeProvider>(
        builder: (context, state, _) {
          if (state.state == ResultState.Loading) {
            return Center(child: CircularProgressIndicator());
          } else if (state.state == ResultState.HasData) {
            return GridView.count(
              physics: ScrollPhysics(),
              crossAxisCount: gridCount,
              shrinkWrap: true,
              children: List.generate(
                1,
                (index) {
                  var sepeda = state.resultSepeda;
                  final filteredList = sepeda
                      .where((bike) => bike.fields.fakultas.value == 'fk')
                      .toList();
                  return CardSepeda(
                    bike: filteredList[index],
                    onDebt: true,
                    statusPinjam: 1,
                    fakultas: fakultas,
                    onPressedPinjam: ((bool) => null),
                  );
                },
              ),
            );
          } else if (state.state == ResultState.NoData) {
            return Center(child: Text(state.message));
          } else if (state.state == ResultState.Error) {
            return Center(
                child: Column(
              children: <Widget>[
                CircleAvatar(
                  child: Icon(Icons.wifi_off, color: primaryColor),
                  backgroundColor: secondaryColor,
                ),
                Text('Tidak ada koneksi', style: TextStyle(color: Colors.black))
              ],
            ));
          } else {
            return Center(
                child: Text('error', style: TextStyle(color: Colors.black)));
          }
        },
      ),
    );
  }
}
