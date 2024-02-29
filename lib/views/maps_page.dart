import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
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
  final LocationData location;
  @override
  void initState() {
    super.initState();
    initPlatformState();
    location = ref.watch(locationProvider);
    initCam();
    _markers = dataPoints.map((dataPoint) {
      return Marker(
        markerId: MarkerId(dataPoint.location.toString()),
        position: dataPoint.location,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          dataPoint.value * 360, // Hue value should be between 0 and 360
        ),
      );
    }).toSet();
  }

  Future<void> initCam() async {
    await ref.read(locationProvider.notifier).getLocation();
  }

  List<DataPoint> dataPoints = [
    DataPoint(const LatLng(37.4219999, -122.0840575), 0.5),
    // Add more data points as needed
  ];

  @override
  Widget build(BuildContext context) {
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
                        onTap: () {},
                      ))
                  .toList(),
              child: SizedBox(
                height: 35,
                child: _logos[1],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: ElevatedButton(
                  onPressed: () {}, child: const Text("Scan here")),
            )
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              markers: _markers,
              zoomControlsEnabled: false,
              onMapCreated: (controller) {
                _controller = controller;
              },
              initialCameraPosition: CameraPosition(
                zoom: 15,
                target: LatLng(
                  location.latitude ?? 0,
                  location.longitude ?? 0,
                ),
              ),
            ),
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
                        onPressed: () async {
                          await ref
                              .read(locationProvider.notifier)
                              .getLocation();
                          _controller.animateCamera(
                            CameraUpdate.newLatLng(
                              LatLng(
                                location.latitude ?? 0,
                                location.longitude ?? 0,
                              ),
                            ),
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
