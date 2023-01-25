class BikeResult {
  BikeResult({
    required this.bikes,
  });
  List<Bike> bikes;

  factory BikeResult.fromJson(Map<String, dynamic> json) => BikeResult(
        bikes: List<Bike>.from((json["bikes"] as List)
            .map((x) => Bike.fromJson(x))
            .where((bike) =>
                bike.frameModel != null &&
                bike.largeImg != null &&
                bike.title != null)),
      );

  Map<String, dynamic> toJson() => {
        "bikes": List<dynamic>.from(bikes.map((x) => x.toJson())),
      };
}

class Bike {
  Bike({
    required this.frameModel,
    required this.id,
    required this.isStockImg,
    required this.largeImg,
    required this.title,
  });

  String? frameModel;
  int id;
  bool isStockImg;
  String? largeImg;
  String? title;

  factory Bike.fromJson(Map<String, dynamic> json) => Bike(
        frameModel: json["frame_model"],
        id: json["id"],
        isStockImg: json["is_stock_img"],
        largeImg: json["large_img"],
        title: json["title"],
      );

  Map<String, dynamic> toJson() => {
        "frame_model": frameModel,
        "id": id,
        "is_stock_img": isStockImg,
        "large_img": largeImg,
        "title": title,
      };
}
