// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:track_wise/controllers/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class map extends StatefulWidget {
  const map({super.key});

  @override
  State<map> createState() => _mapState();
}

// ignore: camel_case_types
class _mapState extends State<map> {
  late double latitude;
  late double longtitude;
  String _destination = '';
  String _userId = '';
  String _reference = '';
  String _seatrow = '';
  String _seatnum = '';
  String _pklocation = '';
  String _price = '';
  String _trainnum = '';
  String _classes = '';
  late IOWebSocketChannel _channel;
  late LatLng currentLocation;
  Marker? vehicleMarker;
  late Marker destinationMarker;
  late GoogleMapController mapController;
  final String trainIcon = 'assets/images/trainicon.png';
  late SharedPreferences _prefs;
  LatLngBounds? bounds;
  static const LatLng initialPosition =
      LatLng(6.93371011831413, 79.85000688281856);

  double? lati;
  double? longi;
  late LatLng desti;
  final List<String> trainNumbers = [
    '001',
    '002',
    '003',
  ];

  @override
  void initState() {
    super.initState();
    _destinationmarkerInitialize();
    _initializeSharedPreferences();
  }

  @override
  void dispose() {
    _channel.sink.close();
    mapController.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _fetchDestination();
    _fetchUserId();
    _vehicalmarkerInitailize();
  }

  Future<void> _fetchDestination() async {
    final String destination = _prefs.getString('selectedDestination') ?? '';
    setState(() {
      _destination = destination;
    });
    _fetchdestinationDetails();
  }

  Future<void> _fetchUserId() async {
    final String userId = _prefs.getString('userId') ?? '';
    Random random = Random();
    int randomIndex = random.nextInt(trainNumbers.length);
    String trainrandom = trainNumbers[randomIndex];
    setState(() {
      _userId = userId;
      _trainnum = trainrandom;
    });
    _fetchuserDetails();
    _connectWebSocket();
  }

  Future<void> _fetchuserDetails() async {
    final response = await http.get(Uri.parse(
        'https://trackwise.pasiyaprogramming.live/viewtrip?userid=$_userId'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String reference = data['reference'] ?? '';
      final String classes = data['class'] ?? '';
      final String seatrow = data['seatrow'] ?? '';
      final String seatnum = data['seatnum'] ?? '';
      final String pklocation = data['pklocation'] ?? '';
      final String price = data['price'] ?? '';
      setState(() {
        _reference = reference;
        _classes = classes;
        _seatrow = seatrow;
        _seatnum = seatnum;
        _pklocation = pklocation;
        _price = price;
      });
    } else {
      print('Error get data: ${response.statusCode}');
    }
  }

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect(
        'wss://socket2.pasiyaprogramming.live',
        headers: {'clientid': 'col01'});
    _channel.stream.listen((data) {
      final Map<String, dynamic> locationdata = jsonDecode(data);
      final double latitude = locationdata['latitude'];
      final double longitude = locationdata['longitude'];
      setState(() {
        lati = latitude;
        longi = longitude;
      });
      _updateVehiclePosition();
    }, onError: (error) {
      print('WebSocket Error: $error');
    }, onDone: () {
      print('WebSocket Connection Closed');
    });
  }

  Future<void> _fetchdestinationDetails() async {
    final response = await http.get(Uri.parse(
        'https://trackwise.pasiyaprogramming.live/getlocationslatlang?destination=$_destination'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final double lat = double.parse(data['latitude']);
      final double lang = double.parse(data['longtitude']);
      setState(() {
        latitude = lat;
        longtitude = lang;
        desti = LatLng(lat, lang);
        destinationMarker = destinationMarker.copyWith(
            positionParam: LatLng(latitude, longtitude));
      });

      //  _simulateReceiveDestination();
    } else {
      print('Error get data: ${response.statusCode}');
    }
  }

  Future<void> _vehicalmarkerInitailize() async {
    final BitmapDescriptor trainIcon = await _loadTrainIcon();
    vehicleMarker = Marker(
      markerId: const MarkerId('vehicle'),
      position: initialPosition,
      icon: trainIcon,
      anchor: const Offset(0.5, 0.5),
    );
  }

  void _destinationmarkerInitialize() {
    destinationMarker = const Marker(
        markerId: MarkerId('destination'),
        position: initialPosition,
        icon: BitmapDescriptor.defaultMarker);
  }

  void _updateVehiclePosition() async {
    try {
      final double? lat = lati;
      final double? lng = longi;
      currentLocation = LatLng(lat!, lng!);
      print("Current location $currentLocation");
      print("Destination: $desti");
      vehicleMarker = vehicleMarker!.copyWith(positionParam: LatLng(lat, lng));
      updateBounds(currentLocation, desti);
    } catch (e) {
      print('Error updating vehicle position: $e');
    }
  }

  void updateBounds(LatLng currentlocation, LatLng destination) {
    if (currentlocation.latitude != null &&
        currentLocation.longitude != null &&
        destination.latitude != null &&
        destination.longitude != null) {
      setState(() {
        double minLat = min(currentlocation.latitude, destination.latitude);
        double maxLat = max(currentlocation.latitude, destination.latitude);
        double minLng = min(currentlocation.longitude, destination.longitude);
        double maxLng = max(currentlocation.longitude, destination.longitude);
        bounds = LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        );
        LatLng center = LatLng(
            (currentlocation.latitude + destination.latitude) / 2,
            (currentLocation.longitude + destination.longitude) / 2);

        mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds!, 100));
        mapController.animateCamera(CameraUpdate.newLatLngZoom(center, 13));
        if (currentLocation == destination) {
          _showdestinationSuccessPopup();
          Provider.of<AuthProvider>(context, listen: false).endtrip(context);
        }
      });
    }
  }

  void _showdestinationSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Timer(const Duration(seconds: 3), () {
          Navigator.of(context).pop();
          Navigator.pushReplacementNamed(context, '/location');
        });
        return const AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: Text(
            'Your Train',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Colors.green,
                size: 35,
              ),
              SizedBox(
                height: 10,
              ),
              Text('Your train is arrived to the station.'),
            ],
          ),
        );
      },
    );
  }

  Future<BitmapDescriptor> _loadTrainIcon() async {
    final ImageConfiguration config = createLocalImageConfiguration(context);
    final BitmapDescriptor bitmapDescriptor =
        await BitmapDescriptor.fromAssetImage(config, trainIcon);
    return bitmapDescriptor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Waiting for the train",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: GoogleMap(
              mapType: MapType.normal,
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                  const CameraPosition(target: initialPosition, zoom: 11.00),
              markers: {vehicleMarker!, destinationMarker},
              zoomGesturesEnabled: true,
            ),
          ),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Trip Details",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: Container(
                    decoration: const BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(
                            width: 1,
                            color: Color.fromARGB(255, 131, 131, 131)))),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Table(
                          children: [
                            TableRow(children: <Widget>[
                              const Center(
                                child: Text(
                                  "Reference No",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Center(
                                child: Text(
                                  _reference,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ]),
                            TableRow(children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text(
                                  "Train No",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Center(
                                child: Text(
                                  _trainnum,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ]),
                            TableRow(children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text(
                                  "From",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Center(
                                child: Text(
                                  _pklocation,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ]),
                            TableRow(children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text(
                                  "To",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Center(
                                child: Text(
                                  _destination,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ]),
                            TableRow(children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text(
                                  "Class",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Center(
                                child: Text(
                                  _classes,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ]),
                            TableRow(children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text(
                                  "Row No",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Center(
                                child: Text(
                                  _seatrow,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ]),
                            TableRow(children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text(
                                  "Seat No",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Center(
                                child: Text(
                                  _seatnum,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              )
                            ]),
                            TableRow(children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(left: 30),
                                child: Text(
                                  "Price",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Center(
                                child: Text(
                                  _price,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ]),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
