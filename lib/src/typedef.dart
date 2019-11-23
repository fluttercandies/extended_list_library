import 'package:flutter/rendering.dart';

import "extended_list_library.dart";

/// The builder to get layout type of last child
/// Notice: it should only for last child
typedef LastChildLayoutTypeBuilder = LastChildLayoutType Function(int index);

/// Return garbage indexs to collect
typedef CollectGarbage = void Function(List<int> garbages);

/// The builder to get indexs in viewport
typedef ViewportBuilder = void Function(int firstIndex, int lastIndex);

/// Return paint extent of child
typedef PaintExtentOf = double Function(RenderBox child);
