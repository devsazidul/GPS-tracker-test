import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:run_app/run/controller/run_controller.dart'
    show TrackingController;

class TrackingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TrackingController controller = Get.put(TrackingController());

    return Scaffold(
      appBar: AppBar(title: Text('GPS Tracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Text(
                'Time: ${controller.elapsedTime.value}',
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(height: 20),
            Obx(
              () => Text(
                'Distance: ${controller.distanceCovered.value.toStringAsFixed(2)} m',
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(height: 40),
            Obx(
              () => ElevatedButton(
                onPressed: () {
                  if (controller.isTracking.value) {
                    controller.stopTracking();
                  } else {
                    controller.startTracking();
                  }
                },
                child: Text(controller.isTracking.value ? 'Stop' : 'Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
