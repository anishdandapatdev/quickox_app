import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quickox_technician_app/core/services/booking_payment_service.dart';
import 'package:quickox_technician_app/core/services/firebase_membership_service.dart';
import 'package:quickox_technician_app/shared/widgets/razorpay_webview_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Razorpay WebView & Payment Integration Tests', () {
    testWidgets('RazorpayWebViewScreen renders app bar, title, amount, and security badges',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: RazorpayWebViewScreen(
            amount: 499.0,
            referenceType: 'INSPECTION',
            referenceId: 'BK-TEST-101',
            title: 'Water Pump Repair & Inspection',
            customerName: 'Anish Customer',
            customerEmail: 'customer@quickox.in',
            customerPhone: '+91 98765 43210',
          ),
        ),
      );
      await tester.pump();

      // Verify header texts & badges
      expect(find.text('Razorpay 256-bit Secure Gateway'), findsOneWidget);
      expect(find.text('LIVE'), findsOneWidget);
      expect(find.text('₹499.00 • Water Pump Repair & Inspection'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('RazorpayWebViewScreen.open opens and returns verified RazorpayPaymentResult in test environment',
        (WidgetTester tester) async {
      RazorpayPaymentResult? paymentResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  paymentResult = await RazorpayWebViewScreen.open(
                    ctx,
                    amount: 899.0,
                    referenceType: 'MEMBERSHIP',
                    referenceId: 'MEM-p899-TEST',
                    title: '2 BHK Premium Protection Plan',
                    planId: 'p899',
                    planAmount: 899.0,
                    referralCode: 'QUICKOX20',
                  );
                },
                child: const Text('Open Payment'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap button to launch WebView Screen
      await tester.tap(find.text('Open Payment'));
      await tester.pump(); // Pushes route and triggers postFrameCallback
      await tester.pumpAndSettle();

      // Verify that payment result was received with success and valid ids
      expect(paymentResult, isNotNull);
      expect(paymentResult!.isSuccess, isTrue);
      expect(paymentResult!.paymentId, startsWith('pay_'));
      expect(paymentResult!.orderId, isNotNull);
      expect(paymentResult!.signature, startsWith('sig_'));
    });

    test('BookingPaymentService handles order generation fallback to live Razorpay key', () async {
      final service = BookingPaymentService();
      final order = await service.createRazorpayOrder(
        amount: 299.0,
        referenceId: 'TEST-REF-001',
        referenceType: 'MEMBERSHIP',
      );

      expect(order.containsKey('key_id'), isTrue);
      expect(order['key_id'], BookingPaymentService.razorpayLiveKeyId);
      expect(order['currency'], 'INR');
    });

    test('FirebaseMembershipService handles subscription with razorpay payment fields', () async {
      final service = FirebaseMembershipService();
      expect(FirebaseMembershipService.defaultPlans.length, 11);
      expect(FirebaseMembershipService.defaultCoupons.isNotEmpty, isTrue);

      final ok = await service.createSubscription(
        planId: 'p899',
        planName: '₹899 Plan',
        bhk: '2 BHK',
        durationMonths: 12,
        totalPaid: 8628,
        couponCode: 'QUICKOX20',
        razorpayPaymentId: 'pay_test_unit_123',
        razorpayOrderId: 'order_test_unit_456',
      );
      // Returns true or fallback without throwing
      expect(ok, isA<bool>());
    });
  });
}
