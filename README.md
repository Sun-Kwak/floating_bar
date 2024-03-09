"When tapped, the children expand to be visible, draggable via drag, and upon onPanEnd, designed to reattach to the left or right based on the given screen center."

The [children] parameter provides a list of child widgets to include in the bar.
It can contain a maximum of five child widgets.

The [initialYOffsetPercentage] parameter represents the initial Y offset of the bar relative to the top of the parent widget.
Its value must be between 0 and 1.

The [expansionWidthPercentage] parameter determines the percentage of the parent widget's width occupied by the expanded bar.
It must be between 0 and 1.

The [collapsedOpacity] parameter determines the opacity of the bar when collapsed. It must be between 0 and 1.

The [expandedOpacity] parameter determines the opacity of the bar when expanded. It must be between 0 and 1.

Note: The width of each child in [children] is determined by the [expansionWidthPercentage] parameter, which calculates the available width based on the parent widget's width. Each child's width is then constrained by subtracting the padding between children ([childrenPadding]) and dividing by the number of children. Therefore, careful consideration should be given to the value of [childrenPadding].

Example:
If the parent widget's width is 500, and [expansionWidthPercentage] is 0.5, then the expansion width will be 250. With a [childrenPadding] of 10 and a list of 5 children, each child can have a maximum width of (250 - 10 \* 5) / 5 = 40.

#Basic UI and onPanEnd

![floating_bar](https://github.com/Sun-Kwak/floating_bar/assets/136423352/5d749cca-908e-4252-bd76-7294b4dd9d49)

#Expansion when onTap

![floating_bar_onTap](https://github.com/Sun-Kwak/floating_bar/assets/136423352/13f22b82-ada5-46e2-9270-7e1a2cb09699)

#Dragging when onPanupdate

![floating_bar_onPanUpdated](https://github.com/Sun-Kwak/floating_bar/assets/136423352/57b1aed5-f1cc-4764-8ffb-97bcfac201fb)

#collased floating bar UI changes

![floating_bar_collapsed_UI_changes](https://github.com/Sun-Kwak/floating_bar/assets/136423352/e5c4ad4d-1dbf-43a5-a3c8-5fda7dd3e885)

#expanded floating bar UI changes

![floating_bar_expanded_UI_changes](https://github.com/Sun-Kwak/floating_bar/assets/136423352/aeb22624-db33-4730-8522-f2893e9d9dd0)

#constraints depends on parent's size & parameter

![floating_bar_expanded_UI_constraints](https://github.com/Sun-Kwak/floating_bar/assets/136423352/e1e9e1b7-28a4-4191-8ddc-b4697a379dd2)
