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
                hintText: 'Root Node\n  Sub Node 1\n    Sub Sub Node 1',
              ),
              maxLines: 5,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                rootNode = parseTree(_controller.text);
              });
            },
            child: Text('Update Mind Map'),
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
