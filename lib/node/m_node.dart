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
  print(input);
  print(input.split('\n'));
  final lines =
      input.split('\n').where((line) => line.trim().isNotEmpty).toList();
  final stack = <NodeModel>[];

  NodeModel? root;

  for (var line in lines) {
    final trimmedLine = line.trimLeft();
    final indent = line.length - trimmedLine.length;
    print(indent);

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
