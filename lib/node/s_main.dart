import 'package:flutter/material.dart';
import 'package:mind_map_app/note/m_note.dart';
import 'package:mind_map_app/note/storage_node.dart';

import 'm_node.dart';
import 'w_mindmap.dart';
import 'w_textfield.dart';

class MainScreen extends StatefulWidget {
  final Note note;

  MainScreen({required this.note});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late NodeModel rootNode;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.note.content);
    rootNode = parseTree(widget.note.title, widget.note.content);
  }

  // 확대된 뷰 상태
  String? expandedView; // 'textField' 또는 'mindMap', 기본값은 null
  bool flipMode = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final updatedNote = Note(
      id: widget.note.id,
      title: widget.note.title,
      content: _controller.text,
    );
    await NoteStorage.saveNote(updatedNote);
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
      rootNode = parseTree(widget.note.title, newText); // 노드 트리 업데이트
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
        rootNode = parseTree(widget.note.title, newText); // 노드 트리 업데이트
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

  Widget _buildTextFieldContainer(String rootName, int? maxLines) {
    return Stack(
      children: [
        Positioned.fill(
          child: TextFieldWidget(
            controller: _controller,
            focusNode: _focusNode,
            onNodeUpdated: (updatedNode) {
              setState(() {
                rootNode = updatedNode;
                _saveNote();
              });
            },
            onTabKeyPress: _increaseDepth,
            onShiftTabKeyPress: _decreaseDepth,
            maxLines: maxLines,
            rootName: rootName,
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
            minScale: 0.1,
            maxScale: 2.0,
            child: MindMapWidget(node: rootNode),
          ),
        ),
        Positioned(
          top: 8,
          right: 40,
          child: IconButton(
            icon: Icon(
              flipMode ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () => {
              setState(() {
                flipMode = !flipMode;
              })
            },
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
                    child: _buildTextFieldContainer(widget.note.title, 5),
                  ),
                  Expanded(
                    flex: 2,
                    child: _buildMindMapContainer(),
                  ),
                ],
              )
            : expandedView == 'textField'
                ? _buildTextFieldContainer(widget.note.title, null)
                : _buildMindMapContainer(),
      ),
    );
  }
}
