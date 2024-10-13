class AnimalReport {
  String id;
  String description;
  final String area;
  String imageUrl;
  final String latitude;
  final String longitude;

  AnimalReport(
      {required this.id,
      required this.description,
      required this.area,
      required this.latitude,
      required this.longitude,
      required this.imageUrl});
}
