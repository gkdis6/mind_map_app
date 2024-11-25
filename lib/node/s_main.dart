import 'package:flutter/material.dart';

import 'm_node.dart';
import 'w_mindmap.dart';
import 'w_textfield.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 초기 노드
  NodeModel rootNode = parseTree('Root Node');

  // 텍스트 컨트롤러
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  // 확대된 뷰 상태
  String? expandedView; // 'textField' 또는 'mindMap', 기본값은 null

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 들여쓰기 증가 (Tab)
  void _increaseDepth() {
    final cursorPosition = _controller.selection.base.offset;
    final lines = _controller.text.split('\n');
    int currentLineIndex = 0;
    int currentCharCount = 0;

    // 커서 위치에서 해당 라인 탐색
    for (int i = 0; i < lines.length; i++) {
      currentCharCount += lines[i].length + 1; // 줄 바꿈 포함
      if (currentCharCount > cursorPosition) {
        currentLineIndex = i;
        break;
      }
    }

    // 현재 줄 업데이트
    final updatedLine = '  ${lines[currentLineIndex]}'; // 들여쓰기 추가
    lines[currentLineIndex] = updatedLine;

    // 텍스트 갱신
    final newText = lines.join('\n');
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(
      offset: cursorPosition + 2,
    ); // 커서 위치 조정

    setState(() {
      rootNode = parseTree(newText); // 노드 트리 업데이트
    });
  }

  // 들여쓰기 감소 (Shift+Tab)
  void _decreaseDepth() {
    final cursorPosition = _controller.selection.base.offset;
    final lines = _controller.text.split('\n');
    int currentLineIndex = 0;
    int currentCharCount = 0;

    // 커서 위치에서 해당 라인 탐색
    for (int i = 0; i < lines.length; i++) {
      currentCharCount += lines[i].length + 1; // 줄 바꿈 포함
      if (currentCharCount > cursorPosition) {
        currentLineIndex = i;
        break;
      }
    }

    // 현재 줄 업데이트
    final currentLine = lines[currentLineIndex];
    if (currentLine.startsWith('  ')) {
      final updatedLine = currentLine.substring(2); // 들여쓰기 제거
      lines[currentLineIndex] = updatedLine;

      // 텍스트 갱신
      final newText = lines.join('\n');
      _controller.text = newText;
      _controller.selection = TextSelection.collapsed(
        offset: cursorPosition - 2,
      ); // 커서 위치 조정

      setState(() {
        rootNode = parseTree(newText); // 노드 트리 업데이트
      });
    }
  }

  void _toggleExpandedView(String view) {
    setState(() {
      if (expandedView == view) {
        expandedView = null; // 이미 확대된 뷰를 다시 축소
      } else {
        expandedView = view; // 새로운 뷰를 확대
      }
    });
  }

  Widget _buildTextFieldContainer() {
    return Stack(
      children: [
        Positioned.fill(
          child: TextFieldWidget(
            controller: _controller,
            focusNode: _focusNode,
            onNodeUpdated: (updatedNode) {
              setState(() {
                rootNode = updatedNode;
              });
            },
            onTabKeyPress: _increaseDepth,
            onShiftTabKeyPress: _decreaseDepth,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              expandedView == 'textField'
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
            ),
            onPressed: () => _toggleExpandedView('textField'),
          ),
        ),
      ],
    );
  }

  Widget _buildMindMapContainer() {
    return Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            constrained: false,
            minScale: 0.5,
            maxScale: 2.0,
            child: MindMapWidget(node: rootNode),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              expandedView == 'mindMap'
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen,
            ),
            onPressed: () => _toggleExpandedView('mindMap'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mind Map')),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: expandedView == null
            ? Column(
                children: [
                  Expanded(
                    flex: 1,
                    child: _buildTextFieldContainer(),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildMindMapContainer(),
                  ),
                ],
              )
            : expandedView == 'textField'
                ? _buildTextFieldContainer()
                : _buildMindMapContainer(),
      ),
    );
  }
}
