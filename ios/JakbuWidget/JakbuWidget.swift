import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), todoCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), todoCount: getTodoCount())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, todoCount: getTodoCount())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func getTodoCount() -> Int {
        let sharedDefaults = UserDefaults(suiteName: "group.com.example.jakbu_flutter")
        return sharedDefaults?.integer(forKey: "todo_count") ?? 0
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let todoCount: Int
}

struct JakbuWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.29, green: 0.48, blue: 0.75),
                    Color(red: 0.27, green: 0.44, blue: 0.70),
                    Color(red: 0.24, green: 0.40, blue: 0.64)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 12) {
                // Header
                HStack(spacing: 8) {
                    Text("👊")
                        .font(.system(size: 40))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("JakBu")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text("오늘의 할일")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color.white.opacity(0.9))
                    }

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)

                Spacer()

                // Time
                Text(entry.date, style: .time)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Date
                Text(formatDate(entry.date))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.7))

                Spacer()

                // Todo count
                Text("오늘 할일 \(entry.todoCount)개")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.9))
                    .padding(.bottom, 12)
            }
        }
        .cornerRadius(32)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM. dd. (E)"
        return formatter.string(from: date)
    }
}

struct JakbuWidget: Widget {
    let kind: String = "JakbuWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JakbuWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("JakBu 위젯")
        .description("오늘의 할일을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct JakbuWidget_Previews: PreviewProvider {
    static var previews: some View {
        JakbuWidgetEntryView(entry: SimpleEntry(date: Date(), todoCount: 3))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
