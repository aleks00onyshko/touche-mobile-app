import 'package:flutter/material.dart';

class BookButton extends StatelessWidget {
  final bool booked;
  final bool disabled;
  final Function onBookTapped;

  const BookButton({super.key, required this.booked, required this.onBookTapped, required this.disabled});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => disabled ? () => {} : onBookTapped(),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: disabled
            ? Colors.grey[900]
            : booked
                ? Colors.red[700]
                : Colors.orange[700],
      ),
      child: Text(_getButtonText(booked, disabled), style: const TextStyle(color: Colors.white)),
    );
  }

  String _getButtonText(bool booked, bool disabled) {
    return disabled
        ? 'Someone else booked a slot, sorry!'
        : booked
            ? 'Cancel booking'
            : 'Book lesson';
  }
}
