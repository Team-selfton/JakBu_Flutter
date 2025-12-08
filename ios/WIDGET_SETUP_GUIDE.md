# iOS Widget 설정 가이드

iOS 위젯을 프로젝트에 추가하는 방법입니다.

## Xcode에서 Widget Extension 추가하기

### 1. Xcode에서 프로젝트 열기
```bash
open ios/Runner.xcworkspace
```

### 2. Widget Extension Target 추가

1. Xcode에서 **File > New > Target** 선택
2. **Widget Extension** 선택 후 Next
3. 설정:
   - Product Name: `JakbuWidget`
   - Include Configuration Intent: 체크 해제
   - Finish 클릭
4. "Activate "JakbuWidget" scheme?" 팝업이 뜨면 **Activate** 클릭

### 3. 기존 파일로 교체

생성된 JakbuWidget 폴더의 파일들을 삭제하고, 이미 작성된 파일들을 사용합니다:
- `ios/JakbuWidget/JakbuWidget.swift` (이미 생성됨)
- `ios/JakbuWidget/Info.plist` (이미 생성됨)
- `ios/JakbuWidget/Assets.xcassets/*` (이미 생성됨)

### 4. App Group 설정

#### Runner Target:
1. Xcode에서 **Runner** target 선택
2. **Signing & Capabilities** 탭 클릭
3. **+ Capability** 버튼 클릭
4. **App Groups** 선택
5. **+** 버튼 클릭하여 `group.com.example.jakbu_flutter` 추가
6. 체크박스 활성화

#### JakbuWidget Target:
1. Xcode에서 **JakbuWidget** target 선택
2. **Signing & Capabilities** 탭 클릭
3. **+ Capability** 버튼 클릭
4. **App Groups** 선택
5. **+** 버튼 클릭하여 `group.com.example.jakbu_flutter` 추가
6. 체크박스 활성화

### 5. Bundle Identifier 설정

#### Runner Target:
- Bundle Identifier: `com.example.jakbu_flutter` (또는 원하는 ID)

#### JakbuWidget Target:
- Bundle Identifier: `com.example.jakbu_flutter.JakbuWidget` (Runner + .JakbuWidget)

### 6. Deployment Target 설정

두 Target 모두:
- iOS Deployment Target: **14.0** 이상 (WidgetKit은 iOS 14+)

### 7. 빌드 및 실행

```bash
flutter clean
flutter pub get
flutter run
```

## 위젯 사용 방법

1. iOS 기기에서 앱 설치
2. 홈 화면에서 빈 공간 길게 누르기
3. 왼쪽 상단 **+** 버튼 클릭
4. 위젯 목록에서 **JakBu 위젯** 찾기
5. 원하는 크기 선택 (Small 또는 Medium)
6. **Add Widget** 클릭

## 문제 해결

### "No such module 'WidgetKit'" 에러
- Deployment Target을 iOS 14.0 이상으로 설정했는지 확인

### 위젯이 목록에 나타나지 않음
- App Group이 양쪽 Target에 모두 추가되었는지 확인
- Bundle Identifier가 올바른지 확인
- 실제 기기에서 테스트 (시뮬레이터는 위젯 지원 제한적)

### 데이터가 위젯에 표시되지 않음
- App Group ID가 Flutter 코드와 일치하는지 확인
  - Flutter: `widget_service.dart`의 `group.com.example.jakbu_flutter`
  - iOS: 양쪽 Target의 App Groups

## 주의사항

- **App Group ID는 실제 개발자 계정의 Bundle ID에 맞춰 변경해야 합니다**
- 현재 설정: `group.com.example.jakbu_flutter`
- 실제 배포 시: `group.YOUR_BUNDLE_ID`로 변경

예시:
- Bundle ID가 `com.mycompany.jakbu`라면
- App Group ID: `group.com.mycompany.jakbu`
