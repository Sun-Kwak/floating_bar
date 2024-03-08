import 'dart:io';

import 'package:floating_bar/floating_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> _loadFont(String name, String path) async {
  final file = File(path);
  final bytes = await file.readAsBytes();

  final fontLoader = FontLoader(name);
  fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));

  await fontLoader.load();
}

void main() async {
  setUpAll(() async {
    await _loadFont(
      '.SF UI Text',
      'test/fonts/FontsFree-Net-sf-ui-text-regular-58646b56a688c.ttf',
    );
    await _loadFont(
      '.SF UI Display',
      'test/fonts/FontsFree-Net-SF-UI-Display-Regular-1.ttf',
    );
    await _loadFont(
      'MaterialIcons',
      'test/fonts/MaterialIcons-Regular.otf',
    );
  });
  const firstIcon = Icon(Icons.account_circle);
  const secondIcon = Icon(Icons.date_range);
  const thirdIcon = Icon(Icons.access_alarm);
  const fourthIcon = Icon(Icons.camera_enhance_rounded);
  const fifthIcon = Icon(Icons.adb_outlined);

  const iconList = [
    firstIcon,
    secondIcon,
    thirdIcon,
    fourthIcon,
    fifthIcon,
  ];

  // Test for FloatingBar initial look
  testGoldens('FloatingBar initial look', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532 - 47 * 3 - 34 * 3);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
      ..addScenario(
          'isOnLeft: true\ndefault initialYPositionPercentage: 0.8\ndefault floatingBarSize: 50',
          Container(
              color: Colors.red,
              width: 200,
              height: 200,
              child: FloatingBar(children: iconList)))
      ..addScenario(
          'isOnLeft: false\nif set up initialYPositionPercentage: 0\nif set up floatingBarSize: 100',
          Container(
              color: Colors.blue,
              width: 200,
              height: 200,
              child: FloatingBar(
                isOnLeft: false,
                initialYOffsetPercentage: 0,
                floatingBarSize: 100,
                children: iconList,
              )));
    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'floating_bar');

    debugDefaultTargetPlatformOverride = null;
  });

  // Test for onTap
  testGoldens('on Tap', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532 - 47 * 3 - 34 * 3);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final builder = GoldenBuilder.column()
      ..addScenario(
          'expansion when onTap',
          Container(
              color: Colors.amber,
              width: 300,
              height: 300,
              child: FloatingBar(children: iconList)));
    await tester.pumpWidgetBuilder(builder.build());
    await tester.tap(find.byIcon(Icons.chevron_right));
    await screenMatchesGolden(tester, 'floating_bar_onTap');

    debugDefaultTargetPlatformOverride = null;
  });

  // Test for Dragging
  testGoldens('on PanUpdating', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532 - 47 * 3 - 34 * 3);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final builder = GoldenBuilder.column()
      ..addScenario(
          'dragging when onPanUpdating',
          Container(
              color: Colors.grey,
              width: 300,
              height: 300,
              child: FloatingBar(children: iconList)));
    await tester.pumpWidgetBuilder(builder.build());
    final FloatingButtonsState state =
        tester.state(find.byType(FloatingButtons));
    state.setBoundaryForTest(const Offset(100, 100));
    await screenMatchesGolden(tester, 'floating_bar_onPanUpdated');

    debugDefaultTargetPlatformOverride = null;
  });

  // Test for collapsed UI changes
  testGoldens('FloatingBar  collapsed UI changes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532 - 47 * 3 - 34 * 3);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final builder = GoldenBuilder.grid(columns: 3, widthToHeightRatio: 1)
      ..addScenario(
          'arrow button color change to red(default : Colors.white)',
          Container(
              color: Colors.green,
              width: 100,
              height: 100,
              child: FloatingBar(
                  expansionButtonColor: Colors.red, children: iconList)))
      ..addScenario(
          'collapsedBackgroundColor change to red(default : Colors.white)',
          Container(
              color: const Color.fromARGB(255, 27, 44, 57),
              width: 100,
              height: 100,
              child: FloatingBar(
                collapsedBackgroundColor: Colors.red,
                children: iconList,
              )))
      ..addScenario(
          'collapsedOpacity change(default : 0.3)',
          Container(
              color: Colors.blue,
              width: 100,
              height: 100,
              child: FloatingBar(
                collapsedOpacity: 1,
                collapsedBackgroundColor: Colors.red,
                children: iconList,
              )));
    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'floating_bar_collapsed_UI_changes');

    debugDefaultTargetPlatformOverride = null;
  });

  // Test for expanded UI changes
  testGoldens('FloatingBar  expanded UI changes', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532 - 47 * 3 - 34 * 3);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final builder = GoldenBuilder.column()
      ..addScenario(
          'expanded background color change to red(default : Colors.white)\n'
          'expandedOpacity change(default : 0.3)',
          Container(
              color: Colors.white,
              width: 500,
              height: 350,
              child: FloatingBar(
                  expandedBackgroundColor: Colors.red,
                  expandedOpacity: 1,
                  children: iconList)));
    await tester.pumpWidgetBuilder(builder.build());
    await tester.tap(find.byIcon(Icons.chevron_right));
    await screenMatchesGolden(tester, 'floating_bar_expanded_UI_changes');

    debugDefaultTargetPlatformOverride = null;
  });

  // Test for expanded UI constraints
  testGoldens('FloatingBar  expanded UI constraints',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532 - 47 * 3 - 34 * 3);

    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

    final builder = GoldenBuilder.column()
      ..addScenario(
          'The expansionWidth is determined by parentSize and [expansionWidthPercentage] (default: 0.7).The width of each child in [children] is determined by the expansionWidth and length of [children]',
          Container(
              color: Colors.yellow,
              width: 500,
              height: 350,
              child: FloatingBar(
                  expansionWidthPercentage: 1,
                  childrenPadding: 10,
                  expandedBackgroundColor: Colors.blue,
                  children: [
                    Container(
                        width: 1000,
                        color: Colors.red,
                        child: const Center(child: Text('width:1000'))),
                    Container(
                        color: Colors.green,
                        child: const Center(child: Text('width: null'))),
                    Container(
                        color: Colors.blue,
                        child: const Center(child: Text('width:null'))),
                  ])));
    await tester.pumpWidgetBuilder(builder.build());
    await tester.tap(find.byIcon(Icons.chevron_right));
    await screenMatchesGolden(tester, 'floating_bar_expanded_UI_constraints');

    debugDefaultTargetPlatformOverride = null;
  });
}
