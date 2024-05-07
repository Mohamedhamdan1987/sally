import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sally/MapScreen.dart';

class addReport extends StatefulWidget {
  final String reportType;

  addReport({Key? key, required this.reportType}) : super(key: key);

  @override
  _addReportState createState() => _addReportState();
}

class _addReportState extends State<addReport> {
  final description = TextEditingController();
  final addressz = TextEditingController();
  String _locationMessage = '';
  LatLng _selectedLocation = const LatLng(32.0161, 35.8695);
  bool showMap = false;
//********************************************************** */

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
    getCurrentLocation();
    addressz.clear();
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      String address = "${place.name}, ${place.locality}, ${place.country}";
      setState(() {
        addressz.clear();
        _locationMessage = address;
        addressz.clear();
      });
    } catch (e) {
      setState(() {
        _locationMessage = 'Error: ${e.toString()}';
      });
    }
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
        print("------- 1 ------------");
      setState(() {
        print("------- 2 ------------");

        _selectedLocation = LatLng(position.latitude, position.longitude);

      });

      // await getLocationDetails();

    }

  }

  @override
  Widget build(BuildContext context) {
    //final controller = Get.put(ReportsController());

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
          centerTitle: true,
          title: const Text('Add Report',
              style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontStyle: FontStyle.italic)),
          backgroundColor: const Color.fromARGB(255, 195, 235, 197),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_outlined),
              onPressed: () {
                //  Get.back();
              })),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                enabled: false,
                readOnly: true,
                decoration: const InputDecoration(
                    hintText: 'Report Type : ', filled: true),
                controller: TextEditingController(text: widget.reportType),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      enabled: true,
                      decoration: const InputDecoration(
                          hintText: 'Address :', filled: true),
                      controller: addressz..text = _locationMessage,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.location_on),
                    onPressed: () async {
                      await getCurrentLocation();


                      LatLng selectedLocation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            selectedLocation:
                                _selectedLocation, // Pass your selected location here
                            onLocationSelected: (location) {
                              setState(() async {
                                _selectedLocation = location;
                                List<Placemark> placemarks =
                                    await placemarkFromCoordinates(
                                        location.latitude, location.longitude);
                                Placemark? place = placemarks.isNotEmpty
                                    ? placemarks[0]
                                    : null;
                                String address = place != null
                                    ? "${place.street}, ${place.locality}, ${place.country}"
                                    : 'Unknown Location';
                                setState(() {
                                  _locationMessage = address;
                                });
                              });
                              Navigator.pop(context,
                                  location); // Pop the map screen and return the selected location
                            },
                          ),
                        ),
                      );
                      setState(() {
                        _selectedLocation = selectedLocation;
                      });
                    },
                  ),
                ],
              ),

              ////////////////////////////////////////////////////////////////////////
              TextField(
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                enabled: true,
                controller: description,
                decoration: const InputDecoration(
                  hintText: 'Description : ',
                  filled: true,
                ),
              ),

              TextField(
                keyboardType: TextInputType.datetime,
                enabled: false,
                decoration: const InputDecoration(
                  hintText: 'date : ',
                  filled: true,
                ),
                controller: TextEditingController(
                    //text: DateFormat('yyyy-MM-dd - h:mm').format(DateTime.now()),
                    ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Submit'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () async {
      },),
    );
  }
}
