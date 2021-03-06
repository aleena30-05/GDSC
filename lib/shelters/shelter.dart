import 'package:flutter/material.dart';
import 'package:helloworld/constants.dart';
import 'package:helloworld/shelters/shelterprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class shelterclass extends StatefulWidget {
  Map userloc;
  shelterclass({Key key, this.userloc}) : super(key: key);

  @override
  _shelterclassState createState() => _shelterclassState();
}

class _shelterclassState extends State<shelterclass> {
  final db = FirebaseFirestore.instance;
  bool isloading = false;
  String search = "";
  TextEditingController searchcont = TextEditingController();
  BitmapDescriptor mapmarker;
  Set<Marker> _markers = {};

  addUserloc() async {
    _markers.add(Marker(
        markerId: MarkerId('userloc'),
        position:
            LatLng(widget.userloc["latitude"], widget.userloc["longitude"]),
        infoWindow: InfoWindow(title: "your Location")));
  }

  void loadProgress(check) {
    setState(() {
      isloading = check;
    });
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  void _onMapCreated() {
    setState(
      () {
        db.collection('shelters').get().then((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            for (int i = 0; i < snapshot.docs.length; i++) {
              Map<dynamic, dynamic> map = snapshot.docs[i].data();
              var id = snapshot.docs[i].id;
              _markers.add(Marker(
                  icon: mapmarker,
                  markerId: MarkerId(id),
                  position: LatLng(map['latitude'], map['longitude']),
                  infoWindow: InfoWindow(title: map["name"])));
            }
            loadProgress(true);
          }
        });
      },
    );
  }

  void markericon() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/paw.png', 100);
    mapmarker = await BitmapDescriptor.fromBytes(markerIcon);
  }

  @override
  void initState() {
    super.initState();
    markericon();
    addUserloc();
    _onMapCreated();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Shelters",
            style: TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(height: 20),
          Container(
            width: 352,
            height: 50,
            margin: EdgeInsets.only(top: 10, left: 20, right: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: TextField(
              keyboardType: TextInputType.text,
              onSubmitted: (String a) {
                setState(() {
                  search = a;
                });
              },
              controller: searchcont,
              decoration: InputDecoration(
                suffixIcon: Padding(
                  padding: EdgeInsetsDirectional.only(end: 12),
                  child: Icon(Icons.search, color: Colors.black, size: 25),
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Colors.black, width: 5)),
                hintText: "Search",
                hintStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            "Nearby shelters",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            width: double.infinity,
            height: 300,
            margin: EdgeInsets.only(left: 20, right: 20),
            decoration: BoxDecoration(
                color: constantclass.backgroundcolor,
                borderRadius: BorderRadius.circular(15)),
            child: this.isloading
                ? GoogleMap(
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
                      new Factory<OneSequenceGestureRecognizer>(
                        () => new EagerGestureRecognizer(),
                      ),
                    ].toSet(),
                    markers: _markers,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(widget.userloc['latitude'],
                            widget.userloc['longitude']),
                        zoom: 13),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Visibility(
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          visible: true,
                          child: Container(
                              margin: EdgeInsets.only(top: 50, bottom: 30),
                              child: CircularProgressIndicator(
                                color: Colors.blue,
                                strokeWidth: 5,
                              ))),
                    ],
                  ),
          ),
          SizedBox(
            height: 20,
          ),
          (search.trim() != "")
              ? StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection('shelters')
                      .where('name',
                          isGreaterThanOrEqualTo: searchcont.text,
                          isLessThan: searchcont.text + 'z')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: Text("No data",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500)));
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        children: []..addAll(snapshot.data.docs.map((doc) {
                            return Column(children: [
                              RawMaterialButton(
                                child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: constantclass.backgroundcolor,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    height: 92,
                                    width: double.infinity,
                                    margin:
                                        EdgeInsets.only(left: 30, right: 30),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(
                                            'https://thumbs.dreamstime.com/b/homeless-shelter-real-estate-concept-close-up-child-hands-holding-white-paper-house-heart-green-background-flat-lay-copy-164579567.jpg'),
                                      ),
                                      title: Text(
                                        doc.get('name') ?? '',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Text(
                                        doc.get('location') ?? '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    )),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              shelterprofileclass(
                                                  doc: doc,
                                                  userloc: widget.userloc)));
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ]);
                          })),
                      );
                    }
                  })
              : StreamBuilder<QuerySnapshot>(
                  stream: db.collection('shelters').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                          child: Text("No data",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500)));
                    } else {
                      return ListView(
                        shrinkWrap: true,
                        physics: ClampingScrollPhysics(),
                        children: []..addAll(snapshot.data.docs.map((doc) {
                            return Column(children: [
                              RawMaterialButton(
                                child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: constantclass.backgroundcolor,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    height: 92,
                                    width: double.infinity,
                                    margin:
                                        EdgeInsets.only(left: 30, right: 30),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        radius: 40,
                                        backgroundImage: NetworkImage(
                                            'https://thumbs.dreamstime.com/b/homeless-shelter-real-estate-concept-close-up-child-hands-holding-white-paper-house-heart-green-background-flat-lay-copy-164579567.jpg'),
                                      ),
                                      title: Text(
                                        doc.get('name') ?? '',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      subtitle: Text(
                                        doc.get('location') ?? '',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis),
                                      ),
                                    )),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              shelterprofileclass(
                                                  doc: doc,
                                                  userloc: widget.userloc)));
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ]);
                          })),
                      );
                    }
                  }),
        ])));
  }
}
