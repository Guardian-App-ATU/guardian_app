import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

            var sessionData = snapshot.data!.data() as dynamic;
            List<dynamic> locationUpdates = sessionData["locations"] ?? [];

            List<LatLng> asLatLng = <LatLng>[];

            for (var element in locationUpdates) {
              asLatLng.add(LatLng(element.latitude, element.longitude));
            }

            Timestamp? lastUpdateDate = sessionData["lastUpdate"];

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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Added People",
                        style: TextStyle(fontSize: 14),
                      ),
                      if (sessionData["userId"] ==
                          FirebaseAuth.instance.currentUser!.uid)
                        IconButton(
                            alignment: Alignment.centerLeft,
                            tooltip: "Add an user",
                            iconSize: 24,
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (ctx) {
                                    return FutureBuilder<DocumentSnapshot>(
                                      future: FirebaseFirestore.instance
                                          .doc(
                                              "users/${FirebaseAuth.instance.currentUser!.uid}")
                                          .get(),
                                      builder: (dialogContext, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.hasError) {
                                          return const Text(
                                              "Sorry, an error has occurred");
                                        }

                                        dynamic data = snapshot.data!.data();
                                        // ignore: prefer_const_constructors
                                        return FriendsPopup(
                                            data: data,
                                            sessionId: widget.sessionId);
                                      },
                                    );
                                  });
                            },
                            icon: const Icon(Icons.add))
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    direction: Axis.horizontal,
                    spacing: 6,
                    children: [
                      for (var id in <String>[...sessionData["users"]])
                        FutureBuilder<DocumentSnapshot>(
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

                            return PopupMenuButton<bool>(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                    enabled: false,
                                    child: Text(data["displayName"])),
                                const PopupMenuDivider(),
                                const PopupMenuItem(
                                    child: Text("Remove"), value: true)
                              ],
                              onSelected: (value) async {
                                if (value == false) {
                                  return;
                                }

                                var dialContext;
                                showDialog(
                                    context: context,
                                    builder: (dialogContext) {
                                      dialContext = dialogContext;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    });

                                FirebaseFirestore.instance
                                    .doc("sessions/${widget.sessionId}")
                                    .update({
                                  "users": FieldValue.arrayRemove([id])
                                }).whenComplete(
                                        () => Navigator.of(dialContext).pop());
                              },
                              child: CircleAvatar(
                                radius: 14,
                                child: url != null
                                    ? Image.network(url)
                                    : const Icon(Icons.person),
                              ),
                            );
                          },
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

class FriendsPopup extends StatelessWidget {
  const FriendsPopup({
    Key? key,
    required this.data,
    required this.sessionId,
  }) : super(key: key);

  final data;
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Add Your friends"),
      contentPadding: const EdgeInsets.all(8),
      children: [
        Container(
          height: 200,
          width: double.maxFinite,
          child: ListView.builder(
            itemBuilder: (context, index) {
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .doc("users/${data["friends"][index]}")
                    .get(),
                builder: (futureContext, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  dynamic userData = snapshot.data!.data();

                  return Card(
                    child: snapshot.connectionState == ConnectionState.waiting
                        ? const Center(child: CircularProgressIndicator())
                        : ListTile(
                            title: Text(userData["displayName"]),
                            onTap: () async {
                              await FirebaseFirestore.instance
                                  .doc("sessions/$sessionId")
                                  .update({
                                "users": FieldValue.arrayUnion(
                                    [snapshot.data!.id])
                              });

                              Navigator.of(futureContext).pop();
                            },
                          ),
                  );
                },
              );
            },
            itemCount: data["friends"].length,
            shrinkWrap: true,
          ),
        ),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"))
      ],
    );
  }
}
