import 'package:flutter/cupertino.dart';
import 'package:unibike/api/api_service.dart';
import 'package:unibike/model/bike_model2.dart';

enum ResultState { Loading, NoData, HasData, Error }

class BikeProvider extends ChangeNotifier {
  final ApiService apiService;

  BikeProvider({required this.apiService}) {
    fetchDataSepeda();
  }

  BikeProvider getBikes() {
    fetchDataSepeda();
    return this;
  }

  late List<ListSepeda> _resultSepeda;
  late ResultState _state;
  String _message = '';

  List<ListSepeda> get userModel => _userModel;
  var _userModel = <ListSepeda>[];
  String get message => _message;

  List<ListSepeda> get resultSepeda => _resultSepeda;

  ResultState get state => _state;

  Future<dynamic> fetchDataSepeda() async {
    // try {
    //   _state = ResultState.Loading;
    //   notifyListeners();
    //   final bike = await ApiService.fetchDataSepeda();
    //   if (bike.isEmpty) {
    //     _state = ResultState.NoData;
    //     notifyListeners();
    //     return _message = 'Empty Data';
    //   } else {
    //     _state = ResultState.HasData;
    //     _resultSepeda = bike;
    //     notifyListeners();
    //     return _resultSepeda = bike;
    //   }
    // } catch (e) {
    //   _state = ResultState.Error;
    //   notifyListeners();
    //   return _message = 'Error --> $e';
    // }
    _userModel = await ApiService.fetchDataSepeda();
    _resultSepeda = _userModel;
    notifyListeners();
    return _resultSepeda = _userModel;
  }
}
