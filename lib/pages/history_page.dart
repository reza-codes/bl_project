import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/fall_detect_model.dart';
import '../repositories/firestore_repository.dart';
import 'fall_details_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with AutomaticKeepAliveClientMixin<HistoryPage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("History Page"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirestoreRepository.readFallDectected(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            List<FallDetectModel> fallsDetect = snapshot.data;
            if (kDebugMode) {
              print(fallsDetect.length);
            }

            if (fallsDetect.isEmpty) {
              return const Center(
                heightFactor: 5,
                child: Text(
                  "History is empty",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            return ListView.separated(
                separatorBuilder: (context, index) => const Divider(
                      indent: 15,
                      endIndent: 15,
                      thickness: 1.3,
                    ),
                itemBuilder: (context, index) {
                  double latitude = fallsDetect[index].latitude;
                  double longitude = fallsDetect[index].longitude;
                  DateTime dataTime = fallsDetect[index].dataTime;

                  return ListTile(
                    leading: const Icon(
                      Icons.warning_rounded,
                      color: Colors.amber,
                      size: 30,
                    ),
                    title:
                        Text("Fall detected at: " "LatLng(${latitude.toString()}, ${longitude.toString()})"),
                    subtitle: Text(dataTime.toString()),
                    trailing: Text((index + 1).toString()),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FallDetailsPage(
                                    latitude: latitude,
                                    longitude: longitude,
                                    dataTime: dataTime,
                                  )));
                    },
                  );
                },
                itemCount: fallsDetect.length);
          }

          return const Center(
            heightFactor: 5,
            child: Text(
              "History is empty",
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
