import 'package:flutter/material.dart';
import 'package:mind_map/mind_map.dart';

import 'm_node.dart';
import 'w_mindmap.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 최상위 노드 생성
  // NodeModel rootNode = NodeModel(id: '1', title: 'Root Node');
  NodeModel rootNode = parseTree('''
Root Node
  Sub Node 1
    Sub Sub Node 1
  Sub Node 2
''');

  Widget _buildMindMap(NodeModel node) {
    return Row(
      children: [
        MindMapWidget(node: node),
        if (node.children.isNotEmpty)
          MindMap(
            dotRadius: 4,
            children: node.children
                .map((child) => _buildMindMap(child)) // 자식 노드 재귀 렌더링
                .toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mind Map')),
      body: Container(
        width: 3000, // 충분히 큰 값
        height: 3000, // 충분히 큰 값
        child: InteractiveViewer(
          boundaryMargin: EdgeInsets.all(double.infinity),
          minScale: 0.5,
          maxScale: 2.0,
          child: _buildMindMap(rootNode),
        ),
      ),
    );
  }
}
