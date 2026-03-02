<!-- Downloaded from: https://engineering.verygood.ventures/development/ui/layouts/llms.txt -->
<!-- Source: Layouts -->

# Layouts

The Flutter [documentation](https://docs.flutter.dev/ui/layout) provides a great introduction to widget layout. Here, we will cover more detailed use cases with `Row`, `Column`, and `Listview`, specifically focusing on how to best leverage the sizing capabilities of widgets. For this discussion, we will illustrate techniques by using the following box widget — a blue square with rounded edges and padding.

```dart
class Box extends StatelessWidget {
  const Box({super.key});
  \@override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      margin: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    );
  }
}
```

  The padding is added to assist with visualization as columns or rows will not
  add padding around or between children by default. In reality widgets will be
  right up next to each other.

## Why Indefinite Sizes

In an ideal world, every phone would have the same physical size and resolution. We could give each widget a width and a height that match the design, pixel for pixel. Unfortunately, there are countless number of screen sizes for all kinds of devices, so our code has to intelligently use the space to make designs looks consistent across multiple devices.

## Rows and Columns

`Row` and `Column` are the building blocks of all layouts and allow you to lay out a list of widgets in a particular direction — horizontally for rows and vertically for columns. Rows and columns provide three options to help with laying out across their children: `MainAxisSize`, `MainAxisAlignment`, and `CrossAxisAlignment`.

### `MainAxisSize`

`MainAxisSize` determines whether a `Row` or `Column` will fill the space in the main axis direction. By default, this is set to main `MainAxisSize.max`, meaning the height will be as large as possible (subject to height constraints). If set to `MainAxisSize.min`, the column height will shrink so as to only fit its children.

min:

  <div slot="left">

    ```dart
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

max:

  <div slot="left">

    ```dart
    Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

### `MainAxisAlignment`

`MainAxisAlignment` determines how to lay out the children along the primary axis (vertical for columns and horizontal for rows) when there is extra vertical space available. If there is no extra vertical space, this value will do nothing.

start:

  <div slot="left">
  
    ```dart
    Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

end:

  <div slot="left">

    ```dart
    Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

center:

  <div slot="left">

    ```dart
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

spaceAround:

  <div slot="left">

    ```dart
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

spaceBetween:

  <div slot="left">

    ```dart
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

spaceEvenly:

  <div slot="left">

    ```dart
    Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
  ```

  </div>
  

### `CrossAxisAlignment`

`CrossAxisAlignment` determines how to lay out widgets along the alternate axis (vertically for rows and horizontally for columns). The column's width is set to the size of the largest child (by default). If all the children are the same size and there are no width constraints, this value will do nothing. While `start`, `center`, and `end` will only adjust the position of the widget, `stretch` will adjust the size of the widgets in the column.

  For these examples, the width of the parent container is set larger than the
  children.

start:

  <div slot="left">

    ```dart
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

end:

  <div slot="left">

    ```dart
    Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

center:

  <div slot="left">

    ```dart
    Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

stretch:

  <div slot="left">

    ```dart
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

## `Expanded`, `Flexible`, and `Spacer`

Within a row or column, you may want different widgets to take up differing amounts of space. `Expanded`, `Flexible`, and `Spacer` widgets are useful for customizing the sizes and positioning of child widgets. These widgets will wrap one of the children in a `Row` or `Column`.

  Using `Expanded` and `Spacer` will override `MainAxisAlignment` and
  `MainAxisSize`, as the extra space will be taken by the expanded widgets
  (which expand to take up all the available space, naturally).

### `Expanded`

The `Expanded` widget will cause its child widget to expand to fill all the available space across the main axis of its parent widget.

  <div slot="left">

    ```dart
    Column(
      children: [
        Expanded(child: Box()),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

### `Spacer`

The `Spacer` widget creates an empty space that fills all the available space across the main axis of its parent widget.

  <div slot="left">

    ```dart
    Column(
      children: [
        Box(),
        Box(),
        Spacer(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

### `Flexible`

The `Flexible` widget is a more flexible (pun intended) expanded widget that lets you choose wether to fill the expandable space (or not).

  <div slot="left">

    ```dart
    Column(
      children: [
        Flexible(fit: FlexFit.loose, child: Box()),
        Flexible(fit: FlexFit.tight, child: Box()),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

### Flex Factor

`Expanded`, `Flexible`, and `Spacer` all have a `flex` factor parameter. The `flex` factor specifies a relative size compared to other widgets which also have a flex factor in the same row or column. By default, `Expanded`, `Flexible`, and `Spacer` each have a `flex` factor of `1.0`. If two widgets have a flex of 1, then they are they same size. If one has flex 4, then it will be 4 times bigger than the other. You can use flex factor to size widgets in the column in relation to each other. These widgets are meant used in a `Row` or `Column` so that all of the sizing will be done along the desired main axis.

without flex:

  <div slot="left">

    ```dart
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: Box()),
        Box(),
        Spacer(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

with flex:

  <div slot="left">

    ```dart
    Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(flex: 4, child: Box()),
        Box(),
        Spacer(flex: 1),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

## Rules for Parents and Children

To really understand how widgets are laid out, it helps to understand the relation between parents, their children, and the constraints and sizes set by each of them. The golden rule for layouts is as follows:

> Constraints go down. Sizes go up. Parent sets position. — Flutter, [Understanding Constraints](https://docs.flutter.dev/ui/layout/constraints)

### Constraints Go Down

Constraints that are set by the parent are enforced on the child widgets. If the parent sets a specific size, the child can only expand to fill the space set by the parent.

without constraints:

  <div slot="left">
  
    ```dart
    Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Box(),
          Box(),
          Box(),
          Box(),
        ],
      ),
    ),
    ```

  </div>
  

with constraints:

  <div slot="left">

    ```dart
    Container(
      width: 300,
      height: 500,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Box(),
          Box(),
          Box(),
          Box(),
        ],
      ),
    ),
    ```

  </div>
  

### Sizes Go up

Children set their sizes within parents, but they cannot override any constraints provided by their parent.

no size:

  <div slot="left">

    ```dart
    Container(
      child: Column(
        children: [
          Box(),
          Box(),
          Box(),
          Box(),
        ],
      ),
    ),
    ```

  </div>
  

children size:

  <div slot="left">

    ```dart
    Column(
      children: [
        Container(
          height: 100,
          width: 300,
          color: Colors.redAccent,
        ),
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

parents size:

  <div slot="left">

    ```dart
    Container(
      width: 200,
      child: Column(
        children: [
          Container(
            height: 100,
            width: 300,
            color: Colors.redAccent,
          ),
          Box(),
          Box(),
          Box(),
          Box(),
        ],
      ),
    ),
    ```

  </div>
  

### Parent Sets Position

Children do not know their absolute position since their position is set by the parent. Consider how the `Column` widget parameters `MainAxisAlignment` and `CrossAxisAlignment` set where the children are in the Column.

Flutter documentation also provides a number of detailed guides regarding constraints[^1] [^2] [^3].

## Wrapping and Scrolling

Sometimes a list of widgets will grow larger than the space that exists for it. When that happens inside a row or column, you will have _overflow_. The flutter library solves this by allowing you to make the items _wrap_ or _scroll_.

  Be careful when using widgets which try to fill all the available space, like
  `Expanded`, `Spacer`, etc, inside a `Wrap` or `Listview`. Since the `Wrap` and
  `Listview` don't constrain the sizes of their children (without additional
  configuration), you can end up with unbounded sizes and overflow errors.

### Wrap

The `Wrap` widget functions like a `Row` or `Column` depending on how you set the `direction` property. When the `Wrap` widget lays out its children widgets, the widgets will wrap to the next row or column when the end of one row or column has been reached.

The `Wrap` widget has several properties that are reminiscent of rows and columns. The `alignment` and `crossAxisAlignment` properties are equivalent to `mainAxisAlignment` and `crossAxisAlignment`, respectively. `Wrap` also provides extra properties to deal with additional rows that are created by the wrapping effect, like `runAlignment` and `runSpacing`.

### Listview

`Listview` will make a scrollable list for its children that scrolls in the direction specified by its `scrollDirection`. By default, the listview will expand in both the width and height directions, regardless of the specified direction `scrollDirection`.

The `shrinkwrap` parameter changes this: when true, the listview’s children will take up the least amount of space available as the listview will bound it's size in the primary direction to the size of those children. If the children take up more space than is available, the `shrinkwrap` property has no effect. The listview also provides many other properties to control scrolling and catching.

### SingleChildScrollView

A `SingleChildScrollView` will wrap a widget and make it scrollable. It is ideal to use when making other types of widgets (besides `Row` and `Column`) scrollable. When trying to render a list of children, however, it is usually more performant to use a listview over a `SingleChildScrollView`.

overflow:

  <div slot="left">

    ```dart
    Column(
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

Wrap:

  <div slot="left">

    ```dart
    Wrap(
      direction: Axis.vertical,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

Listview:

  <div slot="left">

    ```dart
    ListView(
      scrollDirection: Axis.vertical,
      children: [
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
        Box(),
      ],
    ),
    ```

  </div>
  

SingleChildScrollView:

  <div slot="left">

    ```dart
    SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Box(),
          Box(),
          Box(),
          Box(),
          Box(),
          Box(),
          Box(),
          Box(),
        ],
      ),
    )
    ```

  </div>
  

## Nesting

A layout will likely have many nested rows and columns. There is no limit to how many rows and columns can be nested, but it is important to consider the constraints that are present on the rows and columns when nesting these widgets. This is especially true when nesting scrollable widgets or using expanded widgets in a nested row or column.

  - Freely nest rows and columns (they are not expensive widgets) - On all rows
  and columns, consider what `mainAxisSize` should be (`min` or `max`) - Set
  `shrinkwrap` to `true` when nesting Listviews - Use widget inspector to
  visualize widget bounds to see how the widget hierarchy is being rendered -
  Consider if row or column might overflow on smaller devices

  - Don't put `Expanded` widgets inside of `Wrap`, `Listview`, and
  `SingleChildScrollView`, even if nested (unless the nested value has a fixed
  size) - Don't use `SingleChildScrollView` when it is possible to use a regular
  listview (for the sake of performance).

[^1]: [Understanding Constraints](https://docs.flutter.dev/ui/layout/constraints)

[^2]: [`Row` class](https://api.flutter.dev/flutter/widgets/Row-class.html)

[^3]: [`BoxConstraints` class](https://api.flutter.dev/flutter/rendering/BoxConstraints-class.html)