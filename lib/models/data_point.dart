import 'package:google_maps_flutter/google_maps_flutter.dart';

class DataPoint {
  final LatLng location;
  final double value;

  DataPoint(this.location, this.value);
}