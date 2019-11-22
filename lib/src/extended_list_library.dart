typedef LastChildLayoutTypeBuilder = LastChildLayoutType Function(int index);

enum LastChildLayoutType {
  /// as default child
  none,

  /// follow max child trailing layout offset and layout with full cross axis extend
  /// last child as loadmore item/no more item in [GridView] and [WaterfallFlow]
  /// with full cross axis extend
  fullCrossAxisExtend,

  /// as foot at trailing and layout with full cross axis extend
  /// show no more item at trailing when children are not full of viewport
  /// if children is full of viewport, it's the same as fullCrossAxisExtend
  foot,
}

/// A delegate that controls the last child layout of the children within the [ExtendedGridView/ExtendedList/WaterfallFlow].
class ExtendedListDelegate {
  const ExtendedListDelegate({this.lastChildLayoutTypeBuilder});

  /// The builder to get layout type of last child
  final LastChildLayoutTypeBuilder lastChildLayoutTypeBuilder;
}
