// Dart imports:
import 'dart:core';

class HMSInSufficientDataException implements Exception {
  final String message;

  HMSInSufficientDataException({required this.message});
  
  @override
  String toString() => 'HMSInSufficientDataException: $message';
}
