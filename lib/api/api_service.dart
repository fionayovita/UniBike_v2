import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:unibike/model/bike_model2.dart';

String _dataSepedaUrl =
    'https://firestore.googleapis.com/v1/projects/unibike-13780/databases/(default)/documents/data_sepeda/';

class ApiService {
  static Future<List<ListSepeda>> fetchDataSepeda() async {
    final _complete = Completer<List<ListSepeda>>();

    try {
      final resp = await http.get(Uri.parse(_dataSepedaUrl));
      if (resp.statusCode == 200) {
        final decode = json.decode(resp.body);
        final docs = decode['documents'];

        final _data = bikeModelFromJson(docs);
        _complete.complete(_data);
      }
    } catch (exc) {
      print(exc);
      _complete.completeError(<List<ListSepeda>>[]);
    }

    return _complete.future;
  }
}
