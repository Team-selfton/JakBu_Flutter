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
      print('Error updating widget: $e');
    }
  }

  static Future<void> initWidget() async {
    try {
      await HomeWidget.setAppGroupId('YOUR_GROUP_ID');
    } catch (e) {
      print('Error initializing widget: $e');
    }
  }
}
