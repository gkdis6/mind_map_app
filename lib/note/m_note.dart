class Note {
  String title;
  String content;
  int id;

  Note({
    required this.title,
    required this.content,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'content': content, 'id': id};
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      content: json['content'],
      id: json['id'],
    );
  }
}
