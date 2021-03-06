import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helloworld/adoptions/adoptpet.dart';
import 'package:helloworld/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class resultsclass extends StatefulWidget {
  @override
  _resultsclassState createState() => _resultsclassState();
}

class _resultsclassState extends State<resultsclass> {
  final db = FirebaseFirestore.instance;
  String search = " ";
  final storage = firebase_storage.FirebaseStorage.instance;
  TextEditingController searchcont = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Adopt Animals",
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
            "Adopt pets",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            height: 20,
          ),
          (search.trim() != "")
              ? StreamBuilder<QuerySnapshot>(
                  stream: db
                      .collection('adopt')
                      .where('type',
                          isGreaterThanOrEqualTo: search,
                          isLessThan: search + 'z')
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
                            return Column(
                              children: [
                                RawMaterialButton(
                                  child: Container(
                                      width: 352,
                                      height: 120,
                                      margin: EdgeInsets.only(
                                          top: 10, left: 20, right: 20),
                                      decoration: BoxDecoration(
                                        color: constantclass.backgroundcolor,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Colors.pink,
                                            backgroundImage: NetworkImage(doc
                                                    .data()
                                                    .toString()
                                                    .contains('url')
                                                ? doc.get('url')
                                                : 'https://dm6g3jbka53hp.cloudfront.net/static-images/adopt-me-pet-02032021.jpg'),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                width: 200,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  doc.get('type') ?? "",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  width: 200,
                                                  child: Text(
                                                    doc.get('location'),
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 17,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                  child: Container(
                                                width: 200,
                                                child: Text(
                                                  doc.get('description'),
                                                  softWrap: false,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              )),
                                              Text(
                                                doc.get('shelter-attention')
                                                    ? "Shelter Attention Required"
                                                    : "",
                                                softWrap: false,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                petItclass(doc: doc)));
                                  },
                                ),
                              ],
                            );
                          })),
                      );
                    }
                  })
              : StreamBuilder<QuerySnapshot>(
                  stream: db.collection('adopt').snapshots(),
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
                            return Column(
                              children: [
                                RawMaterialButton(
                                  child: Container(
                                      width: 352,
                                      height: 120,
                                      margin: EdgeInsets.only(
                                          top: 10, left: 20, right: 20),
                                      decoration: BoxDecoration(
                                        color: constantclass.backgroundcolor,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          CircleAvatar(
                                            radius: 50,
                                            backgroundColor: Colors.pink,
                                            backgroundImage: NetworkImage(doc
                                                    .data()
                                                    .toString()
                                                    .contains('url')
                                                ? doc.get('url')
                                                : 'https://dm6g3jbka53hp.cloudfront.net/static-images/adopt-me-pet-02032021.jpg'),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                width: 200,
                                                alignment: Alignment.center,
                                                child: Text(
                                                  doc.get('type') ?? "",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  width: 200,
                                                  child: Text(
                                                    doc.get('location'),
                                                    style: TextStyle(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 17,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                  child: Container(
                                                width: 200,
                                                child: Text(
                                                  doc.get('description'),
                                                  softWrap: false,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 16,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              )),
                                              Text(
                                                doc.get('shelter-attention')
                                                    ? "Shelter Attention Required"
                                                    : "",
                                                softWrap: false,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                petItclass(doc: doc)));
                                  },
                                ),
                              ],
                            );
                          })),
                      );
                    }
                  }),
        ])));
  }
}
