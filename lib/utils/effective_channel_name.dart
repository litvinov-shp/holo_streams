import 'package:dart_holodex_api/dart_holodex_api.dart';
import 'package:holo_streams/controllers/settings.dart';

extension EffectiveChannelMinName on ChannelMin {
  String get effectiveName =>
      (Settings.to.preferEnglishNames
          ? ((englishName ?? '').isEmpty)
              ? name
              : englishName
          : (name.isEmpty)
              ? englishName
              : name) ??
      'Unknown';
}

extension EffectiveChannelName on Channel {
  String get effectiveName =>
      (Settings.to.preferEnglishNames
          ? ((englishName ?? '').isEmpty)
              ? name
              : englishName
          : (name.isEmpty)
              ? englishName
              : name) ??
      'Unknown';
}
