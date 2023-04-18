//Class contains the constants used throughout the application
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:hmssdk_flutter_example/common/util/utility_function.dart';

class Constant {
  static String defaultMeetingLink =
      "https://yogi.app.100ms.live/meeting/ssz-eqr-eaa";

  static String meetingUrl = defaultMeetingLink;
  static String meetingCode = "";
  static String streamingUrl = "";

  static HMSLogLevel webRTCLogLevel = HMSLogLevel.ERROR;
  static HMSLogLevel sdkLogLevel = HMSLogLevel.VERBOSE;
  static AppFlavors appFlavor = AppFlavors.hmsInternal;
}
