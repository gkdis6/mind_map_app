import 'package:flutter/material.dart';

import 'm_node.dart';
import 'w_mindmap.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 초기 노드
  NodeModel rootNode = parseTree('Root Node');

  // 텍스트 컨트롤러
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Tab 키 처리 메서드
  void _handleTabKeyPress() {
    final currentText = _controller.text;
    final cursorPosition = _controller.selection.base.offset;

    // Tab을 현재 커서 위치에 삽입
    final newText = currentText.replaceRange(
      cursorPosition,
      cursorPosition,
      '  ', // Tab 대신 공백 사용
    );

    setState(() {
      _controller.text = newText;
      _controller.selection =
          TextSelection.collapsed(offset: cursorPosition + 2);
      rootNode = parseTree(newText); // 노드 트리 업데이트
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mind Map')),
      body: Column(
        children: [
          // 사용자 입력 필드
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Mind Map Structure',
              ),
              maxLines: 5,
              onChanged: (value) {
                if (value.trim() == '') return;
                setState(() {
                  rootNode = parseTree(value);
                });
              },
            ),
          ),
          Expanded(
            child: InteractiveViewer(
              constrained: false,
              minScale: 0.5,
              maxScale: 2.0,
              child: MindMapWidget(node: rootNode),
            ),
          ),
        ],
      ),
    );
  }
}
