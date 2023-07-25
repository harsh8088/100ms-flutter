import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hms_room_kit/common/app_color.dart';
import 'package:hms_room_kit/preview/preview_get_participants_text.dart';
import 'package:hms_room_kit/preview/preview_store.dart';
import 'package:hms_room_kit/widgets/common_widgets/subtitle_text.dart';

///This widget renders the UI for whether the HLS is running in the room
///If the HLS is running, it will show the LIVE tag
///Please note that this will only be rendered if the room state is enabled for the role from dashboard
///This also renders the number of participants in the room in a chip
///Please note that this will only be rendered if the room state is enabled for the role with peer-list
///
///Checkout the docs for room-state here: https://www.100ms.live/docs/flutter/v2/how-to-guides/set-up-video-conferencing/preview#get-onpeerupdate-and-onroomupdate-while-in-preview-mode
class PreviewParticipantChip extends StatelessWidget {
  final PreviewStore previewStore;
  final double width;

  const PreviewParticipantChip(
      {super.key, required this.previewStore, required this.width});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ///This will only be rendered if the room state is enabled for the role from dashboard and the HLS is running in the room
        previewStore.isHLSStreamingStarted
            ? Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                      color: alertErrorDefault,
                      borderRadius: BorderRadius.circular(20)),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "packages/hms_room_kit/lib/assets/icons/white_dot.svg",
                          width: 16,
                          height: 16,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4.0, right: 6),
                          child: SubtitleText(
                              text: "LIVE",
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.25,
                              textColor: onSurfaceHighEmphasis),
                        ),
                      ],
                    ),
                  )),
                ),
              )
            : Container(),

        ///This will only be rendered if room state is enabled for the role with peer-list
        ///and peers is not null
        previewStore.peers == null
            ? Container()
            : Container(
                constraints: BoxConstraints(
                    minWidth: width * 0.4, maxWidth: width * 0.5),
                height: 40,
                decoration: BoxDecoration(
                    color: surfaceDefault,
                    borderRadius: BorderRadius.circular(20)),
                child: Center(
                  child: previewStore.peers!.isEmpty
                      ? SubtitleText(
                          text: "You are the first to join",
                          textColor: onSurfaceHighEmphasis)
                      : PreviewParticipantsText(
                          peers: previewStore.peers!,
                        ),
                ),
              ),
      ],
    );
  }
}