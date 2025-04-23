import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class TrackingController extends GetxController {
  var elapsedTime = '00:00:00'.obs; // Timer display
  var distanceCovered = 0.0.obs; // Distance in meters
  var isTracking = false.obs; // Tracking state

  Timer? _timer;
  int _seconds = 0;
  Position? _previousPosition;
  StreamSubscription<Position>? _positionStream;

  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Location permissions are permanently denied.');
      return;
    }
  }

  void startTracking() async {
    if (!isTracking.value) {
      isTracking.value = true;
      _seconds = 0;
      distanceCovered.value = 0.0;
      _previousPosition = null;

      // Start timer
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        _seconds++;
        int hours = _seconds ~/ 3600;
        int minutes = (_seconds % 3600) ~/ 60;
        int seconds = _seconds % 60;
        elapsedTime.value =
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      });

      // Start GPS tracking
      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5, // Update every 5 meters
        ),
      ).listen((Position position) {
        if (_previousPosition != null) {
          double distance = Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          distanceCovered.value += distance;
        }
        _previousPosition = position;
      });
    }
  }

  void stopTracking() {
    if (isTracking.value) {
      isTracking.value = false;
      _timer?.cancel();
      _positionStream?.cancel();
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    _positionStream?.cancel();
    super.onClose();
  }
}
