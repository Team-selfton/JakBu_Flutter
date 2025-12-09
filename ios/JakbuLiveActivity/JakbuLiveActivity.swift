//
//  JakbuLiveActivity.swift
//  JakbuLiveActivity
//
//  Created by 이지훈 on 12/9/25.
//

import WidgetKit
import SwiftUI

// SharedUserDefaults를 사용해 Flutter 앱과 데이터 공유
let sharedDefaults = UserDefaults(suiteName: "group.ahyeonlee.jakbuFlutter")

struct TodoWidgetItem: Codable {
    let id: Int
    let title: String
    let isDone: Bool
}

struct TodoProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoEntry {
        TodoEntry(date: Date(), todos: [], totalCount: 0, completedCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoEntry) -> ()) {
        let entry = loadTodoEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoEntry>) -> ()) {
        let entry = loadTodoEntry()

        // 15분마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func loadTodoEntry() -> TodoEntry {
        var todos: [TodoWidgetItem] = []
        var totalCount = 0
        var completedCount = 0

        if let data = sharedDefaults?.data(forKey: "widget_todos"),
           let decodedTodos = try? JSONDecoder().decode([TodoWidgetItem].self, from: data) {
            todos = decodedTodos
            totalCount = todos.count
            completedCount = todos.filter { $0.isDone }.count
        }

        return TodoEntry(date: Date(), todos: todos, totalCount: totalCount, completedCount: completedCount)
    }
}

struct TodoEntry: TimelineEntry {
    let date: Date
    let todos: [TodoWidgetItem]
    let totalCount: Int
    let completedCount: Int
}

struct JakbuLiveActivityEntryView : View {
    var entry: TodoProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// Small Widget (작은 위젯)
struct SmallWidgetView: View {
    let entry: TodoEntry

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.16, blue: 0.25),
                    Color(red: 0.10, green: 0.13, blue: 0.19)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("👊")
                        .font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("JakBu")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("오늘의 할일")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Spacer()

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(entry.totalCount - entry.completedCount)")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                    Text("/ \(entry.totalCount)")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }

                if entry.totalCount > 0 {
                    Text("\(entry.completedCount)개 완료")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                } else {
                    Text("할일 없음")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(16)
        }
    }
}

// Medium Widget (중간 위젯)
struct MediumWidgetView: View {
    let entry: TodoEntry

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.16, blue: 0.25),
                    Color(red: 0.10, green: 0.13, blue: 0.19)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            HStack(spacing: 16) {
                // 왼쪽: 요약
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("👊")
                            .font(.system(size: 32))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("JakBu")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                            Text("오늘의 할일")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }

                    Spacer()

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text("\(entry.totalCount - entry.completedCount)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        Text("/ \(entry.totalCount)")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 오른쪽: Todo 목록
                VStack(alignment: .leading, spacing: 6) {
                    if entry.todos.isEmpty {
                        Text("할일이 없어요!")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        ForEach(entry.todos.prefix(4), id: \.id) { todo in
                            HStack(spacing: 6) {
                                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 12))
                                    .foregroundColor(todo.isDone ? Color(red: 0.36, green: 0.55, blue: 0.84) : .white.opacity(0.4))

                                Text(todo.title)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(1)
                                    .strikethrough(todo.isDone, color: .white.opacity(0.5))
                            }
                        }
                        if entry.todos.count > 4 {
                            Text("+\(entry.todos.count - 4)개 더")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
        }
    }
}

// Large Widget (큰 위젯)
struct LargeWidgetView: View {
    let entry: TodoEntry

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.12, green: 0.16, blue: 0.25),
                    Color(red: 0.10, green: 0.13, blue: 0.19)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                // 헤더
                HStack(spacing: 8) {
                    Text("👊")
                        .font(.system(size: 40))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("JakBu")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Text("오늘의 할일")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    VStack(alignment: .trailing) {
                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Text("\(entry.totalCount - entry.completedCount)")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            Text("/ \(entry.totalCount)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        Text("\(entry.completedCount)개 완료")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Divider()
                    .background(.white.opacity(0.2))

                // Todo 목록
                if entry.todos.isEmpty {
                    VStack(spacing: 8) {
                        Text("👊")
                            .font(.system(size: 60))
                        Text("할일이 없어요!")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        Text("오늘의 할일을 추가해보세요")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(entry.todos.prefix(8), id: \.id) { todo in
                            HStack(spacing: 10) {
                                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 16))
                                    .foregroundColor(todo.isDone ? Color(red: 0.36, green: 0.55, blue: 0.84) : .white.opacity(0.4))

                                Text(todo.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(1)
                                    .strikethrough(todo.isDone, color: .white.opacity(0.5))

                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(todo.isDone ? 0.05 : 0.1))
                            )
                        }

                        if entry.todos.count > 8 {
                            Text("+\(entry.todos.count - 8)개 더")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.leading, 12)
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}

struct JakbuLiveActivity: Widget {
    let kind: String = "JakbuLiveActivity"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { entry in
            if #available(iOS 17.0, *) {
                JakbuLiveActivityEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                JakbuLiveActivityEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("JakBu 할일")
        .description("오늘의 할일을 확인하세요")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    JakbuLiveActivity()
} timeline: {
    TodoEntry(date: .now, todos: [], totalCount: 0, completedCount: 0)
    TodoEntry(date: .now, todos: [
        TodoWidgetItem(id: 1, title: "알고리즘 풀기", isDone: false),
        TodoWidgetItem(id: 2, title: "운동하기", isDone: true)
    ], totalCount: 2, completedCount: 1)
}

#Preview(as: .systemMedium) {
    JakbuLiveActivity()
} timeline: {
    TodoEntry(date: .now, todos: [
        TodoWidgetItem(id: 1, title: "알고리즘 풀기", isDone: false),
        TodoWidgetItem(id: 2, title: "운동하기", isDone: true),
        TodoWidgetItem(id: 3, title: "영어 공부", isDone: false)
    ], totalCount: 3, completedCount: 1)
}

#Preview(as: .systemLarge) {
    JakbuLiveActivity()
} timeline: {
    TodoEntry(date: .now, todos: [
        TodoWidgetItem(id: 1, title: "알고리즘 풀기", isDone: false),
        TodoWidgetItem(id: 2, title: "운동하기", isDone: true),
        TodoWidgetItem(id: 3, title: "영어 공부", isDone: false),
        TodoWidgetItem(id: 4, title: "독서하기", isDone: false),
        TodoWidgetItem(id: 5, title: "프로젝트 작업", isDone: true)
    ], totalCount: 5, completedCount: 2)
}
