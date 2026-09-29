import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickox_technician_app/core/services/firebase_services_service.dart';
import 'package:quickox_technician_app/features/services/screens/category_detail_screen.dart';
import 'package:quickox_technician_app/features/services/screens/service_detail_overview_screen.dart';
import 'package:quickox_technician_app/features/services/screens/services_screen.dart';

void main() {
  group('Services Screen & Multi-Screen Flow Tests', () {
    testWidgets('ServicesScreen renders header, search bar, categories list, and trust banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header elements
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Book Inspection'), findsOneWidget);
      expect(find.text('Membership Plans'), findsOneWidget);

      // Section title
      expect(find.text('Explore All Categories'), findsOneWidget);

      // Category cards present
      expect(find.text('AC Service'), findsOneWidget);
      expect(find.text('Electrical Services'), findsOneWidget);
      expect(find.text('Plumbing Services'), findsOneWidget);

      // Trust banner
      expect(find.text('Why Choose Quickox?'), findsOneWidget);
      expect(find.text('Verified\nProfessionals'), findsOneWidget);
    });

    testWidgets('ServicesScreen search filters category list dynamically', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query
      final searchInput = find.byType(TextField);
      await tester.enterText(searchInput, 'Plumbing');
      await tester.pumpAndSettle();

      // Plumbing matches
      expect(find.text('Plumbing Services'), findsOneWidget);
      // AC should not be visible
      expect(find.text('AC Service'), findsNothing);
    });

    testWidgets('CategoryDetailScreen renders frequency tabs, counter, and service cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryDetailScreen(
            categoryName: 'AC',
            headerTitle: 'AC Service & Repair',
            headerSubtitle: 'High pressure jet cleaning & repair',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title & subtitle
      expect(find.text('AC Service & Repair'), findsOneWidget);

      // Filter tabs
      expect(find.text('All Services'), findsOneWidget);
      expect(find.text('One-Time Service'), findsOneWidget);
      expect(find.text('Monthly Service'), findsOneWidget);

      // Cards rendered
      expect(find.text('AC Deep Jet Cleaning & Servicing'), findsWidgets);

      // Tap 'One-Time Service' filter tab
      await tester.tap(find.text('One-Time Service'));
      await tester.pumpAndSettle();
      expect(find.text('AC Deep Jet Cleaning & Servicing'), findsWidgets);
    });

    testWidgets('ServiceDetailOverviewScreen renders hero, stats, inclusions, FAQs, and buttons', (WidgetTester tester) async {
      final sampleService = FirebaseServicesService.defaultServices.first;

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailOverviewScreen(
            serviceTitle: sampleService.title,
            serviceSubtitle: sampleService.desc,
            service: sampleService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Hero title & price
      expect(find.text(sampleService.title), findsAtLeastNWidgets(1));
      expect(find.text(sampleService.price), findsAtLeastNWidgets(1));

      // Choose What You Need section
      expect(find.text('Choose What You Need'), findsOneWidget);
      expect(find.text('Book a Technician'), findsOneWidget);
      expect(find.text('Buy Spare Parts'), findsOneWidget);

      // Inclusions section
      expect(find.text("What's Included"), findsOneWidget);

      // FAQs section
      expect(find.text('FAQs'), findsOneWidget);
    });

    testWidgets('Services flow screens render on small 360x640 mobile screen without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // 1. ServicesScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 2. CategoryDetailScreen
      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryDetailScreen(
            categoryName: 'AC',
            headerTitle: 'AC Service & Repair',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // 3. ServiceDetailOverviewScreen
      await tester.pumpWidget(
        MaterialApp(
          home: ServiceDetailOverviewScreen(
            serviceTitle: 'AC Deep Jet Cleaning & Servicing',
            service: FirebaseServicesService.defaultServices.first,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
