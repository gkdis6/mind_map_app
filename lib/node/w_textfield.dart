import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'm_node.dart';
import 'p_noTraversal.dart'; // parseTree 메서드와 NodeModel을 가져옵니다.

class TextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(NodeModel rootNode) onNodeUpdated;
  final void Function() onTabKeyPress;
  final void Function() onShiftTabKeyPress;

  const TextFieldWidget({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onNodeUpdated,
    required this.onTabKeyPress,
    required this.onShiftTabKeyPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: NoTraversalPolicy(),
      child: RawKeyboardListener(
        focusNode: focusNode,
        onKey: (RawKeyEvent event) {
          if (event.isKeyPressed(LogicalKeyboardKey.tab)) {
            event.isShiftPressed ? onShiftTabKeyPress() : onTabKeyPress();
            return;
          }
        },
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter Mind Map Structure',
          ),
          maxLines: 5,
          onChanged: (value) {
            if (value.trim() == '') return;
            onNodeUpdated(parseTree(value));
          },
        ),
      ),
    );
  }
}