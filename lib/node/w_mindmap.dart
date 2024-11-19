// lib/widgets/mindmap_node.dart
import 'package:flutter/material.dart';
import 'package:mind_map/mind_map.dart';

import 'm_node.dart';

class MindMapWidget extends StatefulWidget {
  final NodeModel node;

  const MindMapWidget({
    Key? key,
    required this.node,
  }) : super(key: key);

  @override
  _MindMapWidgetState createState() => _MindMapWidgetState();
}

class _MindMapWidgetState extends State<MindMapWidget> {
  bool _isEditing = false; // 이름 편집 모드 여부를 확인하는 변수
  late TextEditingController _controller; // 노드 이름 입력을 위한 컨트롤러
  final FocusNode _focusNode = FocusNode(); // TextField에 포커스를 관리할 FocusNode

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.node.title);

    // 포커스가 사라지면 편집 모드를 종료하도록 설정
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isEditing = false;
          widget.node.title = _controller.text; // 새 이름 저장
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addNode(NodeModel parent) {
    setState(() {
      final newNode = NodeModel(
        id: DateTime.now().toString(),
        title: 'Component ${parent.children.length + 1}',
      );
      parent.children.add(newNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _isEditing
            ? Container(
                width: 100,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onSubmitted: (value) {
                    setState(() {
                      _isEditing = false;
                      widget.node.title = value;
                    });
                  },
                  decoration: InputDecoration(border: OutlineInputBorder()),
                ),
              )
            : GestureDetector(
                onTap: () {
                  setState(() {
                    _isEditing = true;
                  });
                  _focusNode.requestFocus();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.node.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: Row(
                    children: [
                      Text(widget.node.title),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          _addNode(widget.node);
                        },
                      ),
                    ],
                  ),
                ),
              ),
        if (widget.node.children.isNotEmpty)
          MindMap(
            dotRadius: 4,
            children: widget.node.children
                .map((child) => MindMapWidget(node: child)) // 재귀 호출
                .toList(),
          ),
      ],
    );
  }
}
