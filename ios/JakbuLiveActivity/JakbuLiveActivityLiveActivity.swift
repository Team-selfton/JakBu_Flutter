//
//  JakbuLiveActivityLiveActivity.swift
//  JakbuLiveActivity
//
//  Created by 이지훈 on 12/9/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// TODO 항목 구조체
struct TodoItem: Codable, Hashable {
    let id: Int
    let title: String
    let isDone: Bool
}

struct JakbuLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var todos: [TodoItem]
        var totalCount: Int
        var completedCount: Int
    }

    // Fixed non-changing properties about your activity go here!
    var startDate: Date
}

struct JakbuLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: JakbuLiveActivityAttributes.self) { context in
            // Lock screen/banner UI goes here
            ZStack {
                // 그라데이션 배경
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.36, green: 0.55, blue: 0.84),
                        Color(red: 0.29, green: 0.48, blue: 0.75)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                HStack(spacing: 16) {
                    // 왼쪽: 아이콘과 타이틀
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text("👊")
                                .font(.system(size: 32))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("JakBu")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)

                                Text("오늘의 할일")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }

                        // TODO 개수 표시
                        HStack(spacing: 4) {
                            Text("\(context.state.totalCount - context.state.completedCount)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            Text("/ \(context.state.totalCount)")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.top, 4)
                    }

                    Spacer()

                    // 오른쪽: TODO 목록
                    VStack(alignment: .trailing, spacing: 6) {
                        ForEach(context.state.todos.prefix(3), id: \.id) { todo in
                            HStack(spacing: 6) {
                                Text(todo.title)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(1)

                                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(todo.isDone ? .white : .white.opacity(0.5))
                            }
                        }

                        if context.state.todos.count > 3 {
                            Text("+\(context.state.todos.count - 3)개 더")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(16)
            }
            .activityBackgroundTint(Color.clear)
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Text("👊")
                            .font(.system(size: 24))
                        VStack(alignment: .leading) {
                            Text("JakBu")
                                .font(.caption2.bold())
                            Text("할일")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing) {
                        Text("\(context.state.totalCount - context.state.completedCount)")
                            .font(.title2.bold())
                        Text("/ \(context.state.totalCount)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(context.state.todos.prefix(3), id: \.id) { todo in
                            HStack {
                                Image(systemName: todo.isDone ? "checkmark.circle.fill" : "circle")
                                    .font(.caption)
                                    .foregroundColor(todo.isDone ? .green : .secondary)
                                Text(todo.title)
                                    .font(.caption)
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                    }
                }
            } compactLeading: {
                Text("👊")
            } compactTrailing: {
                Text("\(context.state.totalCount - context.state.completedCount)/\(context.state.totalCount)")
                    .font(.caption2.bold())
            } minimal: {
                Text("\(context.state.totalCount - context.state.completedCount)")
                    .font(.caption2.bold())
            }
            .keylineTint(Color(red: 0.36, green: 0.55, blue: 0.84))
        }
    }
}

extension JakbuLiveActivityAttributes {
    fileprivate static var preview: JakbuLiveActivityAttributes {
        JakbuLiveActivityAttributes(startDate: Date())
    }
}

extension JakbuLiveActivityAttributes.ContentState {
    fileprivate static var sampleTodos: JakbuLiveActivityAttributes.ContentState {
        JakbuLiveActivityAttributes.ContentState(
            todos: [
                TodoItem(id: 1, title: "알고리즘 문제 풀기", isDone: false),
                TodoItem(id: 2, title: "운동하기", isDone: true),
                TodoItem(id: 3, title: "영어 공부", isDone: false)
            ],
            totalCount: 3,
            completedCount: 1
        )
     }

     fileprivate static var moreTodos: JakbuLiveActivityAttributes.ContentState {
         JakbuLiveActivityAttributes.ContentState(
            todos: [
                TodoItem(id: 1, title: "알고리즘 문제 풀기", isDone: true),
                TodoItem(id: 2, title: "운동하기", isDone: true),
                TodoItem(id: 3, title: "영어 공부", isDone: true),
                TodoItem(id: 4, title: "독서하기", isDone: false),
                TodoItem(id: 5, title: "프로젝트 작업", isDone: false)
            ],
            totalCount: 5,
            completedCount: 3
         )
     }
}

#Preview("Notification", as: .content, using: JakbuLiveActivityAttributes.preview) {
   JakbuLiveActivityLiveActivity()
} contentStates: {
    JakbuLiveActivityAttributes.ContentState.sampleTodos
    JakbuLiveActivityAttributes.ContentState.moreTodos
}
