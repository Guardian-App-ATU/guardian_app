import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guardian_app_flutter/services/LocationService.dart';
import 'package:provider/provider.dart';

class SessionPage extends StatefulWidget {
  const SessionPage({Key? key, required this.sessionId}) : super(key: key);

  final String sessionId;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  Widget build(BuildContext context) {
    final String sessionId = widget.sessionId;

    final sessionSnapshot =
        FirebaseFirestore.instance.doc("sessions/$sessionId").snapshots();

    final locationService = context.read<LocationService>();
    locationService.requestPermission();

    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<DocumentSnapshot>(
              stream: sessionSnapshot,
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator(size: 18, borderWidth: 1);
                }

                if (snapshot.hasError) {
                  return const Text("An error occured");
                }

                if (!snapshot.hasData) {
                  return const Text("Failed to fetch any data");
                }

                var data = snapshot.data!.data() as dynamic;
                List<dynamic> locationUpdates = data["locations"] ?? [];

                List<LatLng> asLatLng = <LatLng>[];

                for (var element in locationUpdates) {
                  asLatLng.add(LatLng(element.latitude, element.longitude));
                }

                return GoogleMap(
                  initialCameraPosition:
                      const CameraPosition(target: LatLng(53.14, 7.69)),
                  buildingsEnabled: true,
                  myLocationEnabled: true,
                  polylines: <Polyline>{
                    Polyline(
                        polylineId: const PolylineId("path"),
                        width: 5,
                        points: asLatLng,
                        color: Theme.of(context).primaryColor)
                  },
                );
              }),
        ),
      ),
    );
  }
}
