import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickox_technician_app/core/services/auth_service.dart';
import 'package:quickox_technician_app/core/theme/app_theme.dart';
import 'package:quickox_technician_app/features/auth/screens/login_screen.dart';
import 'package:quickox_technician_app/features/auth/screens/otp_verification_screen.dart';
import 'package:quickox_technician_app/features/auth/screens/profile_setup_screen.dart';
import 'package:quickox_technician_app/features/auth/screens/signup_screen.dart';
import 'package:quickox_technician_app/features/auth/widgets/rounded_password_input.dart';
import 'package:quickox_technician_app/features/auth/widgets/rounded_phone_input.dart';
import 'package:quickox_technician_app/features/auth/widgets/rounded_text_input.dart';
import 'package:quickox_technician_app/features/bookings/screens/bookings_screen.dart';
import 'package:quickox_technician_app/features/membership/screens/membership_screen.dart';
import 'package:quickox_technician_app/features/navigation/main_navigation_screen.dart';
import 'package:quickox_technician_app/features/navigation/widgets/modern_bottom_nav_bar.dart';
import 'package:quickox_technician_app/features/profile/screens/profile_screen.dart';
import 'package:quickox_technician_app/features/services/screens/shop_parts_screen.dart';
import 'package:quickox_technician_app/main.dart';

void main() {
  setUp(() {
    AuthService.instance.resetSession();
  });
  testWidgets('QuickoxApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuickoxApp());
    expect(find.byType(QuickoxApp), findsOneWidget);
  });

  testWidgets('ShopPartsScreen renders without error', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ShopPartsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Products & Spare Parts'), findsOneWidget);
    expect(find.text('AC Power Cord'), findsOneWidget);
  });

  testWidgets('ShopPartsScreen renders on small 360x640 screen without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ShopPartsScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Products & Spare Parts'), findsOneWidget);
    expect(find.text('AC Power Cord'), findsOneWidget);
  });

  testWidgets('MainNavigationScreen renders modern nav bar and switches tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final navBarFinder = find.byType(ModernBottomNavBar);
    expect(navBarFinder, findsOneWidget);

    // Verify nav items are present inside ModernBottomNavBar
    expect(find.descendant(of: navBarFinder, matching: find.text('Home')), findsOneWidget);
    expect(find.descendant(of: navBarFinder, matching: find.text('Services')), findsOneWidget);
    expect(find.descendant(of: navBarFinder, matching: find.text('Membership')), findsOneWidget);
    expect(find.descendant(of: navBarFinder, matching: find.text('Book')), findsOneWidget);
    expect(find.descendant(of: navBarFinder, matching: find.text('Profile')), findsOneWidget);

    // Verify badge count '1' on Book tab
    expect(find.descendant(of: navBarFinder, matching: find.text('1')), findsOneWidget);

    // Tap Services tab
    await tester.tap(find.descendant(of: navBarFinder, matching: find.text('Services')));
    await tester.pumpAndSettle();

    // Tap Profile tab
    await tester.tap(find.descendant(of: navBarFinder, matching: find.text('Profile')));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
  });

  testWidgets('MainNavigationScreen renders on small 360x640 screen without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigationScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ModernBottomNavBar), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  test('google.png asset is bundled and readable', () async {
    final byteData = await rootBundle.load('assets/images/google.png');
    expect(byteData.lengthInBytes, greaterThan(0));
  });

  testWidgets('LoginScreen renders phone, password, and Log In button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RoundedPhoneInput), findsOneWidget);
    expect(find.byType(RoundedPasswordInput), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);

    // Tap Log In with empty inputs and verify validation
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid 10-digit mobile number'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });

  testWidgets('LoginScreen Continue with Google logs in directly to MainNavigationScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Continue with Google
    final googleBtn = find.text('Continue with Google');
    expect(googleBtn, findsOneWidget);
    await tester.ensureVisible(googleBtn);
    await tester.tap(googleBtn);
    await tester.pumpAndSettle();

    // Choose Google account from GoogleAccountPickerModal
    final accountFinder = find.text('rahul.sharma@gmail.com');
    expect(accountFinder, findsOneWidget);
    await tester.tap(accountFinder);
    await tester.pump();

    // Verify it does NOT navigate to OtpVerificationScreen
    expect(find.byType(OtpVerificationScreen), findsNothing);

    // Let the authentication delay complete
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify user is directly in MainNavigationScreen
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(OtpVerificationScreen), findsNothing);
  });

  testWidgets('SignUpScreen Continue with Google logs in directly to MainNavigationScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Continue with Google
    final googleBtn = find.text('Continue with Google');
    expect(googleBtn, findsOneWidget);
    await tester.ensureVisible(googleBtn);
    await tester.tap(googleBtn);
    await tester.pumpAndSettle();

    // Choose Google account from GoogleAccountPickerModal
    final accountFinder = find.text('rahul.sharma@gmail.com');
    expect(accountFinder, findsOneWidget);
    await tester.tap(accountFinder);
    await tester.pump();

    // Verify it does NOT navigate to OtpVerificationScreen
    expect(find.byType(OtpVerificationScreen), findsNothing);

    // Let the authentication delay complete
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify user is directly in MainNavigationScreen
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(OtpVerificationScreen), findsNothing);
  });

  testWidgets('LoginScreen Continue with Google with new account navigates to ProfileSetupScreen, then home after setup', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Continue with Google
    final googleBtn = find.text('Continue with Google');
    expect(googleBtn, findsOneWidget);
    await tester.ensureVisible(googleBtn);
    await tester.tap(googleBtn);
    await tester.pumpAndSettle();

    // Choose Google account for Anish Kumar (new email not yet registered)
    final accountFinder = find.text('anish.quickox@gmail.com');
    expect(accountFinder, findsOneWidget);
    await tester.tap(accountFinder);
    await tester.pump();

    // Let authentication delay complete
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify user is navigated to ProfileSetupScreen
    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(find.byType(MainNavigationScreen), findsNothing);

    // Verify name and email are pre-filled
    expect(find.text('Anish Kumar'), findsOneWidget);
    expect(find.text('anish.quickox@gmail.com'), findsOneWidget);

    // Scroll down to complete button and tap it
    final completeBtn = find.text('Complete & Get Started');
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(completeBtn);
    await tester.pumpAndSettle();

    // Verify user is now on MainNavigationScreen
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('SignUpScreen Continue with Google with new account navigates to ProfileSetupScreen, then home after setup', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SignUpScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Continue with Google
    final googleBtn = find.text('Continue with Google');
    expect(googleBtn, findsOneWidget);
    await tester.ensureVisible(googleBtn);
    await tester.tap(googleBtn);
    await tester.pumpAndSettle();

    // Choose Google account for Anish Kumar
    final accountFinder = find.text('anish.quickox@gmail.com');
    expect(accountFinder, findsOneWidget);
    await tester.tap(accountFinder);
    await tester.pump();

    // Let authentication delay complete
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    // Verify user is navigated to ProfileSetupScreen
    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(find.byType(MainNavigationScreen), findsNothing);

    // Verify name and email are pre-filled
    expect(find.text('Anish Kumar'), findsOneWidget);
    expect(find.text('anish.quickox@gmail.com'), findsOneWidget);

    // Scroll down to complete button and tap it
    final completeBtn = find.text('Complete & Get Started');
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pumpAndSettle();
    await tester.tap(completeBtn);
    await tester.pumpAndSettle();

    // Verify user is now on MainNavigationScreen
    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });

  testWidgets('OtpVerificationScreen renders elements matching design mockup', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OtpVerificationScreen(phoneNumber: '+91 1234567890'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text("We've sent a 6-digit verification code to"), findsOneWidget);
    expect(find.text('+91 1234567890'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text("Didn't receive the code?"), findsOneWidget);
    expect(find.text('Resend Code'), findsOneWidget);
    expect(find.text('Verify OTP'), findsOneWidget);
    expect(find.text('By logging in I agree to the'), findsOneWidget);
    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(6));
  });

  testWidgets('OtpVerificationScreen renders on small 360x640 screen without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: OtpVerificationScreen(phoneNumber: '+91 1234567890'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enter OTP'), findsOneWidget);
    expect(find.text('Verify OTP'), findsOneWidget);
  });

  testWidgets('ProfileSetupScreen renders rounded input sections and validates', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileSetupScreen(phoneNumber: '+91 1234567890'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set Up Profile'), findsOneWidget);
    expect(find.byType(RoundedTextInput), findsNWidgets(3));
    expect(find.text('Current'), findsOneWidget);
    expect(find.text('Complete & Get Started'), findsOneWidget);

    // Tap Complete & Get Started with empty name and verify validation
    await tester.ensureVisible(find.text('Complete & Get Started'));
    await tester.tap(find.text('Complete & Get Started'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your full name'), findsOneWidget);
  });

  testWidgets('ProfileSetupScreen renders on small 360x640 screen without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileSetupScreen(phoneNumber: '+91 1234567890'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Set Up Profile'), findsOneWidget);
    expect(find.byType(RoundedTextInput), findsNWidgets(3));
  });

  testWidgets('ProfileScreen renders grouped sections matching mockup', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Manage your account and preferences'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Saved Addresses'), findsOneWidget);
    expect(find.text('Emergency Contacts'), findsOneWidget);
    expect(find.text('BOOKINGS & SERVICES'), findsOneWidget);
    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('MEMBERSHIP & OFFERS'), findsOneWidget);
    expect(find.text('Membership Plans'), findsOneWidget);
    expect(find.text('Offers'), findsOneWidget);
    expect(find.text('SUPPORT & SECURITY'), findsOneWidget);
    expect(find.text('Help Center'), findsOneWidget);
    expect(find.text('Privacy & Security'), findsOneWidget);
    expect(find.text('Account Deletion'), findsOneWidget);
    expect(find.text('APP SETTINGS'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });

  testWidgets('BookingsScreen renders Active and Completed tabs and switches correctly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BookingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Track your service orders and membership subscriptions'), findsOneWidget);
    expect(find.text('Services (4)'), findsOneWidget);
    expect(find.text('Membership Plans (2)'), findsOneWidget);

    // Tier 2 service filters
    expect(find.text('Active (1)'), findsOneWidget);
    expect(find.text('Completed (2)'), findsOneWidget);
    expect(find.text('Cancelled (1)'), findsOneWidget);

    // Active booking content
    expect(find.text('AC Deep Clean & Jet Service'), findsOneWidget);
    expect(find.text('Booking ID: QX-98241'), findsOneWidget);
    expect(find.text('ACTIVE'), findsOneWidget);
    expect(find.text('Confirmed'), findsOneWidget);
    expect(find.text('Need another service?'), findsOneWidget);

    // Tap View Details to open bottom sheet
    await tester.ensureVisible(find.text('View Details').first);
    await tester.tap(find.text('View Details').first);
    await tester.pumpAndSettle();
    expect(find.text('Booking Details'), findsOneWidget);
    expect(find.text('Start Service Verification Code'), findsOneWidget);
    expect(find.text('4821'), findsOneWidget);
    await tester.tap(find.text('Close Details'));
    await tester.pumpAndSettle();

    // Switch to Completed filter
    await tester.tap(find.text('Completed (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Switchboard & Socket Installation'), findsOneWidget);
    expect(find.text('Bathroom Tap Leakage Repair'), findsOneWidget);
    expect(find.text('Booking ID: QX-87119'), findsOneWidget);

    // Switch to Tier 1: Membership Plans
    await tester.tap(find.text('Membership Plans (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Active Plans (1)'), findsOneWidget);
    expect(find.text('Expired / History (1)'), findsOneWidget);
    expect(find.text('Quickox Plus Care Club'), findsOneWidget);
    expect(find.text('3 Months Plan'), findsOneWidget);
    expect(find.text('42 Days Remaining'), findsOneWidget);
    expect(find.text('Renew'), findsOneWidget);
  });

  testWidgets('BookingsScreen renders on small 360x640 screen without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BookingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('Services (4)'), findsOneWidget);
  });

  testWidgets('BookingsScreen search filters bookings dynamically across sections', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: BookingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap search icon beside My Bookings to open search field
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    // Verify search TextField renders in the rounded pill input
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Type "Jet" into search field
    await tester.enterText(searchField, 'Jet');
    await tester.pumpAndSettle();

    // Verify dynamic match count & filtered card
    expect(find.text('Services (1)'), findsOneWidget);
    expect(find.text('AC Deep Clean & Jet Service'), findsOneWidget);

    // Clear search using the close icon in the search box
    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();
    expect(find.text('Services (4)'), findsOneWidget);
  });

  testWidgets('MembershipScreen renders 11 BHK-tailored plans and active subscriber banner', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MembershipScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & Active Member Banner
    expect(find.widgetWithText(AppBar, 'Membership Plans'), findsOneWidget);
    expect(find.text('ACTIVE SUBSCRIBER'), findsOneWidget);
    expect(find.text('₹899 Plan — 2 BHK Premium Protection'), findsOneWidget);

    // Verify Duration Multiplier Selector
    expect(find.text('Select Duration & Multiplier'), findsOneWidget);
    expect(find.text('Save 20% on Yearly'), findsOneWidget);
    expect(find.text('⭐ 12 Mo'), findsOneWidget);

    // Verify BHK Filter Chips
    expect(find.text('All BHKs'), findsOneWidget);
    expect(find.text('1 RK'), findsWidgets);
    expect(find.text('2 BHK'), findsWidgets);

    // Verify Total Plan Count
    expect(find.text('Membership Plans (11)'), findsOneWidget);

    // Verify Plans Presence
    expect(find.text('₹299 Plan'), findsOneWidget);
    expect(find.text('1 RK Essential Maintenance'), findsOneWidget);
  });

  testWidgets('MembershipScreen filters by BHK and opens checkout bottom sheet', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MembershipScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Tap '1 RK' filter chip
    await tester.tap(find.widgetWithText(FilterChip, '1 RK'));
    await tester.pumpAndSettle();
    expect(find.text('Membership Plans (1)'), findsOneWidget);
    expect(find.text('₹299 Plan'), findsOneWidget);

    // Open Checkout Bottom Sheet
    await tester.ensureVisible(find.text('Choose Plan').first);
    await tester.tap(find.text('Choose Plan').first);
    await tester.pumpAndSettle();

    expect(find.text('Select Duration'), findsOneWidget);
    expect(find.text('Apply Promo Code'), findsOneWidget);
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Total Payable'), findsOneWidget);

    // Apply Coupon Code
    await tester.enterText(find.byType(TextField).last, 'QUICKOX20');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(find.text('Coupon "QUICKOX20" applied (20% OFF)'), findsOneWidget);

    // Close bottom sheet
    await tester.tap(find.byType(ElevatedButton).last); // Proceed & Pay
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    // Verify confirmation modal
    expect(find.text('Membership Activated!'), findsOneWidget);
  });

  testWidgets('MembershipScreen renders on small 360x640 screen without overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const MembershipScreen(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Membership Plans'), findsOneWidget);
    expect(find.text('Membership Plans (11)'), findsOneWidget);
  });
}

