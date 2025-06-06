import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomProfileImage extends StatelessWidget {
  final String? url;
  final double? radius;
  final File? localImage;

  const CustomProfileImage({super.key, this.url, this.localImage, this.radius});

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (localImage != null) {
      imageProvider = FileImage(localImage!);
    } else if (url != null && url!.isNotEmpty) {
      imageProvider = CachedNetworkImageProvider(url!);
    }

    return CircleAvatar(
      radius: radius ?? 30,
      backgroundColor: Colors.white,
      backgroundImage: imageProvider,
      child:
          (imageProvider == null)
              ? Icon(Icons.person, size: 30, color: Colors.green.shade700)
              : null,
    );
  }
}
