
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guardian_app_flutter/services/LocationService.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
      body: StreamBuilder<DocumentSnapshot>(
          stream: sessionSnapshot,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text("An error occurred"));
            }

            if (!snapshot.hasData) {
              return const Center(child: Text("No data retrieved"));
            }

            var data = snapshot.data!.data() as dynamic;
            List<dynamic> locationUpdates = data["locations"] ?? [];

            List<LatLng> asLatLng = <LatLng>[];

            for (var element in locationUpdates) {
              asLatLng.add(LatLng(element.latitude, element.longitude));
            }

            Timestamp? lastUpdateDate = data["lastUpdate"];

            return SlidingUpPanel(
              minHeight: 72,
              backdropTapClosesPanel: true,
              backdropEnabled: true,
              // collapsed: const Center(child: Icon(Icons.arrow_upward, size: 32)),
              padding: const EdgeInsets.only(
                  left: 12, right: 12, top: 12, bottom: 12),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              panel: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      "Guardian Session",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Center(
                    child: Text(
                      lastUpdateDate != null
                          ? "Last update ${DateFormat.yMEd().format(lastUpdateDate.toDate())}"
                          : "Never Updated",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "Added People",
                        style: TextStyle(fontSize: 14),
                      ),
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {},
                          icon: const Icon(Icons.add))
                    ],
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    spacing: 6,
                    children: [
                      for (var id in <String>[...data["users"]])
                        GestureDetector(
                          onTap: () {},
                          child: FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .doc("users/${id}")
                                .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return CircleAvatar(
                                  radius: 14,
                                  child: snapshot.connectionState ==
                                          ConnectionState.waiting
                                      ? const CircularProgressIndicator()
                                      : const Icon(Icons.error_outline),
                                );
                              }

                              dynamic data = snapshot.data!.data();
                              String? url = data!["avatar"];

                              return CircleAvatar(
                                radius: 14,
                                child: url != null
                                    ? Image.network(url)
                                    : const Icon(Icons.person),
                              );
                            },
                          ),
                        )
                    ],
                  )
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                      zoom: 12.0,
                      target: asLatLng.isEmpty
                          ? const LatLng(53.14, 7.69)
                          : asLatLng[0]),
                  markers: asLatLng.isNotEmpty
                      ? <Marker>{
                          Marker(
                              markerId: const MarkerId("asLatLng"),
                              position: asLatLng[asLatLng.length - 1],
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                  BitmapDescriptor.hueBlue))
                        }
                      : {},
                  polylines: <Polyline>{
                    Polyline(
                        polylineId: const PolylineId("path"),
                        width: 5,
                        points: asLatLng,
                        color: Theme.of(context).primaryColor)
                  },
                ),
              ),
            );
          }),
    );
  }
}
