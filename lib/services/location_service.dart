import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return Geolocator.getCurrentPosition();
  }

  Future<String> getLocationName(Position position) async {
    final latitude = position.latitude;
    final longitude = position.longitude;

    await setLocaleIdentifier("en_US");
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      String location = '${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}';
      print('----- coordinate is latitude : $latitude | longitude : $longitude -----');
      print('----- location name is $location -----');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('location', location);
      await prefs.setDouble('lat', latitude);
      await prefs.setDouble('long', longitude);
      return location;
    } else {
      return '-';
    }
  }
}