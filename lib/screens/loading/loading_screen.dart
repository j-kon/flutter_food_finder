import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:food_finder/models/models.dart';
import 'package:food_finder/services/place_service.dart';
import 'package:geolocator/geolocator.dart';

import '../../constants.dart';

class LoadingScreen extends StatefulWidget {
  static const String id = 'loading_screen';

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  PlaceService _placeService;
  Position _currentPosition;
  String _currentAddress;

  @override
  void initState() {
    super.initState();
    _placeService = PlaceService();
    _getCurrentLocation();
  }

  Future<dynamic> _getCurrentLocation() async {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        if (position != null) {
          _currentPosition = position;
          print(
              'current location: ${_currentPosition.latitude}, ${_currentPosition.longitude}');
        }
      });

      // _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: FutureBuilder(
              future: _placeService.getPlaces(
                  lat: _currentPosition.latitude.toString(),
                  long: _currentPosition.longitude.toString()),
              builder: (context, snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? PlaceList(result: snapshot.data)
                    : Container(child: Text("No Data"));
              }),
        ),
      ),
    );
  }
}

class PlaceList extends StatefulWidget {
  List<Result> result;

  PlaceList({Key key, this.result}) : super(key: key);

  @override
  _PlaceListState createState() => _PlaceListState();
}

class _PlaceListState extends State<PlaceList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.result.length,
        itemBuilder: (BuildContext context, int index) {
          final result = widget.result[index];
          return PlaceCard(name: result.name, rating: result.rating);
        });
  }
}

class PlaceCard extends StatelessWidget {
  String name;
  String icon;
  String rating;
  bool openNow;

  PlaceCard({Key key, this.name, this.icon, this.rating, this.openNow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
//          Image.network(icon),
          Column(
            children: [Text(name), Text(rating)],
          )
        ],
      ),
    );
  }
}
