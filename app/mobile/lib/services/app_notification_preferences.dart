import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// 앱 내부 알림 on/off (시스템 권한과 별도). 실제 발송 시 [shouldDeliver]로 판단.
class AppNotificationPreferences {
    AppNotificationPreferences._();

    static const String prefsKeyEnabled = 'appNotificationsEnabled';

    static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
        FlutterLocalNotificationsPlugin();


    /// 앱 설정 토글 값. 키가 없으면 시스템 권한 허용 여부로 1회 추정(기존 사용자 호환).
    static Future<bool> isEnabled() async {
        final prefs = await SharedPreferences.getInstance();
        if (!prefs.containsKey(prefsKeyEnabled)) {
            return _inferEnabledFromSystemPermission();
        }
        return prefs.getBool(prefsKeyEnabled) ?? false;
    }


    static Future<void> setEnabled(bool enabled) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(prefsKeyEnabled, enabled);
        if (!enabled) {
            try {
                await _localNotificationsPlugin.cancelAll();
            } catch (_) {
                // 플러그인 미초기화(테스트 등) 시 무시
            }
        }
    }


    /// 앱 설정 ON 이고 시스템 권한도 허용된 경우에만 알림을 보냅니다.
    static Future<bool> shouldDeliver() async {
        if (!await isEnabled()) return false;
        if (!Platform.isIOS && !Platform.isAndroid) return true;
        final status = await Permission.notification.status;
        return status.isGranted;
    }


    static Future<bool> isSystemPermissionGranted() async {
        if (!Platform.isIOS && !Platform.isAndroid) return true;
        final status = await Permission.notification.status;
        return status.isGranted;
    }


    /// ON 시 시스템 알림 권한 요청. 반환값은 권한 허용 여부.
    static Future<bool> requestSystemPermission() async {
        if (!Platform.isIOS && !Platform.isAndroid) return true;

        if (Platform.isIOS) {
            final ios = _localNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>();
            if (ios != null) {
                final granted = await ios.requestPermissions(
                    alert: true,
                    badge: true,
                    sound: true,
                );
                return granted ?? false;
            }
        }

        final status = await Permission.notification.request();
        return status.isGranted;
    }


    static Future<bool> _inferEnabledFromSystemPermission() async {
        return isSystemPermissionGranted();
    }
}
