import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:touche_app/core/DI/root-locator.dart';

class BookButton extends StatelessWidget {
  final FirebaseFirestore firestore = locator.get<FirebaseFirestore>();

  final bool booked;
  final Function onBookTapped;

  BookButton({super.key, required this.booked, required this.onBookTapped});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onBookTapped(),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: booked ? Colors.red[700] : Colors.orange[700],
      ),
      child: Text(_getButtonText(booked), style: const TextStyle(color: Colors.white)),
    );
  }

  String _getButtonText(bool booked) {
    return booked ? 'Cancel booking' : 'Book lesson';
  }
}
