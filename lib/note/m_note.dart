import 'package:mind_map_app/node/m_node.dart';

class Note {
  String title;
  NodeModel? node;
  int id;

  Note({
    required this.title,
    required this.node,
    required this.id,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'node': node?.toJson(), 'id': id};
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'],
      node: json['node'] != null
          ? NodeModel.fromJson(json['node'] as Map<String, dynamic>)
          : null,
      id: json['id'],
    );
  }
}
