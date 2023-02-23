// ignore_for_file: prefer_single_quotes

import 'dart:convert';

List<ListSepeda> bikeModelFromJson(str) => List<ListSepeda>.from(
    str.map((x) => ListSepeda.fromJson(x)).where((bike) => bike != null));

String bikeToJson(List<Sepeda> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ListSepeda {
  ListSepeda({
    required this.name,
    required this.fields,
  });

  String name;
  Sepeda fields;

  factory ListSepeda.fromJson(Map<String, dynamic> json) => ListSepeda(
        name: json['name'],
        fields: Sepeda.fromJson(json['fields']),
      );

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['fields'] = this.fields;

    return data;
  }
}

class Sepeda {
  Sepeda(
      {required this.jenisSepeda,
      required this.status,
      required this.tahun,
      required this.merkSepeda,
      required this.deskripsi,
      required this.fakultas,
      required this.fotoSepeda,
      required this.kodeSepeda});

  Value jenisSepeda;
  Value status;
  Value tahun;
  Value merkSepeda;
  Value deskripsi;
  Value fakultas;
  Value fotoSepeda;
  Value kodeSepeda;

  factory Sepeda.fromJson(Map<String, dynamic> json) => Sepeda(
      jenisSepeda: Value.fromJson(json['jenis_sepeda']),
      status: Value.fromJson(json['status']),
      tahun: Value.fromJson(json['tahun']),
      merkSepeda: Value.fromJson(json['merk_sepeda']),
      fakultas: Value.fromJson(json['fakultas']),
      deskripsi: Value.fromJson(json['deskripsi']),
      fotoSepeda: Value.fromJson(json['foto_sepeda']),
      kodeSepeda: Value.fromJson(json['kode_sepeda']));

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jenis_sepeda'] = this.jenisSepeda;
    data['status'] = this.status;
    data['tahun'] = this.tahun;
    data['fakultas'] = this.fakultas;
    data['merk_sepeda'] = this.merkSepeda;
    data['deskripsi'] = this.deskripsi;
    data['foto_sepeda'] = this.fotoSepeda;
    data['kode_sepeda'] = this.kodeSepeda;
    return data;
  }
}

class Value {
  Value({
    required this.value,
  });

  String? value;

  // factory Value.fromJson(Map<String, dynamic> json) => Value(
  //       value: json['stringValue'],
  //     );
  Value.fromJson(Map<String, dynamic> json) {
    value = json['stringValue'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stringValue'] = this.value;

    return data;
  }
}
