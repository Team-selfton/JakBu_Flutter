import 'package:home_widget/home_widget.dart';

class WidgetService {
  static Future<void> updateWidget({required int todoCount}) async {
    try {
      // Save data to be displayed on the widget
      await HomeWidget.saveWidgetData<int>('todo_count', todoCount);

      // Update the widget
      await HomeWidget.updateWidget(
        androidName: 'JakbuWidget',
        iOSName: 'JakbuWidget',
      );
    } catch (e) {
    }
  }

  static Future<void> initWidget() async {
    try {
      await HomeWidget.setAppGroupId('group.com.example.jakbu_flutter');
    } catch (e) {
    }
  }
}
