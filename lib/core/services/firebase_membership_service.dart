import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/membership/screens/membership_screen.dart';

/// Service connecting the Flutter app to Firebase Firestore for the 'home-service-haldia' project.
/// Mirrors web admin (home-service_admin/src/pages/Membership.jsx) and web client (home_service_web/src/features/plans/PlansPage.jsx).
class FirebaseMembershipService {
  static const String projectId = 'home-service-haldia';
  static const String apiKey = 'AIzaSyDJK_fcAvqE6SLJ6SXiVKdUUmWwn0r5epE';
  static const String firestoreBaseUrl =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  final http.Client _client;

  FirebaseMembershipService({http.Client? client})
      : _client = client ?? http.Client();

  /// Default 11 BHK fallback plans matching Handwriting Matrix & admin defaults
  static const List<MembershipPlanItem> defaultPlans = [
    MembershipPlanItem(
      id: 'p299',
      name: '₹299 Plan',
      bhk: '1 RK',
      subtext: '1 RK Essential Maintenance',
      inspection: '1 Home Inspection',
      visits: '3 Visits / month',
      acCovered: false,
      roCovered: false,
      monthlyPrice: 299,
      yearlyPrice: 239,
      yearlyNote: '₹239/mo on yearly billing (Save 20%)',
      features: [
        '1 Home Inspection',
        '3 Visits / month',
        'AC & RO service not included ❌',
        '30-day labor warranty',
      ],
    ),
    MembershipPlanItem(
      id: 'p399',
      name: '₹399 Plan',
      bhk: '1 BHK',
      subtext: '1 BHK Standard Care',
      inspection: '1 Home Inspection',
      visits: '3 Visits / month',
      acCovered: true,
      roCovered: false,
      monthlyPrice: 399,
      yearlyPrice: 319,
      yearlyNote: '₹319/mo on yearly billing (Save 20%)',
      features: [
        '1 Home Inspection',
        '3 Visits / month',
        'AC service included ✅',
        'RO service not included ❌',
        'Priority booking window',
      ],
    ),
    MembershipPlanItem(
      id: 'p499',
      name: '₹499 Plan',
      bhk: '1.5 BHK',
      subtext: '1.5 BHK Smart Coverage',
      inspection: '1 Home Inspection',
      visits: '3 Visits / month',
      acCovered: true,
      roCovered: false,
      monthlyPrice: 499,
      yearlyPrice: 399,
      yearlyNote: '₹399/mo on yearly billing (Save 20%)',
      features: [
        '1 Home Inspection',
        '3 Visits / month',
        'AC service included ✅',
        'RO service not included ❌',
        'Full labor charge waiver',
      ],
    ),
    MembershipPlanItem(
      id: 'p599',
      name: '₹599 Plan',
      bhk: '1 BHK',
      subtext: '1 BHK Advanced Care',
      inspection: '1 Home Inspection',
      visits: '3 Visits / month',
      acCovered: true,
      roCovered: true,
      monthlyPrice: 599,
      yearlyPrice: 479,
      yearlyNote: '₹479/mo on yearly billing (Save 20%)',
      features: [
        '1 Home Inspection',
        '3 Visits / month',
        'AC service included ✅',
        'RO service included 💧✅',
        'Dedicated support engineer',
      ],
    ),
    MembershipPlanItem(
      id: 'p699',
      name: '₹699 Plan',
      bhk: '2 BHK',
      subtext: '2 BHK Total Home Care',
      inspection: '1 Home Inspection',
      visits: '3 Visits / month',
      acCovered: true,
      roCovered: true,
      monthlyPrice: 699,
      yearlyPrice: 559,
      yearlyNote: '₹559/mo on yearly billing (Save 20%)',
      features: [
        '1 Home Inspection',
        '3 Visits / month',
        'Total home care coverage',
        'AC Service Included ✅',
        'RO Service Included ✅',
      ],
    ),
    MembershipPlanItem(
      id: 'p799',
      name: '₹799 Plan',
      bhk: '2.5 BHK',
      subtext: '2.5 BHK Family Shield',
      inspection: '1 Home Inspection',
      visits: '3 Visits / month',
      acCovered: true,
      roCovered: true,
      monthlyPrice: 799,
      yearlyPrice: 639,
      yearlyNote: '₹639/mo on yearly billing (Save 20%)',
      features: [
        '1 Home Inspection',
        '3 Visits / month',
        'AC Service Included ✅',
        'RO Service Included ✅',
        'Appliance health reports',
      ],
    ),
    MembershipPlanItem(
      id: 'p899',
      name: '₹899 Plan',
      bhk: '2 BHK',
      subtext: '2 BHK Premium Protection',
      inspection: '1 Home Inspection',
      visits: '3 Visits / month',
      acCovered: true,
      roCovered: true,
      monthlyPrice: 899,
      yearlyPrice: 719,
      isPopular: true,
      popularLabel: 'Most Popular',
      yearlyNote: '₹719/mo on yearly billing (Save 20%)',
      features: [
        '1 Home Inspection',
        '3 Visits / month',
        'AC Service Included ✅',
        'RO Service Included ✅',
        'Priority Customer Support',
        'Zero labor charge on all bookings',
      ],
    ),
    MembershipPlanItem(
      id: 'p999',
      name: '₹999 Plan',
      bhk: '3 BHK',
      subtext: '3 BHK Complete Care',
      inspection: '1 Home Inspection',
      visits: '3 Visits / month',
      acCovered: true,
      roCovered: true,
      monthlyPrice: 999,
      yearlyPrice: 799,
      yearlyNote: '₹799/mo on yearly billing (Save 20%)',
      features: [
        '1 Home Inspection',
        '3 Visits / month',
        'AC Service Included ✅',
        'RO Service Included ✅',
        'Priority Customer Support',
      ],
    ),
    MembershipPlanItem(
      id: 'p1199',
      name: '₹1,199 Plan',
      bhk: '2 BHK',
      subtext: '2 BHK + Add-on Service',
      inspection: '1 Home Inspection',
      visits: '3 Visits + 1 Add-on / mo',
      acCovered: true,
      roCovered: true,
      monthlyPrice: 1199,
      yearlyPrice: 959,
      yearlyNote: '₹959/mo on yearly billing (Save 20%)',
      features: [
        '1 Home Inspection',
        '3 Visits + 1 Add-on Service per month',
        'AC Service Included ✅',
        'RO Service Included ✅',
        'Priority Support',
      ],
    ),
    MembershipPlanItem(
      id: 'p1599',
      name: '₹1,599 Plan',
      bhk: '3 BHK',
      subtext: '3 BHK Total Home Care',
      inspection: 'Total Home Care (1 Inspection)',
      visits: '4 Visits / month',
      acCovered: true,
      roCovered: true,
      monthlyPrice: 1599,
      yearlyPrice: 1279,
      yearlyNote: '₹1,279/mo on yearly billing (Save 20%)',
      features: [
        'Total Home Care (1 Inspection)',
        '4 Visits / month',
        'One add-on service per month',
        'AC Service Included ✅',
        'RO Service Included ✅',
        'Express Service Booking',
      ],
    ),
    MembershipPlanItem(
      id: 'p2199',
      name: '₹2,199 Plan',
      bhk: '2 BHK',
      subtext: 'Ultimate VIP Care & 24x7 Support',
      inspection: '4 Home Inspections / Month',
      visits: '4 Maintenance Visits / Month',
      acCovered: true,
      roCovered: true,
      monthlyPrice: 2199,
      yearlyPrice: 1759,
      isPopular: true,
      popularLabel: 'Super Elite VIP',
      yearlyNote: '₹1,759/mo on yearly billing (Save 20%)',
      features: [
        'Total home care & VIP protection',
        '4 Home Inspections / Month',
        '4 Maintenance Visits / Month',
        'One add-on service included',
        'AC Service Included ✅',
        'RO Service Included ✅',
        '24x7 Emergency Support',
      ],
    ),
  ];

  static const List<MembershipCoupon> defaultCoupons = [
    MembershipCoupon(
      code: 'QUICKOX20',
      discountPercentage: 20,
      description: '20% OFF on all 3+ months care plans',
    ),
    MembershipCoupon(
      code: 'WELCOME50',
      discountPercentage: 50,
      description: '50% OFF first month subscription',
    ),
    MembershipCoupon(
      code: 'SUPERCARE',
      discountPercentage: 25,
      description: '25% OFF on 2 BHK & 3 BHK plans',
    ),
  ];

  /// Fetches real-time membership plans configuration from Firestore
  /// Document: `membership_config/prices`
  Future<List<MembershipPlanItem>> fetchPlans() async {
    try {
      final uri = Uri.parse('$firestoreBaseUrl/membership_config/prices');
      final response = await _client.get(uri).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final fields = data['fields'] as Map<String, dynamic>?;

        if (fields != null && fields.containsKey('plans')) {
          final plansMap = fields['plans']?['mapValue']?['fields'] as Map<String, dynamic>? ?? {};

          // Extract planOrder if present
          List<String> order = [];
          if (fields.containsKey('planOrder')) {
            final orderValues =
                fields['planOrder']?['arrayValue']?['values'] as List<dynamic>?;
            if (orderValues != null) {
              for (final v in orderValues) {
                if (v is Map && v.containsKey('stringValue')) {
                  order.add(v['stringValue'].toString());
                }
              }
            }
          }

          if (order.isEmpty) {
            order = plansMap.keys.toList();
          } else {
            // Append any remote plans not in order
            for (final k in plansMap.keys) {
              if (!order.contains(k)) order.add(k);
            }
          }

          final List<MembershipPlanItem> result = [];
          for (final id in order) {
            final raw = plansMap[id]?['mapValue']?['fields'] as Map<String, dynamic>?;
            final fallback = defaultPlans.firstWhere(
              (p) => p.id == id,
              orElse: () => defaultPlans.first,
            );

            if (raw != null) {
              result.add(_parsePlanItem(id, raw, fallback));
            } else if (defaultPlans.any((p) => p.id == id)) {
              result.add(fallback);
            }
          }

          if (result.isNotEmpty) {
            return result;
          }
        }
      }
    } catch (e) {
      debugPrint('[FirebaseMembershipService] Fetch plans failed ($e). Using cached defaults.');
    }

    return defaultPlans;
  }

  /// Parses Firestore REST map fields into a strongly typed `MembershipPlanItem`
  MembershipPlanItem _parsePlanItem(
    String id,
    Map<String, dynamic> f,
    MembershipPlanItem fallback,
  ) {
    String str(String key, String def) =>
        f[key]?['stringValue']?.toString() ?? def;

    int numVal(String key, int def) {
      final val = f[key];
      if (val == null) return def;
      if (val.containsKey('integerValue')) {
        return int.tryParse(val['integerValue'].toString()) ?? def;
      }
      if (val.containsKey('doubleValue')) {
        return (double.tryParse(val['doubleValue'].toString()) ?? def.toDouble()).round();
      }
      return def;
    }

    bool boolVal(String key, bool def) =>
        f[key]?['booleanValue'] as bool? ?? def;

    List<String> featuresList = [];
    if (f.containsKey('features')) {
      final arr = f['features']?['arrayValue']?['values'] as List<dynamic>?;
      if (arr != null) {
        for (final item in arr) {
          if (item is Map && item.containsKey('stringValue')) {
            featuresList.add(item['stringValue'].toString());
          }
        }
      }
    }

    if (featuresList.isEmpty) {
      featuresList = fallback.features;
    }

    final monthly = numVal('monthlyPrice', fallback.monthlyPrice);
    final yearly = numVal('yearlyPrice', fallback.yearlyPrice);

    return MembershipPlanItem(
      id: id,
      name: str('name', fallback.name),
      bhk: str('bhk', fallback.bhk),
      subtext: str('subtext', fallback.subtext),
      inspection: str('inspection', fallback.inspection),
      visits: str('visits', fallback.visits),
      acCovered: boolVal('acCovered', fallback.acCovered),
      roCovered: boolVal('roCovered', fallback.roCovered),
      monthlyPrice: monthly,
      yearlyPrice: yearly,
      isPopular: boolVal('isPopular', fallback.isPopular),
      popularLabel: str('popularLabel', fallback.popularLabel),
      yearlyNote: str('yearlyNote', '₹$yearly/mo on yearly billing (Save 20%)'),
      features: featuresList,
    );
  }

  /// Fetches coupons from Firestore `coupons` collection
  Future<List<MembershipCoupon>> fetchCoupons() async {
    try {
      final uri = Uri.parse('$firestoreBaseUrl/coupons');
      final response = await _client.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = data['documents'] as List<dynamic>?;

        if (docs != null && docs.isNotEmpty) {
          final List<MembershipCoupon> parsed = [];
          for (final doc in docs) {
            final f = doc['fields'] as Map<String, dynamic>?;
            if (f != null) {
              final active = f['active']?['booleanValue'] as bool? ?? true;
              if (active) {
                final code = f['code']?['stringValue']?.toString() ??
                    (doc['name'] as String).split('/').last;
                final discount = int.tryParse(
                        f['discountPercentage']?['integerValue']?.toString() ??
                            '20') ??
                    20;
                final minPrice = int.tryParse(
                        f['minPlanPrice']?['integerValue']?.toString() ??
                            '0') ??
                    0;
                final desc = f['description']?['stringValue']?.toString() ??
                    '$discount% OFF member coupon';

                parsed.add(MembershipCoupon(
                  code: code,
                  discountPercentage: discount,
                  description: desc,
                  minPlanPrice: minPrice,
                ));
              }
            }
          }
          if (parsed.isNotEmpty) return parsed;
        }
      }
    } catch (e) {
      debugPrint('[FirebaseMembershipService] Fetch coupons error: $e');
    }

    return defaultCoupons;
  }

  /// Submits an active membership purchase to Firebase Firestore `subscriptions`
  Future<bool> createSubscription({
    required String planId,
    required String planName,
    required String bhk,
    required int durationMonths,
    required int totalPaid,
    required String couponCode,
    String? razorpayPaymentId,
    String? razorpayOrderId,
    String? userId,
    String? userName,
    String? userPhone,
    String? userEmail,
  }) async {
    try {
      final subId = 'QX-MEM-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
      final now = DateTime.now().toUtc().toIso8601String();
      final expiry = DateTime.now()
          .add(Duration(days: durationMonths * 30))
          .toUtc()
          .toIso8601String();

      final uri = Uri.parse('$firestoreBaseUrl/subscriptions?documentId=$subId');
      final payload = {
        'fields': {
          'id': {'stringValue': subId},
          'transactionId': {'stringValue': razorpayPaymentId ?? subId},
          'planId': {'stringValue': planId},
          'planName': {'stringValue': planName},
          'bhk': {'stringValue': bhk},
          'billingCycle': {
            'stringValue': durationMonths >= 12 ? 'yearly' : 'monthly',
          },
          'durationMonths': {'integerValue': durationMonths.toString()},
          'monthlyPrice': {
            'integerValue': (totalPaid / (durationMonths > 0 ? durationMonths : 1)).round().toString(),
          },
          'subtotal': {'integerValue': totalPaid.toString()},
          'addonSubtotal': {'integerValue': '0'},
          'taxesAndFees': {'integerValue': '0'},
          'totalPaid': {'integerValue': totalPaid.toString()},
          'couponCode': {'stringValue': couponCode},
          'status': {'stringValue': 'active'},
          'startDate': {'timestampValue': now},
          'endDate': {'timestampValue': expiry},
          'createdAt': {'timestampValue': now},
          'userId': {'stringValue': userId ?? 'demo_user_123'},
          'userName': {'stringValue': userName ?? 'Quickox Customer'},
          'userPhone': {'stringValue': userPhone ?? '+91 9876543210'},
          'userEmail': {'stringValue': userEmail ?? 'customer@quickox.com'},
          'paymentStatus': {'stringValue': 'success'},
          'paymentMethod': {'stringValue': 'Razorpay / UPI'},
          if (razorpayPaymentId != null)
            'razorpayPaymentId': {'stringValue': razorpayPaymentId},
          if (razorpayOrderId != null)
            'razorpayOrderId': {'stringValue': razorpayOrderId},
        }
      };

      final res = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 6));

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      debugPrint('[FirebaseMembershipService] createSubscription exception: $e');
      return false;
    }
  }
}
