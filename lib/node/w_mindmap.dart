import 'package:flutter/material.dart';
import 'package:mind_map/mind_map.dart';

import 'm_node.dart';

class MindMapWidget extends StatefulWidget {
  final NodeModel node;
  final bool flipMode; // flipMode를 추가로 받음

  const MindMapWidget({
    Key? key,
    required this.node,
    required this.flipMode,
  }) : super(key: key);

  @override
  _MindMapWidgetState createState() => _MindMapWidgetState();
}

class _MindMapWidgetState extends State<MindMapWidget> {
  bool _isEditing = false;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.node.title);

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _isEditing = false;
          widget.node.title = _controller.text;
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

  void _editMemo(NodeModel node) {
    showDialog(
      context: context,
      builder: (context) {
        final memoController = TextEditingController(text: node.memo);
        return AlertDialog(
          title: Text('메모 수정'),
          content: TextField(
            controller: memoController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '메모를 입력하세요...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  node.memo = memoController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('저장'),
            ),
          ],
        );
      },
    );
  }

  void _toggleNodeVisibility() {
    setState(() {
      widget.node.isFlip = !widget.node.isFlip; // isFlip 상태 전환
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
                  if (widget.flipMode || widget.node.isFlip) {
                    _toggleNodeVisibility(); // flipMode가 활성화된 경우 isFlip 변경
                  } else {
                    setState(() {
                      _isEditing = true;
                    });
                    _focusNode.requestFocus();
                  }
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
                      Text(widget.node.isFlip ? '🔒 숨김' : widget.node.title),
                      IconButton(
                        icon: Icon(Icons.edit_note),
                        onPressed: () {
                          _editMemo(widget.node);
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
                .map((child) => MindMapWidget(
                    node: child, flipMode: widget.flipMode)) // flipMode 전달
                .toList(),
          ),
      ],
    );
  }
}
