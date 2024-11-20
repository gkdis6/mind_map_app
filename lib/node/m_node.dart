// lib/models/node_model.dart
import 'package:flutter/material.dart';

class NodeModel {
  final String id;
  String title;
  Color color;
  String? memo;
  bool isStar;
  List<NodeModel> children;

  NodeModel({
    required this.id,
    required this.title,
    this.color = Colors.blueAccent,
    String? memo,
    bool? isStar,
    List<NodeModel>? children,
  })  : children = children ?? [],
        isStar = isStar ?? false;
}

NodeModel parseTree(String input, {int tabSize = 2}) {
  // 각 줄을 나누고 트리 구조를 저장할 스택 초기화
  final lines =
      input.split('\n').where((line) => line.trim().isNotEmpty).toList();
  final stack = <NodeModel>[];

  NodeModel? root;

  for (var line in lines) {
    final trimmedLine = line.trimLeft();
    final indent = line.length - trimmedLine.length;

    final depth = indent ~/ tabSize;

    final newNode = NodeModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: trimmedLine);

    if (depth == 0) {
      root = newNode;
      stack.clear();
      stack.add(newNode);
    } else {
      while (stack.length > depth) {
        stack.removeLast();
      }
      stack.last.children.add(newNode);
      stack.add(newNode);
    }
  }

  return root!;
}

String stringifyTree(NodeModel root, {int tabSize = 2}) {
  final buffer = StringBuffer();

  void _dfs(NodeModel node, int depth) {
    // 현재 노드의 제목을 추가
    final indent = ' ' * (depth * tabSize);
    buffer.writeln('$indent${node.title}');

    // 자식 노드를 재귀적으로 순회
    for (final child in node.children) {
      _dfs(child, depth + 1);
    }
  }

  _dfs(root, 0); // 루트 노드부터 시작
  return buffer.toString();
}
