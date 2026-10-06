import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickox_technician_app/features/home/screens/home_screen.dart';
import 'package:quickox_technician_app/features/services/screens/category_detail_screen.dart';
import 'package:quickox_technician_app/features/services/screens/home_service_categories_screen.dart';

void main() {
  testWidgets('HomeScreen renders image slider and verifies search bar is removed',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int navigatedTab = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          onNavigateTab: (index) => navigatedTab = index,
          autoPlaySlider: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify search bar text and search icon are REMOVED
    expect(find.text('Search electrical, AC, plumbing...'), findsNothing);
    expect(find.byIcon(Icons.search_rounded), findsNothing);

    // Verify promotional image slider slides exist
    expect(find.text('AC Deep Jet Wash & Gas Check'), findsOneWidget);
    expect(find.text('SUMMER SPECIAL • 20% OFF'), findsOneWidget);

    // Verify PageView is present for horizontal image slider
    expect(find.byType(PageView), findsOneWidget);

    // Verify Super App Verticals from explore_service.jsx are rendered
    expect(find.text('Home Service'), findsOneWidget);
    expect(find.text('Food Delivery'), findsOneWidget);
    expect(find.text('Medicine Delivery'), findsOneWidget);

    // Verify tapping View All on categories navigates to Services (tab 1)
    final viewAllFinders = find.text('View All');
    expect(viewAllFinders, findsWidgets);

    await tester.tap(viewAllFinders.first);
    expect(navigatedTab, 1);
  });

  testWidgets('HomeScreen renders dynamic services from Firebase with View All button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int navigatedTab = -1;

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          onNavigateTab: (index) => navigatedTab = index,
          autoPlaySlider: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Popular Services section header
    expect(find.text('Popular Services'), findsOneWidget);
    expect(find.text('Real-time verified pricing in Haldia'), findsOneWidget);

    // Verify services rendered (at least 3 or 4 services)
    final bookButtons = find.text('Book');
    expect(bookButtons, findsAtLeastNWidgets(3));

    // Scroll to and tap Book button (navigates to ServiceDetailOverviewScreen)
    await tester.ensureVisible(bookButtons.first);
    await tester.pumpAndSettle();
    await tester.tap(bookButtons.first);
    await tester.pumpAndSettle();
    // Return back to HomeScreen
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    // Verify View All Services Catalog CTA button at bottom
    final catalogCta = find.text('View All Services Catalog →');
    expect(catalogCta, findsOneWidget);
    await tester.ensureVisible(catalogCta);
    await tester.pumpAndSettle();
    await tester.tap(catalogCta);
    expect(navigatedTab, 1);
  });

  testWidgets('HomeScreen horizontal slider scrolls to next slide',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          onNavigateTab: (_) {},
          autoPlaySlider: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial slide
    expect(find.text('AC Deep Jet Wash & Gas Check'), findsOneWidget);

    // Drag PageView to the left to scroll horizontally
    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    // Verify next slide is displayed
    expect(find.text('Home Wiring & Electrical Audit'), findsOneWidget);
    expect(find.text('CERTIFIED EXPERTS'), findsOneWidget);
  });

  testWidgets('HomeScreen renders on small 360x640 screen without overflow',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          onNavigateTab: (_) {},
          autoPlaySlider: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Popular Services'), findsOneWidget);
    expect(find.byType(PageView), findsOneWidget);
  });

  testWidgets('Tapping Home Service opens HomeServiceCategoriesScreen',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          onNavigateTab: (_) {},
          autoPlaySlider: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final homeServiceItem = find.text('Home Service');
    expect(homeServiceItem, findsOneWidget);

    await tester.tap(homeServiceItem);
    await tester.pumpAndSettle();

    expect(find.byType(HomeServiceCategoriesScreen), findsOneWidget);
  });

  testWidgets('Tapping Popular category opens CategoryDetailScreen with category',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          onNavigateTab: (_) {},
          autoPlaySlider: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final acServiceItem = find.text('AC Service');
    expect(acServiceItem, findsOneWidget);

    await tester.tap(acServiceItem);
    await tester.pumpAndSettle();

    expect(find.byType(CategoryDetailScreen), findsOneWidget);
  });
}
