library floating_bar;

import 'package:flutter/material.dart';

/// A widget representing a floating bar above its parent widget.
class FloatingBar extends StatefulWidget {
  /// List of child widgets to include in the bar.
  final List<Widget> children;

  /// Padding between child widgets.
  final double childrenPadding;

  /// Initial Y offset of the bar relative to the top of the parent widget (percentage).
  final double initialYOffsetPercentage;

  /// Size of the floating bar.
  final double floatingBarSize;

  /// Determines if the bar is initially positioned on the left side.
  final bool isOnLeft;

  /// Background color of the bar when collapsed.
  final Color collapsedBackgroundColor;

  /// Background color of the bar when expanded.
  final Color expandedBackgroundColor;

  /// Color of the expansion button.
  final Color expansionButtonColor;

  /// Percentage of the parent widget's width occupied by the expanded bar.
  final double expansionWidthPercentage;

  /// Opacity of the bar when collapsed.
  final double collapsedOpacity;

  /// Opacity of the bar when expanded.
  final double expandedOpacity;

  /// Constructs a [FloatingBar] widget.
  ///
  /// The [children] parameter provides a list of child widgets to include in the bar.
  /// It can contain a maximum of five child widgets.
  ///
  /// The [parentKey] parameter provides the GlobalKey of the parent widget where the bar will be displayed.
  ///
  /// The [initialYOffsetPercentage] parameter represents the initial Y offset of the bar relative to the top of the parent widget.
  /// Its value must be between 0 and 1.
  ///
  /// The [expansionWidthPercentage] parameter determines the percentage of the parent widget's width occupied by the expanded bar.
  /// It must be between 0 and 1.
  ///
  /// The [collapsedOpacity] parameter determines the opacity of the bar when collapsed. It must be between 0 and 1.
  ///
  /// The [expandedOpacity] parameter determines the opacity of the bar when expanded. It must be between 0 and 1.
  ///
  /// Note: The width of each child in [children] is determined by the [expansionWidthPercentage] parameter, which calculates the available width based on the parent widget's width. Each child's width is then constrained by subtracting the padding between children ([childrenPadding]) and dividing by the number of children. Therefore, careful consideration should be given to the value of [childrenPadding].
  ///
  /// Example:
  /// If the parent widget's width is 500, and [expansionWidthPercentage] is 0.5, then the expansion width will be 250. With a [childrenPadding] of 10 and a list of 5 children, each child can have a maximum width of (250 - 10 * 5) / 5 = 40.
  ///
  FloatingBar({
    required this.children,
    this.floatingBarSize = 50,
    this.isOnLeft = true,
    this.initialYOffsetPercentage = 0.8,
    this.collapsedBackgroundColor = Colors.white,
    this.expandedBackgroundColor = Colors.white,
    this.expansionButtonColor = Colors.white,
    this.expansionWidthPercentage = 0.7,
    this.collapsedOpacity = 0.3,
    this.expandedOpacity = 0.3,
    this.childrenPadding = 8,
    Key? key,
  }) : super(key: key) {
    if (children.length > 5) {
      throw ArgumentError('Floating list can only contain up to 5.');
    }
    assert(initialYOffsetPercentage >= 0 && initialYOffsetPercentage <= 1,
        'Initial Y offset must be between 0 and 1.');
    assert(expansionWidthPercentage >= 0 && expansionWidthPercentage <= 1,
        'Expansion width percentage must be between 0 and 1.');
    assert(collapsedOpacity >= 0 && collapsedOpacity <= 1,
        'Collapsed opacity must be between 0 and 1.');
    assert(expandedOpacity >= 0 && expandedOpacity <= 1,
        'Expanded opacity must be between 0 and 1.');
  }

  @override
  State<FloatingBar> createState() => _FloatingBarState();
}

class _FloatingBarState extends State<FloatingBar> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FloatingButtons(
          isOnLeft: widget.isOnLeft,
          expandedBackgroundColor: widget.expandedBackgroundColor,
          collapsedBackgroundColor: widget.collapsedBackgroundColor,
          childrenPadding: widget.childrenPadding,
          expandedOpacity: widget.expandedOpacity,
          collapsedOpacity: widget.collapsedOpacity,
          expansionButtonColor: widget.expansionButtonColor,
          constraints: constraints,
          expansionWidthPercentage: widget.expansionWidthPercentage,
          floatingBarSize: widget.floatingBarSize,
          initialYOffsetPercentage: widget.initialYOffsetPercentage,
          children: widget.children,
        );
      },
    );
  }
}

class FloatingButtons extends StatefulWidget {
  final BoxConstraints constraints;
  final bool isOnLeft;
  final Color expandedBackgroundColor;
  final Color collapsedBackgroundColor;
  final List<Widget> children;
  final double childrenPadding;
  final double expandedOpacity;
  final double collapsedOpacity;
  final Color expansionButtonColor;
  final double expansionWidthPercentage;
  final double floatingBarSize;
  final double initialYOffsetPercentage;

  const FloatingButtons({
    super.key,
    required this.isOnLeft,
    required this.expandedBackgroundColor,
    required this.collapsedBackgroundColor,
    required this.childrenPadding,
    required this.children,
    required this.expandedOpacity,
    required this.collapsedOpacity,
    required this.expansionButtonColor,
    required this.constraints,
    required this.expansionWidthPercentage,
    required this.floatingBarSize,
    required this.initialYOffsetPercentage,
  });

  @override
  State<FloatingButtons> createState() => FloatingButtonsState();
}

@visibleForTesting
class FloatingButtonsState extends State<FloatingButtons>
    with TickerProviderStateMixin {
  double _floatingBarSize = 0;
  double _fabYPosition = 0;
  double _fabXPosition = 0;
  bool _isOpen = false;
  bool _isPanUpdating = false;
  Size _parentSize = Size.zero;
  double _expansionWidth = 0;
  double leftX = 0;
  double rightX = 0;
  bool _isInitialBuild = true;
  late bool _isOnLeft;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setBoundary(context, widget.constraints);
      _animationController.forward();
    });
  }

  // Initialize the state of the widget.
  void _initializeState() {
    _isOnLeft = widget.isOnLeft;

    // Initialize the animation controller.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Add a listener to detect animation status changes.
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Update the initial build state when the first animation is completed.
        setState(() {
          _isInitialBuild = false;
        });
      }
    });
  }

// Set the positions for test code
  @visibleForTesting
  void setBoundaryForTest(Offset offset) {
    setState(() {
      _isPanUpdating = true;
      _fabXPosition = offset.dx;
      _fabYPosition = offset.dy;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Set the boundary for the widget based on its parent's size and other parameters.
  void _setBoundary(BuildContext context, BoxConstraints constraints) {
    // Calculate the parent size from constraints.
    _parentSize = Size(constraints.maxWidth, constraints.maxHeight);

    setState(() {
      // Calculate the expansion width based on the percentage provided.
      _expansionWidth = _parentSize.width * widget.expansionWidthPercentage;

      // Limit the floating bar size within the parent's width.
      _floatingBarSize = widget.floatingBarSize.clamp(0, _parentSize.width);

      // Calculate positions for left and right sides.
      leftX = -_floatingBarSize * 0.8 / 2;
      rightX = _parentSize.width - _floatingBarSize * 0.8 / 2;

      // Calculate the initial position of the floating action button (FAB).
      _fabYPosition = _parentSize.height * widget.initialYOffsetPercentage -
          (_floatingBarSize / 2);
      _fabXPosition = widget.isOnLeft ? leftX : rightX;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color color = _isOpen
        ? widget.expandedBackgroundColor
        : widget.collapsedBackgroundColor;
    return Stack(
      children: [
        AnimatedPositioned(
          duration: _isInitialBuild
              ? const Duration(milliseconds: 0)
              : const Duration(milliseconds: 500),
          curve: Curves.fastEaseInToSlowEaseOut,
          top: _fabYPosition,
          left: _fabXPosition,
          child: _isOpen ? _buildExpandedFab(color) : _buildCollapsedFab(color),
        )
      ],
    );
  }

  Widget _buildExpandedFab(Color color) {
    double width = (_expansionWidth -
            (widget.children.length * widget.childrenPadding) -
            (_floatingBarSize * 0.8 / 2)) /
        widget.children.length;
    return Container(
      height: _floatingBarSize,
      width: _expansionWidth,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: color.withOpacity(widget.expandedOpacity),
        borderRadius: BorderRadius.circular(_floatingBarSize * 0.2),
      ),
      child: Row(
        children: [
          Visibility(
            visible: _isOnLeft,
            child: _buildChevronButton(
              icon: Icons.chevron_left,
              onTap: () {
                setState(() {
                  _isOpen = false;
                  _fabXPosition = leftX;
                });
              },
              color: widget.expansionButtonColor,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: widget.children.map((child) {
                return Row(
                  children: [
                    SizedBox(width: widget.childrenPadding),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: width,
                          minWidth: width,
                          maxHeight: _floatingBarSize * 0.9),
                      child: child,
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          Visibility(
            visible: !_isOnLeft,
            child: _buildChevronButton(
              icon: Icons.chevron_right,
              onTap: () {
                setState(() {
                  _fabXPosition = rightX;
                  Future.delayed(const Duration(milliseconds: 300), () {
                    setState(() {
                      _isOpen = false;
                    });
                  });
                });
              },
              color: widget.expansionButtonColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChevronButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: _floatingBarSize * 0.8 / 2,
        color: color,
      ),
    );
  }

  Widget _buildCollapsedFab(Color color) {
    return GestureDetector(
      onTap: () {
        _handleOnTap();
      },
      onPanUpdate: (details) {
        _handlePanUpdate(details, widget.constraints);
      },
      onPanEnd: (details) {
        _handlePanEnd(details);
      },
      child: Container(
        width: _floatingBarSize * 0.8,
        height: _floatingBarSize,
        decoration: BoxDecoration(
          shape: !_isPanUpdating ? BoxShape.rectangle : BoxShape.circle,
          color: color.withOpacity(widget.collapsedOpacity),
          borderRadius: !_isPanUpdating
              ? BorderRadius.circular(_floatingBarSize * 0.2)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chevron_left,
              size: _floatingBarSize * 0.8 / 2,
              color: widget.expansionButtonColor,
            ),
            Icon(
              Icons.chevron_right,
              size: _floatingBarSize * 0.8 / 2,
              color: widget.expansionButtonColor,
            ),
          ],
        ),
      ),
    );
  }

// Handle tap events on the floating action button (FAB).
  void _handleOnTap() {
    setState(() {
      // Toggle the FAB position based on its current position.
      if (_fabXPosition == leftX) {
        _fabXPosition = 5;
        _isOpen = true;
      } else {
        _fabXPosition = _parentSize.width - _expansionWidth - 5;
        _isOpen = true;
      }
    });
  }

// Handle pan update events on the floating action button (FAB).
  void _handlePanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    _isPanUpdating = true;

    // Retrieve the render box of the parent widget.
    final RenderBox parentRenderBox = context.findRenderObject() as RenderBox;

    // If the parent render box exists, update the position of the FAB based on the drag details.
    // if (parentRenderBox != null) {
    final Offset localPosition =
        parentRenderBox.globalToLocal(details.globalPosition);

    double x = localPosition.dx - _floatingBarSize / 2;
    double y = localPosition.dy - _floatingBarSize / 2;

    // Adjust x-coordinate to stay within parentRenderBox width
    x = x.clamp(-_floatingBarSize / 2,
        parentRenderBox.size.width - _floatingBarSize / 2);

    // Adjust y-coordinate to stay within parentRenderBox height
    y = y.clamp(-_floatingBarSize / 2,
        parentRenderBox.size.height - _floatingBarSize / 2);

    setState(() {
      _fabYPosition = y;
      _fabXPosition = x;
    });
    // }
  }

// Handle pan end events on the floating action button (FAB).
  void _handlePanEnd(DragEndDetails details) {
    // Determine the final position of the FAB after the pan gesture ends.
    if (_fabXPosition + _floatingBarSize * 0.8 / 2 <= _parentSize.width / 2) {
      _fabXPosition = leftX;
      _isOnLeft = true;
    } else {
      _fabXPosition = rightX;
      _isOnLeft = false;
    }

    // Delay setting the pan update flag to false to allow time for visual feedback.
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _isPanUpdating = false;
      });
    });
  }
}
