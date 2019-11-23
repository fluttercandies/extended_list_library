import 'package:flutter/rendering.dart';
import "typedef.dart";

enum LastChildLayoutType {
  /// as default child
  none,

  /// follow max child trailing layout offset and layout with full cross axis extend
  /// last child as loadmore item/no more item in [ExtendedGridView] and [WaterfallFlow]
  /// with full cross axis extend
  fullCrossAxisExtend,

  /// as foot at trailing and layout with full cross axis extend
  /// show no more item at trailing when children are not full of viewport
  /// if children is full of viewport, it's the same as fullCrossAxisExtend
  foot,
}

/// A delegate that provides extensions within the [ExtendedGridView],[ExtendedList],[WaterfallFlow].
class ExtendedListDelegate {
  const ExtendedListDelegate({
    this.lastChildLayoutTypeBuilder,
    this.collectGarbage,
    this.viewportBuilder,
    this.closeToTrailing,
  });

  /// The builder to get layout type of last child
  /// Notice: it should only for last child
  final LastChildLayoutTypeBuilder lastChildLayoutTypeBuilder;

  /// Call when collect garbage, return garbage indexs to collect
  final CollectGarbage collectGarbage;

  /// The builder to get indexs in viewport
  final ViewportBuilder viewportBuilder;

  /// when reverse property of List is true, layout is as following.
  /// it likes chat list, and new session will insert to zero index
  /// but it's not right when items are not full of viewport.
  ///
  ///      trailing
  /// -----------------
  /// |               |
  /// |               |
  /// |     item2     |
  /// |     item1     |
  /// |     item0     |
  /// -----------------
  ///      leading
  ///
  /// to solve it, you could set closeToTrailing to true, layout is as following.
  /// support [ExtendedGridView],[ExtendedList],[WaterfallFlow]
  /// it works not only reverse is true.
  ///
  ///      trailing
  /// -----------------
  /// |     item2     |
  /// |     item1     |
  /// |     item0     |
  /// |               |
  /// |               |
  /// -----------------
  ///      leading
  ///
  final bool closeToTrailing;
}

/// minxin of extended list render
///
mixin ExtendedRenderObjectMixin on RenderSliverMultiBoxAdaptor {
  /// call ViewportBuilder if it's not null
  void callViewportBuilder({
    ViewportBuilder viewportBuilder,
    //ExtentList and GridView can't use paintExtentOf
    PaintExtentOf getPaintExtend,
  }) {
    if (viewportBuilder == null) return;

    int viewportFirstIndex = indexOf(firstChild);
    int viewportLastIndex = indexOf(lastChild);

    RenderBox viewportFirstChild = firstChild;
    while (childScrollOffset(viewportFirstChild) +
            (getPaintExtend != null
                ? getPaintExtend(viewportFirstChild)
                : paintExtentOf(viewportFirstChild)) <=
        constraints.scrollOffset) {
      viewportFirstChild = childAfter(viewportFirstChild);
    }
    viewportFirstIndex = indexOf(viewportFirstChild);

    RenderBox viewportLastChild = lastChild;
    while (childScrollOffset(viewportLastChild) >
        constraints.remainingPaintExtent + constraints.scrollOffset) {
      viewportLastChild = childBefore(viewportLastChild);
    }
    viewportLastIndex = indexOf(viewportLastChild);

    viewportBuilder(viewportFirstIndex, viewportLastIndex);
  }

  /// call CollectGarbage if it's not null
  void callCollectGarbage({
    CollectGarbage collectGarbage,
    int leadingGarbage,
    int trailingGarbage,
    int firstIndex,
    int targetLastIndex,
  }) {
    if (collectGarbage == null) return;

    List<int> garbages = [];
    firstIndex ??= indexOf(firstChild);
    targetLastIndex ??= indexOf(lastChild);
    for (var i = leadingGarbage; i > 0; i--) {
      garbages.add(firstIndex - i);
    }
    for (var i = 0; i < trailingGarbage; i++) {
      garbages.add(targetLastIndex + i);
    }
    if (garbages.length != 0) {
      //call collectGarbage
      collectGarbage.call(garbages);
    }
  }

  /// handle closeToTrailing at begin
  void handleCloseToTrailingBegin(bool closeToTrailing) {
    if (closeToTrailing) {
      RenderBox child = firstChild;
      SliverMultiBoxAdaptorParentData childParentData = child.parentData;
      if (childParentData.index == 0 && childParentData.layoutOffset != 0) {
        var distance = childParentData.layoutOffset;
        while (child != null) {
          childParentData = child.parentData;
          childParentData.layoutOffset -= distance;
          child = childAfter(child);
        }
      }
    }
  }

  /// handle closeToTrailing at end
  double handleCloseToTrailingEnd(
      bool closeToTrailing, double endScrollOffset) {
    if (closeToTrailing && endScrollOffset < constraints.remainingPaintExtent) {
      RenderBox child = firstChild;
      final distance = constraints.remainingPaintExtent - endScrollOffset;
      while (child != null) {
        final SliverMultiBoxAdaptorParentData childParentData =
            child.parentData;
        childParentData.layoutOffset += distance;
        child = childAfter(child);
      }
      return constraints.remainingPaintExtent;
    }
    return endScrollOffset;
  }
}
