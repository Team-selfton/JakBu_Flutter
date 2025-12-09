import 'package:flutter/material.dart';

// 전역 Navigator 키 (API 에러 시 로그인 화면으로 이동하기 위해 사용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 인증 실패 시 호출될 콜백 (api_client에서 UI 위젯을 직접 import하지 않기 위해 사용)
void Function()? onAuthenticationFailed;
