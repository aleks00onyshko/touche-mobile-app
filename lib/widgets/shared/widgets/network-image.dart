import 'package:flutter/material.dart';

class UrlImage extends StatelessWidget {
  final String imageUrl;

  const UrlImage({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color while the image is loading
        borderRadius: BorderRadius.circular(8.0), // Rounded corners (optional)
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0), // Apply the same rounded corners (optional)
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
            return const Center(
              child: Icon(
                Icons.broken_image,
                color: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}
