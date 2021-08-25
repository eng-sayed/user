import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tip_trip/constant.dart';
import 'package:tip_trip/screens/trips.dart';

class TripDetails extends StatefulWidget {
  static const id = 'TripDetails';
  DocumentSnapshot detailTrip;
  TripDetails({this.detailTrip});

  @override
  _TripDetailsState createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  List _listOfImages = [];

  images() async {
    _listOfImages = [];
    for (int i = 0;
        i < widget.detailTrip.data()['image trip data'].length;
        i++) {
      _listOfImages.add(widget.detailTrip.data()['image trip data'][i]);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    images();
  }

  delete() async {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content:
                Text("Are you sure?", style: TextStyle(color: Colors.black)),
            actions: [
              TextButton(
                  onPressed: () async {
                    await firebase_storage.FirebaseStorage.instance
                        .refFromURL(widget.detailTrip.data()['image trip'])
                        .delete();
                    for (int j = 0;
                        j < widget.detailTrip.data()['image trip data'].length;
                        j++) {
                      await firebase_storage.FirebaseStorage.instance
                          .refFromURL(
                              widget.detailTrip.data()['image trip data'][j])
                          .delete();
                    }

                    await tripsCollection
                        .doc(widget.detailTrip.data()['name'])
                        .delete()
                        .then((value) {
                      Navigator.pushReplacementNamed(context, Trips.id);
                    });
                  },
                  child: Text('Delete'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.detailTrip.data()['name']),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                delete();
              },
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ))
        ],
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
                child: CarouselSlider(
              options: CarouselOptions(
                // height: 300.0,
                autoPlay: true,
              ),
              items: _listOfImages.map((item) {
                return Container(
                  width: double.infinity,
                  child: Center(
                      child: Container(
                    child: Image.network(
                      item,
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * .97,
                      height: 200,
                    ),
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(25)),
                  )),
                );
              }).toList(),
            )),
          ),
        ],
      ),
    );
  }
}
