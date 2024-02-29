import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ra9mana/models/data_point.dart';
import 'package:ra9mana/providers/locarion_provider.dart';
import 'package:ra9mana/utils/printer.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MapsPage extends ConsumerStatefulWidget {
  const MapsPage({super.key});

  @override
  ConsumerState<MapsPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MapsPage> {
  // ignore: unused_field
  late GoogleMapController _controller;

  List<Object?> carrierNames = [];
  final plateform = const MethodChannel("com.example/carrier_info");

  Future<void> initPlatformState() async {
    try {
      carrierNames = await plateform.invokeMethod('getCarrierNames');
    } on PlatformException catch (e) {
      printDebug("Failed to get carrier names: '${e.message}'.");
    }
  }

  final List<Image> _logos = [
    Image.asset("assets/ATM_Mobilis.svg.png"),
    Image.asset("assets/djezzy-seeklogo.png"),
    Image.asset("assets/ORDS.AE.png"),
  ];
  final Map<String, int> _providers = {"Mobilis": 0, "Djezzy": 1, "Ooredoo": 2};
  late Set<Marker> _markers;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    initCam();
    _markers = dataPoints.map((dataPoint) {
      return Marker(
        markerId: MarkerId(dataPoint.location.toString()),
        position: dataPoint.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      );
    }).toSet();
  }

  Future<void> initCam() async {
    await ref.read(locationProvider.notifier).getLocation();
  }

  List<DataPoint> dataPoints = [
    DataPoint(const LatLng(35.690688, -0.645711), 0.5),
    DataPoint(const LatLng(35.662410, -0.632905), 0.8),
    DataPoint(const LatLng(35.659907, -0.584917), 0.2),
    DataPoint(const LatLng(35.659072, -0.673797), 0.1),
  ];
  Random random = Random();
  int index = 1;
  List<DataPoint> generateRandomDataPoints(LatLng target, double zoom) {
    double radiusDegrees = 0.5 / zoom; // Adjust this value as needed

    return List<DataPoint>.generate(random.nextInt(5) + 1, (index) {
      // Generate 10 data points
      double lat =
          target.latitude + (random.nextDouble() * 2 - 1) * radiusDegrees;
      double lng =
          target.longitude + (random.nextDouble() * 2 - 1) * radiusDegrees;
      double value =
          random.nextDouble() / 2; // Generate a random value between 0 and 1

      return DataPoint(LatLng(lat, lng), value);
    });
  }

  void generateDataPoints() {
    LatLng target = _cameraPos.target;
    double zoom = _cameraPos.zoom;
    dataPoints = generateRandomDataPoints(target, zoom);
    _markers = dataPoints.map((dataPoint) {
      return Marker(
        markerId: MarkerId(dataPoint.location.toString()),
        position: dataPoint.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      );
    }).toSet();
  }

  CameraPosition _cameraPos = const CameraPosition(
    target: LatLng(35.690688, -0.645711),
    zoom: 12,
  );
  @override
  Widget build(BuildContext context) {
    // final location = ref.watch(locationProvider);
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SpeedDial(
              activeChild: const Icon(Icons.add),
              childrenButtonSize: const Size(50, 50),
              children: _providers.keys
                  .map((e) => SpeedDialChild(
                        child: _logos[_providers[e]!],
                        onTap: () {
                          setState(() {
                            index = _providers[e]!;
                          });
                        },
                      ))
                  .toList(),
              child: SizedBox(
                height: 35,
                child: _logos[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _loading = true;
                    });
                    await Future.delayed(const Duration(seconds: 1));
                    setState(() {
                      _loading = false;
                      generateDataPoints();
                    });
                  },
                  child: const Text("Scan here")),
            )
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              circles: dataPoints
                  .map((dataPoint) => Circle(
                        circleId: CircleId(dataPoint.location.toString()),
                        center: dataPoint.location,
                        radius: 2500,
                        fillColor: Colors.blue.withOpacity(dataPoint.value),
                        strokeWidth: 0,
                      ))
                  .toSet(),
              markers: _markers,
              onCameraMove: (position) {
                setState(() {
                  _cameraPos = position;
                });
              },
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                _controller = controller;
              },
              initialCameraPosition: const CameraPosition(
                zoom: 12,
                target: LatLng(35.690688, -0.645711),
              ),
            ),
            Positioned(
                child: Center(
                    child:
                        _loading ? const CircularProgressIndicator() : null)),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: true,
                child: Row(
                  children: [
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: SearchBar(
                          hintText: "Search for a location",
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.white),
                          leading: Icon(Icons.search),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: FloatingActionButton(
                        onPressed: () {
                          // ref.read(locationProvider.notifier).getLocation();
                          _controller.animateCamera(
                            CameraUpdate.newLatLngZoom(
                                const LatLng(35.690688, -0.645711), 12),
                          );
                        },
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.my_location_outlined),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }
}
