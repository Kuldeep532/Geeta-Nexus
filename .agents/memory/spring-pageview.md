---
name: Spring physics for PageView
description: Custom ScrollPhysics subclass used for verse reader horizontal swipe.
---

## Rule
`SpringPageScrollPhysics` is a custom `ScrollPhysics` subclass with a SpringDescription (mass 60, stiffness 120, damping 18) that replaces the default clamping physics on the verse reader `PageView`. It gives a natural elastic snap and overscroll feel.

**Why:** Default `PageScrollPhysics` uses clamping which feels rigid on web. Spring physics provide tactile feedback consistent with the "spring physics" requirement in the spec. The physics also work correctly with screen-reader horizontal swipe gestures.

**How to apply:**
```dart
PageView.builder(
  physics: const SpringPageScrollPhysics(),
  ...
)
```
