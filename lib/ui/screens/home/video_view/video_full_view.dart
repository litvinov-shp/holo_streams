import 'package:cached_network_image/cached_network_image.dart';
import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ContextExtensionss;
import 'package:holo_streams/controllers/time.dart';
import 'package:holo_streams/model/holo_stream.dart';
import 'package:holo_streams/ui/screens/home/video_view/holo_avatar.dart';
import 'package:holo_streams/ui/screens/home/video_view/video_subtitle.dart';
import 'package:holo_streams/ui/screens/video/video_screen.dart';
import 'package:holo_streams/ui/widgets/icon_span.dart';
import 'package:holo_streams/ui/widgets/list_tile/outlined_list_tile.dart';
import 'package:holo_streams/utils/context_navigator.dart';
import 'package:holo_streams/utils/effective_channel_name.dart';
import 'package:holo_streams/utils/holo_url_launcher.dart';
import 'package:holo_streams/utils/quick_theme.dart';
import 'package:holo_streams/utils/start_date.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

class VideoFullView extends StatelessWidget {
  const VideoFullView({
    super.key,
    required this.stream,
    required this.videoIndex,
    this.isClickable = true,
  });

  final HoloStream stream;

  final int videoIndex;

  final bool isClickable;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TimeController>(
      builder: (controller) {
        final video = stream.videos[videoIndex];

        final name = video.channel?.effectiveName ?? 'Unknown';
        final dateText = DateFormat.jm().add_MMMd().format(video.localStartDate);

        final listTileTheme = Theme.of(context).listTileTheme;
        final subtitleStyle = ListTileTheme.of(context).subtitleTextStyle ??
            context.theme.textTheme.bodySmall
                ?.copyWith(color: context.colorScheme.onSurfaceVariant) ??
            TextStyle(color: context.colorScheme.onSurfaceVariant);

        final nowFloored = controller.now.floorTo(TimeUnit.second);
        final localDateFloored = video.localStartDate.floorTo(TimeUnit.second);
        final difference = nowFloored.difference(localDateFloored);
        final differenceAbs = difference.abs();

        final isActive = video.status == VideoStatus.live || !difference.isNegative;

        final hours = '${differenceAbs.inHours}'.padLeft(2, '0');
        final minutes = '${differenceAbs.inMinutes % 60}'.padLeft(2, '0');
        final seconds = '${differenceAbs.inSeconds % 60}'.padLeft(2, '0');
        final timeText = '$hours:$minutes:$seconds';

        Widget videoView = ListTile(
          contentPadding: EdgeInsets.only(left: 16.0, right: isClickable ? 0.0 : 16.0),
          titleTextStyle: listTileTheme.titleTextStyle,
          subtitleTextStyle: listTileTheme.subtitleTextStyle,
          leading: CachedNetworkImage(
            imageUrl: video.channel?.photo ?? '',
            imageBuilder: (context, imageProvider) => HoloAvatar(image: imageProvider),
            errorWidget: (context, url, error) => const HoloAvatar(),
            placeholder: (context, url) => const HoloAvatar(),
          ),
          title: Padding(
            padding: isClickable ? const EdgeInsets.only(right: 8.0) : EdgeInsets.zero,
            child: Text(
              video.title,
              maxLines: isClickable ? 2 : 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: VideoSubtitle(
                  name: TextSpan(text: name, style: subtitleStyle),
                  time: TextSpan(text: dateText, style: subtitleStyle),
                  timeDifference: TextSpan(
                    style: subtitleStyle,
                    children: [
                      IconSpan(
                        isActive ? Symbols.radio_button_checked : Symbols.timelapse,
                        color: isActive ? const Color(0xFFFF0000) : null,
                        style: subtitleStyle,
                      ),
                      TextSpan(text: ' $timeText'),
                    ],
                  ),
                  liveViewers: video.liveViewers == null || video.liveViewers == 0
                      ? null
                      : TextSpan(
                          style: subtitleStyle,
                          children: [
                            IconSpan(
                              Symbols.visibility,
                              fill: 1.0,
                              style: subtitleStyle,
                            ),
                            TextSpan(text: ' ${video.liveViewers}'),
                          ],
                        ),
                ),
              ),
              if (isClickable)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: TextButton(
                    onPressed: () => context
                        .push((context) => VideoScreen(stream: stream, videoIndex: videoIndex)),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      minimumSize: MaterialStatePropertyAll(Size.zero),
                      padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0)),
                    ),
                    child: Text('More', style: TextStyle(fontSize: subtitleStyle.fontSize)),
                  ),
                )
            ],
          ),
        );

        if (isClickable) {
          videoView = Tooltip(
            message: video.title,
            child: InkWell(
              onTap: () => watchVideo(video.id),
              borderRadius: BorderRadius.circular(16.0),
              child: OutlinedListTile(
                color: isActive ? const Color(0xFFFF0000) : null,
                child: videoView,
              ),
            ),
          );
        }

        return videoView;
      },
    );
  }
}
