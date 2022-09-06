import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:hmssdk_flutter_example/common/util/app_color.dart';
import 'package:hmssdk_flutter_example/enum/meeting_mode.dart';
import 'package:hmssdk_flutter_example/hls-streaming/util/hls_subtitle_text.dart';
import 'package:hmssdk_flutter_example/meeting/meeting_store.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';

class MeetingModeSheet extends StatefulWidget {
  MeetingModeSheet({
    Key? key,
  }) : super(key: key);
  @override
  State<MeetingModeSheet> createState() => _MeetingModeSheetState();
}

class _MeetingModeSheetState extends State<MeetingModeSheet> {
  GlobalKey? dropdownKey;

  @override
  void initState() {
    super.initState();
    dropdownKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    MeetingStore _meetingStore = context.read<MeetingStore>();
    return FractionallySizedBox(
      heightFactor: 0.5,
      child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
          child: Expanded(
            child: ListView(
              children: [
                ListTile(
                  horizontalTitleGap: 2,
                  onTap: () async {
                    _meetingStore.setActiveSpeakerMode();
                    Navigator.pop(context);
                  },
                  contentPadding: EdgeInsets.zero,
                  leading: SvgPicture.asset(
                    "assets/icons/participants.svg",
                    semanticsLabel: "fl_active_speaker_mode",
                    fit: BoxFit.scaleDown,
                  ),
                  title: Text(
                    "Active Speaker Mode",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: defaultColor,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  horizontalTitleGap: 2,
                  onTap: () async {
                    if (_meetingStore.meetingMode != MeetingMode.Audio) {
                      _meetingStore.setMode(MeetingMode.Audio);
                    } else {
                      _meetingStore.setPlayBackAllowed(true);
                      _meetingStore.setMode(MeetingMode.Video);
                    }
                    Navigator.pop(context);

                  },
                  contentPadding: EdgeInsets.zero,
                  leading: SvgPicture.asset(
                    _meetingStore.meetingMode == MeetingMode.Audio
                        ? 'assets/icons/cam_state_on.svg'
                        : 'assets/icons/mic_state_on.svg',
                    semanticsLabel: "fl_audio_video_view",
                    fit: BoxFit.scaleDown,
                  ),
                  title: Text(
                    _meetingStore.meetingMode == MeetingMode.Audio
                        ? "Video View"
                        : "Audio View",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: defaultColor,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  horizontalTitleGap: 2,
                  onTap: () async {
                    if (_meetingStore.meetingMode != MeetingMode.Hero) {
                      _meetingStore.setMode(MeetingMode.Hero);
                    } else {
                      _meetingStore.setMode(MeetingMode.Video);
                    }
                    Navigator.pop(context);

                  },
                  contentPadding: EdgeInsets.zero,
                  leading: SvgPicture.asset(
                    "assets/icons/participants.svg",
                    semanticsLabel: "fl_hero_mode",
                    fit: BoxFit.scaleDown,
                  ),
                  title: Text(
                    "Hero Mode",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: defaultColor,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                ListTile(
                  horizontalTitleGap: 2,
                  onTap: () async {
                    if (_meetingStore.meetingMode != MeetingMode.Single) {
                      _meetingStore.setMode(MeetingMode.Single);
                    } else {
                      _meetingStore.setMode(MeetingMode.Video);
                    }
                    Navigator.pop(context);

                  },
                  contentPadding: EdgeInsets.zero,
                  leading: SvgPicture.asset(
                    "assets/icons/single_tile.svg",
                    semanticsLabel: "fl_single_mode",
                    fit: BoxFit.scaleDown,
                  ),
                  title: Text(
                    "Single Tile Mode",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        color: defaultColor,
                        letterSpacing: 0.25,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
