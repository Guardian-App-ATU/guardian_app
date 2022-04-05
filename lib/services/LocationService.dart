import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:location/location.dart';

class LocationService {
  Location location = Location();
  final bool autoAskForPermission;

  LocationService({this.autoAskForPermission = false}) {
    startService();
  }

  startService() async {
    log("Location Service starting!");
    await Future.wait([
      location.requestService(),
      location.requestPermission(),
      location.changeSettings(interval: 1000 * 30, distanceFilter: 5),
      location.enableBackgroundMode(enable: true)
    ]).catchError((e) {
      log(e.toString());
    });
    // await location.requestService();
    // await location.requestPermission();
    // await location.changeSettings(interval: 1000 * 30, distanceFilter: 5);
    // await location.enableBackgroundMode(enable: true);

    location.onLocationChanged.listen((locationData) {
      var endpoint = FirebaseFunctions.instance.httpsCallable("updateLocation");

      log("Updating location information!");

      endpoint.call({
        "longitude": locationData.longitude,
        "altitude": locationData.latitude
      });
    });

    log("Location Service started!");
  }

  Future<bool> requestService() async {
    var isEnabled = await location.serviceEnabled();
    if (!isEnabled) {
      isEnabled = await location.requestService();
    }

    return isEnabled;
  }

  Future<LocationData> getLocation() async {
    var serviceStatus = await requestService();
    if (serviceStatus == false) {
      return Future.error("no service granted");
    }

    var gotPermission = await requestPermission();
    if (gotPermission == false) {
      return Future.error("no permission");
    }

    return location.getLocation();
  }

  Future<bool> requestPermission() async {
    var hasPermission = await location.hasPermission();
    if (hasPermission == PermissionStatus.deniedForever) {
      return false;
    }

    if (hasPermission != PermissionStatus.granted ||
        hasPermission != PermissionStatus.grantedLimited) {
      hasPermission = await location.requestPermission();

      return requestPermission();
    }

    return true;
  }
}
