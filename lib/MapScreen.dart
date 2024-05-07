// ignore_for_file: avoid_unnecessary_containers

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatefulWidget {
  final LatLng selectedLocation;
  final Function(LatLng) onLocationSelected;

  const MapScreen({
    Key? key,
    required this.selectedLocation,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late LatLng mapSelectedLocation;
  MapController mapController = MapController();

  @override
  void initState() {
    mapSelectedLocation = widget.selectedLocation; //changes the marker
    super.initState();
  }


  getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;


    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.rawSnackbar(
          title: "Warning",
          messageText: const Text("you must enable location service :( "));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied)
    {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.rawSnackbar(
            title: "Warning",
            messageText:
            const Text("you must allow our app to access location !!!"));
        return;
      }
      else if (permission == LocationPermission.whileInUse) {
        await getCurrentLocation();
      }
    }
    else if (permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        print(position.latitude);
        print(position.longitude);
        mapSelectedLocation = LatLng(position.latitude, position.longitude);
        mapController.move(LatLng(position.latitude, position.longitude), 14);

      });

      // await getLocationDetails();

    }

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map View'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: mapSelectedLocation,
              zoom: 15.0,
              onTap: (TapPosition tapPosition, LatLng location) {
                setState(() {
                  mapSelectedLocation = location;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 80.0,
                    height: 80.0,
                    point: mapSelectedLocation,
                    builder: (ctx) => Container(
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            right: 20,
            child: FloatingActionButton(onPressed: () async {
              await getCurrentLocation();

            },
            child: Icon(Icons.location_on_outlined),),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(onPressed: ()  {
              Navigator.pop(context); // Go back to the previous screen
              log(mapSelectedLocation.toString());
              widget.onLocationSelected(
                  mapSelectedLocation); //bring the value to the etxt field
            },
            child: Icon(Icons.check),),
          ),
          Text("${mapSelectedLocation.longitude} ----- ${mapSelectedLocation.longitude}"),


        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //
      //     // Navigator.pop(context); // Go back to the previous screen
      //     // log(mapSelectedLocation.toString());
      //     // widget.onLocationSelected(
      //     //     mapSelectedLocation); //bring the value to the etxt field
      //   },
      //   child: const Icon(Icons.check),
      // ),
    );
  }
}
