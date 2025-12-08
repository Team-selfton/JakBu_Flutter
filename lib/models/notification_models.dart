enum IntervalType { TWO_HOUR, FOUR_HOUR, DAILY }

class FcmTokenRequest {
  final String fcmToken;

  FcmTokenRequest({required this.fcmToken});

  Map<String, dynamic> toJson() => {
        'fcmToken': fcmToken,
      };
}

class NotificationSetting {
  final int id;
  final IntervalType intervalType;
  final bool enabled;

  NotificationSetting({
    required this.id,
    required this.intervalType,
    required this.enabled,
  });

  factory NotificationSetting.fromJson(Map<String, dynamic> json) =>
      NotificationSetting(
        id: json['id'],
        intervalType: _parseIntervalType(json['intervalType']),
        enabled: json['enabled'],
      );

  static IntervalType _parseIntervalType(String type) {
    switch (type) {
      case 'TWO_HOUR':
        return IntervalType.TWO_HOUR;
      case 'FOUR_HOUR':
        return IntervalType.FOUR_HOUR;
      case 'DAILY':
        return IntervalType.DAILY;
      default:
        return IntervalType.TWO_HOUR;
    }
  }
}

class NotificationSettingRequest {
  final IntervalType intervalType;
  final bool enabled;

  NotificationSettingRequest({
    required this.intervalType,
    required this.enabled,
  });

  Map<String, dynamic> toJson() => {
        'intervalType': _intervalTypeToString(intervalType),
        'enabled': enabled,
      };

  static String _intervalTypeToString(IntervalType type) {
    switch (type) {
      case IntervalType.TWO_HOUR:
        return 'TWO_HOUR';
      case IntervalType.FOUR_HOUR:
        return 'FOUR_HOUR';
      case IntervalType.DAILY:
        return 'DAILY';
    }
  }
}
