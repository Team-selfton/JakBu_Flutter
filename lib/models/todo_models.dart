enum TodoStatus { todo, done }

class TodoModel {
  final int id;
  final String title;
  final String date;
  final TodoStatus status;

  TodoModel({
    required this.id,
    required this.title,
    required this.date,
    required this.status,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'],
        title: json['title'],
        date: json['date'],
        status: json['status'] == 'DONE' ? TodoStatus.done : TodoStatus.todo,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'status': status == TodoStatus.done ? 'DONE' : 'TODO',
      };
}

class CreateTodoRequest {
  final String title;
  final String date;

  CreateTodoRequest({
    required this.title,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'date': date,
      };
}
