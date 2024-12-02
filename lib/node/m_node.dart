// lib/models/node_model.dart
import 'package:flutter/material.dart';

class NodeModel {
  final String id;
  String title;
  Color color;
  String? memo;
  bool isStar;
  bool isFlip;
  List<NodeModel> children;

  NodeModel({
    required this.id,
    required this.title,
    this.color = Colors.blueAccent,
    this.memo,
    bool? isStar,
    bool? isFlip,
    List<NodeModel>? children,
  })  : children = children ?? [],
        isStar = isStar ?? false,
        isFlip = isFlip ?? false;

  // JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'color': color.value, // Color를 int로 변환
      'memo': memo,
      'isStar': isStar,
      'isFlip': isFlip,
      'children': children?.map((child) => child.toJson()).toList(),
    };
  }

  // JSON에서 객체 생성
  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'],
      title: json['title'],
      color: Color(json['color']), // int에서 Color로 변환
      memo: json['memo'],
      isStar: json['isStar'] ?? false,
      isFlip: json['isFlip'] ?? false,
      children: (json['children'] as List<dynamic>?)
              ?.map((child) => NodeModel.fromJson(child))
              .toList() ??
          [],
    );
  }

  bool hasChild() {
    return children != null && children != [];
  }
}

NodeModel parseTree(String rootName, String input, {int tabSize = 2}) {
  // 각 줄을 나누고 트리 구조를 저장할 스택 초기화
  final lines =
      input.split('\n').where((line) => line.trim().isNotEmpty).toList();
  final stack = <NodeModel>[];

  NodeModel root = NodeModel(id: '0', title: rootName);
  stack.add(root);
  for (var line in lines) {
    final trimmedLine = line.trimLeft();
    final indent = line.length - trimmedLine.length;

    final depth = (indent ~/ tabSize) + 1;

    final newNode = NodeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: trimmedLine);

    // if (depth == 0) {
    //   root = newNode;
    //   stack.clear();
    //   stack.add(newNode);
    // } else {
    while (stack.length > depth) {
      stack.removeLast();
    }
    stack.last.children?.add(newNode);
    stack.add(newNode);
    // }
  }

  return root!;
}

String stringifyTree(NodeModel root, {int tabSize = 2}) {
  final buffer = StringBuffer();

  void _dfs(NodeModel node, int depth) {
    for (final child in node.children) {
      final indent = ' ' * (depth * tabSize);
      buffer.writeln('$indent${child.title}');
      _dfs(child, depth + 1);
    }
  }

  _dfs(root, 0); // 루트 노드부터 시작
  return buffer.toString();
}
