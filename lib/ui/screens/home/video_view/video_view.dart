import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:holo_streams/ui/screens/home/video_view/holo_avatar.dart';
import 'package:holo_streams/ui/widgets/list_tile/outlined_list_tile.dart';
import 'package:holo_streams/utils/effective_channel_name.dart';
import 'package:holo_streams/utils/holo_url_launcher.dart';

class VideoView extends StatelessWidget {
  const VideoView({
    super.key,
    required this.video,
  });

  final VideoFull video;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return InkWell(
        onTap: () => watchVideo(video.id),
        borderRadius: BorderRadius.circular(16.0),
        child: OutlinedListTile(
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: video.channel?.photo ?? '',
              imageBuilder: (context, imageProvider) => HoloAvatar(image: imageProvider),
              errorWidget: (context, url, error) => const HoloAvatar(),
              placeholder: (context, url) => const HoloAvatar(),
            ),
            title: Text(video.title),
            subtitle: Text(video.channel?.effectiveName ?? 'Unknown'),
          ),
        ),
      );
    });
  }
}
