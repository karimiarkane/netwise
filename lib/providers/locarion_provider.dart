import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';

class LocationNotifier extends StateNotifier<LocationData> {
  LocationNotifier(super._state);

  final Location _location = Location();
  


  Future<void> getLocation() async {
    var service = await _location.serviceEnabled();
    if (!service) service = await _location.requestService();
    if (!service) return;
    state = await _location.getLocation();
  }

  Future<void> setLocation(LocationData location) async {
    state = location;
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationData>((ref) {
  return LocationNotifier(LocationData.fromMap({}));
});
