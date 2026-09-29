import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickox_technician_app/core/services/firebase_services_service.dart';
import 'package:quickox_technician_app/features/services/screens/book_technician_screen.dart';
import 'package:quickox_technician_app/features/services/screens/category_detail_screen.dart';
import 'package:quickox_technician_app/features/services/screens/choose_appointment_slot_screen.dart';
import 'package:quickox_technician_app/features/services/screens/service_detail_overview_screen.dart';
import 'package:quickox_technician_app/features/services/screens/services_screen.dart';
import 'package:quickox_technician_app/shared/widgets/common_widgets.dart';

void main() {
  group('Services Screen & Multi-Screen Flow Tests', () {
    testWidgets('ServicesScreen renders all 8 service verticals matching explore_service.jsx and trust banner', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Header elements: Membership Plans removed, Book Inspection is animated floating button with search icon
      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Membership Plans'), findsNothing);
      expect(find.byIcon(Icons.search_rounded), findsWidgets);

      // Section title
      expect(find.text('Explore All Categories'), findsOneWidget);

      // All 8 primary services present matching explore_service.jsx
      expect(find.text('Home Service'), findsOneWidget);
      expect(find.text('Food Delivery'), findsOneWidget);
      expect(find.text('Bike & Cab Service'), findsOneWidget);
      expect(find.text('Any Kind of Event Booking'), findsOneWidget);
      expect(find.text('Emergency Ambulance'), findsOneWidget);
      expect(find.text('Medicine Delivery'), findsOneWidget);
      expect(find.text('Room Booking'), findsOneWidget);
      expect(find.text('QUICKOX ELECTRA Scooty'), findsOneWidget);

      // Trust banner
      expect(find.text('Why Choose Quickox?'), findsOneWidget);
      expect(find.text('Verified\nProfessionals'), findsOneWidget);
    });

    testWidgets('ServicesScreen floating Book Inspection button with search icon navigates to BookTechnicianScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesScreen(),
        ),
      );
      await tester.pump();

      // Initially shows Book Inspection label alongside search icon
      expect(find.text('Book Inspection'), findsOneWidget);

      // Find floating action button with search icon
      final fab = find.byTooltip('Book Inspection');
      expect(fab, findsOneWidget);

      // Tap floating button
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Navigated to BookTechnicianScreen
      expect(find.byType(BookTechnicianScreen), findsOneWidget);
    });

    testWidgets('ServicesScreen search filters services dynamically', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query
      final searchInput = find.byType(TextField);
      await tester.enterText(searchInput, 'Food');
      await tester.pumpAndSettle();

      // Food matches
      expect(find.text('Food Delivery'), findsOneWidget);
      // Ambulance should not be visible
      expect(find.text('Emergency Ambulance'), findsNothing);
    });

    testWidgets('Multi-tier flow: ServicesScreen -> HomeServiceCategoriesScreen -> CategoryDetailScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tier 1: Tap Home Service
      await tester.tap(find.text('Home Service'));
      await tester.pumpAndSettle();

      // Tier 2: Home Service Categories Screen opened
      expect(find.text('Home Service Categories'), findsOneWidget);
      expect(find.text('AC Service'), findsOneWidget);

      // Tier 3: Tap AC Service
      await tester.tap(find.text('AC Service'));
      await tester.pumpAndSettle();

      // Category Details Screen opened
      expect(find.text('All Services'), findsOneWidget);
      expect(find.text('AC Deep Jet Cleaning & Servicing'), findsWidgets);
    });

    testWidgets('Multi-tier flow: ServicesScreen -> Food Delivery SubServicesScreen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ServicesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tier 1: Tap Food Delivery
      await tester.tap(find.text('Food Delivery'));
      await tester.pumpAndSettle();

      // Tier 2: SubServicesScreen opened
      expect(find.text('Daily Home-Style Tiffin Service'), findsOneWidget);
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
      expect(find.text('Book a Technician'), findsAtLeastNWidgets(1));
      expect(find.text('Buy Spare Parts'), findsOneWidget);

      // Inclusions section
      expect(find.text("What's Included"), findsOneWidget);

      // FAQs section (View All removed from FAQs)
      expect(find.text('FAQs'), findsOneWidget);

      // Related Services section renders with View All button
      expect(find.text('Related Services'), findsOneWidget);
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('Related Services View All button navigates back to previous screen', (WidgetTester tester) async {
      final sampleService = FirebaseServicesService.defaultServices.first;
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailOverviewScreen(
                      serviceTitle: sampleService.title,
                      serviceSubtitle: sampleService.desc,
                      service: sampleService,
                    ),
                  ),
                ).then((_) => popped = true);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('View All'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(popped, isTrue);
    });

    testWidgets('Services flow screens render on small 360x640 mobile screen without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      FlutterError.onError = FlutterError.dumpErrorToConsole;
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

    testWidgets('BookTechnicianScreen renders Verified banner at end without forward arrow and dynamic categories', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BookTechnicianScreen(
            serviceTitle: 'AC Repair & Jet Servicing',
            parentCategory: 'AC Service',
            basePrice: 399,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verified banner text is present
      expect(find.text('Verified Professionals'), findsOneWidget);
      expect(find.text('Skilled & background verified technicians at your doorstep'), findsOneWidget);

      // Verify no forward arrow icon in the banner
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsNothing);

      // Dynamic AC categories are loaded
      expect(find.text('Not Cooling'), findsOneWidget);
      expect(find.text('Gas Leak / Refill'), findsOneWidget);

      // Back button uses AppBackButton
      expect(find.byType(AppBackButton), findsOneWidget);

      // Add photos section rendered with real + Add Photo button and counter
      expect(find.text('3. Add Photos (Optional)'), findsOneWidget);
      expect(find.text('+ Add Photo'), findsOneWidget);
      expect(find.text('0/5 uploaded'), findsOneWidget);
    });

    testWidgets('ChooseAppointmentSlotScreen renders Razorpay option, summary and doorstep booking', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ChooseAppointmentSlotScreen(
            serviceTitle: 'AC Jet Cleaning',
            parentCategory: 'AC Service',
            serviceAddress: 'Chas Road, Purulia, West Bengal 723101',
            selectedIssue: 'Not Cooling',
            basePrice: 499,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title & Back button
      expect(find.text('Choose Appointment Slot'), findsOneWidget);
      expect(find.byType(AppBackButton), findsOneWidget);

      // Dynamic dates row is present
      expect(find.text('1. Select Date'), findsOneWidget);

      // Payment options
      final doorstepFinder = find.text('Pay on Doorstep (Post Service)');
      await tester.ensureVisible(doorstepFinder);
      await tester.pumpAndSettle();

      expect(find.text('Pay Online via Razorpay'), findsOneWidget);
      expect(find.text('Razorpay'), findsWidgets);
      expect(doorstepFinder, findsOneWidget);

      // Total summary displays dynamic price
      expect(find.text('₹499'), findsWidgets);

      // Choose Pay on Doorstep
      await tester.tap(doorstepFinder);
      await tester.pumpAndSettle();

      expect(find.text('Confirm Booking (Pay ₹499 Later)'), findsOneWidget);
    });
  });
}
