import 'package:data_store_example/meeting/peer_track_node.dart';
import 'package:data_store_example/utilities.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

class MeetingPage extends StatefulWidget {
  const MeetingPage({super.key});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage>
    implements HMSUpdateListener {
  List<PeerTrackNode> peers = [];
  late HMSSDK _hmssdk;
  bool isAudioOn = true, isVideoOn = true;

  @override
  void initState() {
    super.initState();
    _hmssdk = HMSSDK();
    _hmssdk.build();
    _hmssdk.addUpdateListener(listener: this);
    _hmssdk.join(config: Utilities.getHMSConfig());
  }

  @override
  void onHMSError({required HMSException error}) {}

  @override
  void onJoin({required HMSRoom room}) {}

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {
    if (peer.isLocal) {
      if (trackUpdate == HMSTrackUpdate.trackMuted) {
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          isAudioOn = false;
        } else {
          isVideoOn = false;
        }
      } else if (trackUpdate == HMSTrackUpdate.trackUnMuted) {
        if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
          isAudioOn = true;
        } else {
          isVideoOn = true;
        }
      }
      updateUI();
    }
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      int index =
          peers.indexWhere((node) => node.uid == "${peer.peerId}mainVideo");
      if (index != -1) {
        peers[index].track = track as HMSVideoTrack;
      } else {
        if (track.source == "SCREEN") {
          peers.add(PeerTrackNode(
              peer: peer,
              uid: "${peer.peerId}${track.trackId}",
              track: track as HMSVideoTrack));
        } else {
          if (peer.isLocal) {
            peers.insert(
                0,
                PeerTrackNode(
                    peer: peer,
                    uid: "${peer.peerId}mainVideo",
                    track: track as HMSVideoTrack));
          } else {
            peers.add(PeerTrackNode(
                peer: peer,
                uid: "${peer.peerId}mainVideo",
                track: track as HMSVideoTrack));
          }
        }
      }
      updateUI();
    }
  }

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        int index =
            peers.indexWhere((node) => node.uid == "${peer.peerId}mainVideo");
        if (index == -1) {
          if (peer.isLocal) {
            peers.insert(
                0, PeerTrackNode(peer: peer, uid: "${peer.peerId}mainVideo"));
          } else {
            peers
                .add(PeerTrackNode(peer: peer, uid: "${peer.peerId}mainVideo"));
          }
        }
        updateUI();
        break;
      case HMSPeerUpdate.peerLeft:
        int index =
            peers.indexWhere((node) => node.uid == "${peer.peerId}mainVideo");
        if (index != -1) {
          peers.removeAt(index);
        }
        updateUI();
        break;
      case HMSPeerUpdate.roleUpdated:
        break;
      case HMSPeerUpdate.metadataChanged:
        break;
      case HMSPeerUpdate.nameChanged:
        break;
      case HMSPeerUpdate.defaultUpdate:
        break;
      case HMSPeerUpdate.networkQualityUpdated:
        break;
    }
  }

  void leaveMeeting() {
    _hmssdk.removeUpdateListener(listener: this);
    _hmssdk.leave();
    _hmssdk.destroy();
    Navigator.pop(context);
  }

  void updateUI() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final heightofEachTile = MediaQuery.of(context).size.height / 2;
    final widthofEachTile = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        leaveMeeting();
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(),
              slivers: [
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      mainAxisExtent: widthofEachTile,
                      crossAxisSpacing: 5,
                      childAspectRatio: heightofEachTile / widthofEachTile),
                  delegate: SliverChildBuilderDelegate(
                      ((context, index) => (peers[index].track == null ||
                              peers[index].track!.isMute)
                          ? Container(
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(20, 23, 28, 1),
                              ),
                              child: Center(
                                child: CircleAvatar(
                                    backgroundColor: Colors.purple,
                                    radius: 36,
                                    child: Text(
                                      peers[index].peer.name[0],
                                      style: const TextStyle(
                                          fontSize: 36, color: Colors.white),
                                    )),
                              ),
                            )
                          : HMSVideoView(
                              key: Key(peers[index].uid),
                              track: peers[index].track!,
                              scaleType: ScaleType.SCALE_ASPECT_FILL,
                            )),
                      childCount: peers.length),
                )
              ],
            ),
            (peers.isNotEmpty && peers[0].peer.isLocal)
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        height: 60,
                        width: widthofEachTile - 20,
                        decoration: BoxDecoration(
                            color: const Color.fromRGBO(29, 34, 41, 1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                _hmssdk.switchAudio(isOn: isAudioOn);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withAlpha(60),
                                        blurRadius: 3.0,
                                        spreadRadius: 5.0,
                                      ),
                                    ]),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                      isAudioOn ? Icons.mic : Icons.mic_off,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                _hmssdk.switchVideo(isOn: isVideoOn);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withAlpha(60),
                                        blurRadius: 3.0,
                                        spreadRadius: 5.0,
                                      ),
                                    ]),
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                      isVideoOn
                                          ? Icons.videocam
                                          : Icons.videocam_off_rounded,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                leaveMeeting();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.red.withAlpha(60),
                                        blurRadius: 3.0,
                                        spreadRadius: 5.0,
                                      ),
                                    ]),
                                child: const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.red,
                                  child:
                                      Icon(Icons.call_end, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onReconnected() {}

  @override
  void onReconnecting() {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}
}