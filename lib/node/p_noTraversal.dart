import 'package:flutter/widgets.dart';

class NoTraversalPolicy extends FocusTraversalPolicy {
  // @override
  // FocusNode? findFirstFocus(FocusScopeNode scope) => null;
  //
  // @override
  // FocusNode? findLastFocus(FocusScopeNode scope) => null;

  @override
  FocusNode? findNextFocus(FocusNode currentNode) => null;

  @override
  FocusNode? findPreviousFocus(FocusNode currentNode) => null;

  @override
  bool inDirection(FocusNode currentNode, TraversalDirection direction) {
    return false;
  }

  @override
  FocusNode? findFirstFocusInDirection(
      FocusNode currentNode, TraversalDirection direction) {
    // final nodes = currentNode.children;
    // return direction == TraversalDirection.down ? nodes.first : nodes.last;
  }

  @override
  Iterable<FocusNode> sortDescendants(
      Iterable<FocusNode> descendants, FocusNode currentNode) {
    throw UnimplementedError();
  }
}
