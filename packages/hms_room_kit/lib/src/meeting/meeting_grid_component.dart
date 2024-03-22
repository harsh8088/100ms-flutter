///Dart imports
library;

import 'dart:io';

///Package imports
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

///Project imports
import 'package:hms_room_kit/hms_room_kit.dart';
import 'package:hms_room_kit/src/enums/meeting_mode.dart';
import 'package:hms_room_kit/src/meeting/meeting_navigation_visibility_controller.dart';
import 'package:hms_room_kit/src/meeting/meeting_store.dart';
import 'package:hms_room_kit/src/model/peer_track_node.dart';
import 'package:hms_room_kit/src/widgets/meeting_modes/custom_one_to_one_grid.dart';
import 'package:hms_room_kit/src/widgets/meeting_modes/one_to_one_mode.dart';

///[MeetingGridComponent] is a component that is used to show the video grid
class MeetingGridComponent extends StatelessWidget {
  final MeetingNavigationVisibilityController? visibilityController;

  const MeetingGridComponent({super.key, required this.visibilityController});

  double getHeight(bool showControls, BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    EdgeInsets padding = MediaQuery.of(context).padding;
    double screenHeight = MediaQuery.of(context).size.height;

    switch (orientation) {
      case Orientation.portrait:
        if (!showControls) {
          return screenHeight - padding.top - padding.bottom - 20;
        } else {
          return screenHeight -
              padding.top -
              padding.bottom -
              (Platform.isAndroid
                  ? 160
                  : Platform.isIOS
                      ? 230
                      : 160);
        }
      case Orientation.landscape:
        return screenHeight - padding.top - padding.bottom;
    }
  }

  double getInsetTilePosition(bool showControls, BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    switch (orientation) {
      case Orientation.portrait:
        return showControls ? 250 : 130;
      case Orientation.landscape:
        return 110;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MeetingStore,
            Tuple6<List<PeerTrackNode>, bool, int, int, MeetingMode, int>>(
        selector: (_, meetingStore) => Tuple6(
            meetingStore.peerTracks,
            meetingStore.isHLSLink,
            meetingStore.peerTracks.length,
            meetingStore.screenShareCount,
            meetingStore.meetingMode,
            meetingStore.viewControllers.length),
        builder: (_, data, __) {
          ///If there are no peerTracks or the view controllers are empty we show an empty tapable container
          if (data.item3 == 0 || data.item6 == 0) {
            return GestureDetector(
                onTap: () => visibilityController?.toggleControlsVisibility(),
                child: Container(
                  color: Colors.transparent,
                  height: double.infinity,
                  width: double.infinity,
                ));
          }
          return Selector<MeetingStore, Tuple2<MeetingMode, HMSPeer?>>(
              selector: (_, meetingStore) =>
                  Tuple2(meetingStore.meetingMode, meetingStore.localPeer),
              builder: (_, modeData, __) {
                ///This renders the video grid based on whether the controls are visible or not
                return Selector<MeetingNavigationVisibilityController, bool>(
                    selector: (_, meetingNavigationVisibilityController) =>
                        meetingNavigationVisibilityController.showControls,
                    builder: (_, showControls, __) {
                      return Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),

                          ///If the controls are visible we reduce the
                          ///height of video grid by 140 else it covers the whole screen
                          ///
                          ///Here we also check for the platform and reduce the height accordingly
                          height: getHeight(showControls, context),
                          child: GestureDetector(
                            onTap: () => visibilityController
                                ?.toggleControlsVisibility(),
                            child: (modeData.item1 ==
                                        MeetingMode.activeSpeakerWithInset &&
                                    (context
                                                .read<MeetingStore>()
                                                .localPeer
                                                ?.audioTrack !=
                                            null ||
                                        context
                                                .read<MeetingStore>()
                                                .localPeer
                                                ?.videoTrack !=
                                            null))
                                ? OneToOneMode(
                                    ///This is done to keep the inset tile
                                    ///at correct position when controls are hidden
                                    bottomMargin: getInsetTilePosition(
                                        showControls, context),
                                    peerTracks: data.item1,
                                    screenShareCount: data.item4,
                                    context: context,
                                  )
                                : CustomOneToOneGrid(
                                    isLocalInsetPresent: false,
                                    peerTracks: data.item1,
                                  ),
                          ),
                        ),
                      );
                    });
              });
        });
  }
}
