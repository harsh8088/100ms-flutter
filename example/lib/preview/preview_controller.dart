import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:hmssdk_flutter_example/meeting/hms_sdk_interactor.dart';
import 'package:hmssdk_flutter_example/service/room_service.dart';
import 'package:uuid/uuid.dart';

class PreviewController {
  final String roomId;
  final String user;
  HMSSDKInteractor? _hmsSdkInteractor;

  PreviewController({required this.roomId, required this.user})
      : _hmsSdkInteractor = HMSSDKInteractor();

  Future<bool> startPreview() async {
    List<String?>? token =
        await RoomService().getToken(user: user, room: roomId);

    if (token == null) return false;
    print(token[0]);
    HMSConfig config = HMSConfig(
        userId: Uuid().v1(),
        roomId: roomId,
        authToken: token[0]!,
        userName: user,
        isProdLink: token[1] == "true" ? true : false);

    _hmsSdkInteractor?.previewVideo(config: config);
    return true;
  }

  void startListen(HMSPreviewListener listener) {
    _hmsSdkInteractor?.addPreviewListener(listener);
  }

  void stopCapturing() {
    _hmsSdkInteractor?.stopCapturing();
  }

  void startCapturing() {
    _hmsSdkInteractor?.startCapturing();
  }

  void switchAudio({bool isOn = false}) {
    _hmsSdkInteractor?.switchAudio(isOn: isOn);
  }
}
