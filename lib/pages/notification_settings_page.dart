import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/api_client.dart';
import '../models/notification_models.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final NotificationService _notificationService =
      NotificationService(ApiClient());

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEnabled = false;
  IntervalType _selectedInterval = IntervalType.twoHour;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);

    try {
      final settings = await _notificationService.getNotificationSetting();
      setState(() {
        _isEnabled = settings.enabled;
        _selectedInterval = settings.intervalType;
      });
    } catch (e) {
      // 설정이 없으면 기본값 사용
      debugPrint('알림 설정 로드 실패: $e');
      setState(() {
        _isEnabled = false;
        _selectedInterval = IntervalType.twoHour;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final request = NotificationSettingRequest(
        intervalType: _selectedInterval,
        enabled: _isEnabled,
      );

      await _notificationService.saveNotificationSetting(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('알림 설정이 저장되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 설정 저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  String _getIntervalText(IntervalType type) {
    switch (type) {
      case IntervalType.twoHour:
        return '2시간 간격';
      case IntervalType.fourHour:
        return '4시간 간격';
      case IntervalType.daily:
        return '매일 (오전 9시)';
    }
  }

  String _getIntervalDescription(IntervalType type) {
    switch (type) {
      case IntervalType.twoHour:
        return '2시간마다 알림을 받습니다';
      case IntervalType.fourHour:
        return '4시간마다 알림을 받습니다';
      case IntervalType.daily:
        return '매일 오전 9시에 알림을 받습니다';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 알림 활성화/비활성화
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: const Text(
                        '푸시 알림',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        _isEnabled ? '알림이 활성화되어 있습니다' : '알림이 비활성화되어 있습니다',
                        style: TextStyle(
                          color: _isEnabled ? Colors.green : Colors.grey,
                        ),
                      ),
                      value: _isEnabled,
                      onChanged: (value) {
                        setState(() => _isEnabled = value);
                      },
                      activeColor: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 알림 간격 선택
                  if (_isEnabled) ...[
                    const Text(
                      '알림 간격',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...IntervalType.values.map((type) {
                      final isSelected = _selectedInterval == type;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedInterval = type);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Radio<IntervalType>(
                                  value: type,
                                  groupValue: _selectedInterval,
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedInterval = value);
                                    }
                                  },
                                  activeColor: Colors.blue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _getIntervalText(type),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getIntervalDescription(type),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],

                  const SizedBox(height: 32),

                  // 저장 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '저장',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
