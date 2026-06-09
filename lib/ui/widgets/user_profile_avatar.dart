import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Helpers for profile photos stored as http(s) URLs in [UserModel.profileUrl].
/// When empty or not remote, UI shows [Icons.person] instead of a default URL.
class UserProfileImage {
  UserProfileImage._();

  static bool hasRemote(String url) {
    if (url.isEmpty) return false;
    if (!(url.startsWith('http://') || url.startsWith('https://'))) {
      return false;
    }
    // Legacy data: ui-avatars often returns responses some Android decoders reject.
    final lower = url.toLowerCase();
    if (lower.contains('ui-avatars.com')) return false;
    return true;
  }
}

/// Circular avatar: network image when [imageUrl] is remote, otherwise [Icons.person].
class UserProfileAvatar extends StatelessWidget {
  const UserProfileAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.iconSize,
    this.backgroundColor,
    this.iconColor,
  });

  final String imageUrl;
  final double radius;
  final double? iconSize;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;
    if (!UserProfileImage.hasRemote(imageUrl)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bg,
        child: Icon(
          Icons.person,
          size: iconSize ?? radius * 1.25,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      backgroundImage: CachedNetworkImageProvider(imageUrl),
    );
  }
}
