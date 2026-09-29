import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/firebase_membership_service.dart';
import '../../../shared/widgets/razorpay_webview_screen.dart';
import '../../navigation/main_navigation_screen.dart';

/// Data model representing a BHK-tailored membership plan tier
class MembershipPlanItem {
  final String id;
  final String name;
  final String bhk;
  final String subtext;
  final String inspection;
  final String visits;
  final bool acCovered;
  final bool roCovered;
  final int monthlyPrice;
  final int yearlyPrice;
  final bool isPopular;
  final String popularLabel;
  final String yearlyNote;
  final List<String> features;

  const MembershipPlanItem({
    required this.id,
    required this.name,
    required this.bhk,
    required this.subtext,
    required this.inspection,
    required this.visits,
    required this.acCovered,
    required this.roCovered,
    required this.monthlyPrice,
    required this.yearlyPrice,
    this.isPopular = false,
    this.popularLabel = 'Most Popular',
    required this.yearlyNote,
    required this.features,
  });

  /// Price calculation based on duration in months (1, 3, 6, 12)
  int calculateTotal(int months) {
    if (months == 12) {
      return yearlyPrice * 12;
    }
    return monthlyPrice * months;
  }

  /// Effective monthly rate for selected duration
  int effectiveMonthlyRate(int months) {
    if (months == 12) {
      return yearlyPrice;
    }
    return monthlyPrice;
  }

  /// Total regular cost without yearly discount
  int regularTotal(int months) {
    return monthlyPrice * months;
  }

  /// Savings amount when yearly billing is chosen
  int yearlySavings() {
    return (monthlyPrice * 12) - (yearlyPrice * 12);
  }
}

/// Coupon code model matching admin coupons manager
class MembershipCoupon {
  final String code;
  final int discountPercentage;
  final String description;
  final int minPlanPrice;

  const MembershipCoupon({
    required this.code,
    required this.discountPercentage,
    required this.description,
    this.minPlanPrice = 0,
  });
}

/// Membership & Subscription Plans Screen
/// Matches the web admin architecture (home-service_admin/src/pages/Membership.jsx):
/// - 11 BHK-tailored tiers (1 RK to 3 BHK and VIP Elite)
/// - Multi-Month duration calculator & simulator (1, 3, 6, 12 Months)
/// - BHK filter pill category selector
/// - Active membership banner & renewal flow
/// - Interactive subscription checkout with coupon application & payment simulation
class MembershipScreen extends StatefulWidget {
  final UserSubscription? initialActiveSubscription;
  const MembershipScreen({super.key, this.initialActiveSubscription});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final FirebaseMembershipService _firebaseService = FirebaseMembershipService();

  // Selected BHK filter: 'All', '1 RK', '1 BHK', '1.5 BHK', '2 BHK', '2.5 BHK', '3 BHK'
  String _selectedBhkFilter = 'All';

  // Active membership state loaded dynamically from Firestore
  UserSubscription? _activeSubscription;
  bool _isLoading = true;

  // Dynamic live data from Firebase Firestore `membership_config/prices` & `coupons`
  List<MembershipPlanItem> _plans = [];
  List<MembershipCoupon> _availableCoupons = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialActiveSubscription != null) {
      _activeSubscription = widget.initialActiveSubscription;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFirebaseData();
      }
    });
  }

  /// Realtime fetch from Firestore `membership_config/prices`, `coupons`, & `subscriptions`
  Future<void> _loadFirebaseData() async {
    setState(() => _isLoading = true);
    try {
      final user = AuthService.instance.currentUser;
      final results = await Future.wait([
        _firebaseService.fetchPlans(),
        _firebaseService.fetchCoupons(),
        _firebaseService.fetchActiveSubscription(user?.id, user?.phone),
      ]);
      if (mounted) {
        setState(() {
          _plans = results[0] as List<MembershipPlanItem>;
          _availableCoupons = results[1] as List<MembershipCoupon>;
          // Preserve initialActiveSubscription if live returns null (e.g. offline/testing)
          final liveSub = results[2] as UserSubscription?;
          if (liveSub != null || widget.initialActiveSubscription == null) {
            _activeSubscription = liveSub;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('[MembershipScreen] Sync error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<MembershipPlanItem> get _filteredPlans {
    if (_selectedBhkFilter == 'All') {
      return _plans;
    }
    return _plans.where((p) => p.bhk == _selectedBhkFilter).toList();
  }

  // ── Checkout & Subscription Bottom Sheet Flow ─────────────────────────────
  void _openCheckoutSheet(MembershipPlanItem plan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CheckoutSheet(
        plan: plan,
        initialMonths: 1,
        availableCoupons: _availableCoupons,
        onSubscribed: (planName, durationMonths, totalPaid, code, [paymentId, orderId]) {
          Navigator.pop(ctx);
          final user = AuthService.instance.currentUser;
          final customerName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Quickox Customer';
          final customerEmail = user?.email.isNotEmpty == true ? user!.email : 'customer@quickox.com';
          final customerPhone = user?.phone?.isNotEmpty == true ? user!.phone! : '+91 9876543210';
          final userUid = user?.id;

          // Persist subscription asynchronously to Firebase Firestore `subscriptions`
          _firebaseService.createSubscription(
            planId: plan.id,
            planName: planName,
            bhk: plan.bhk,
            durationMonths: durationMonths,
            totalPaid: totalPaid,
            couponCode: code,
            razorpayPaymentId: paymentId,
            razorpayOrderId: orderId,
            userId: userUid,
            userName: customerName,
            userPhone: customerPhone,
            userEmail: customerEmail,
          ).then((_) {
            if (mounted) _loadFirebaseData();
          });
          _showSuccessConfirmation(
            planName,
            durationMonths,
            totalPaid,
            code,
            paymentId: paymentId,
          );
        },
      ),
    );
  }

  // ── Success Confirmation Sheet ────────────────────────────────────────────
  void _showSuccessConfirmation(
    String planName,
    int durationMonths,
    int totalPaid,
    String couponCode, {
    String? paymentId,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF16A34A),
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Membership Activated!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You are now an active subscriber of $planName ($durationMonths Months). Zero labor charges and priority visits have been unlocked!',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _detailRow('Subscription ID', 'QX-MEM-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'),
                    const SizedBox(height: 8),
                    _detailRow('Total Paid', '₹$totalPaid'),
                    if (paymentId != null) ...[
                      const SizedBox(height: 8),
                      _detailRow('Razorpay Ref', paymentId, isHighlight: true),
                    ],
                    const SizedBox(height: 8),
                    _detailRow('Payment Status', 'Paid via Razorpay', isHighlight: true),
                    const SizedBox(height: 8),
                    _detailRow('Duration', '$durationMonths ${durationMonths == 1 ? "Month" : "Months"}'),
                    if (couponCode.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _detailRow('Coupon Applied', couponCode, isHighlight: true),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MainNavigationScreen(initialIndex: 3),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'View My Bookings',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isHighlight ? AppColors.primary : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ── Available Coupons Sheet ───────────────────────────────────────────────
  void _openCouponsSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Offers & Coupons',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._availableCoupons.map((coupon) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFBFDBFE),
                                  ),
                                ),
                                child: Text(
                                  coupon.code,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                coupon.description,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${coupon.discountPercentage}% OFF',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16A34A),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _plans.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Membership Plans',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              SizedBox(height: 16),
              Text(
                'Loading membership plans from Firestore...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Membership Plans',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.primary,
            ),
            tooltip: 'Available Coupons',
            onPressed: _openCouponsSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFirebaseData,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [


            // ── Active Subscription Status Card ──────────────────────────────
            if (_activeSubscription != null && _activeSubscription!.isActive) ...[
              _buildActiveMembershipHero(_activeSubscription!),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── BHK Category Filter Pills ─────────────────────────────────────
            _buildBhkFilterChips(),
            const SizedBox(height: AppSpacing.md),

            // ── Section Title & Plan Count ────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Membership Plans (${_filteredPlans.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Text(
                    'Save 20% on Yearly',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Plan Cards List or Empty State ────────────────────────────────
            if (_filteredPlans.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF94A3B8)),
                    const SizedBox(height: 10),
                    Text(
                      'No plans found for "$_selectedBhkFilter"',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Switch filters or pull down to refresh live plans from Firestore.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ..._filteredPlans.map(
                (plan) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _buildPlanCard(plan),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    ),
  );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  // ── Hero Banner: Real Active Membership Status ────────────────────────────
  Widget _buildActiveMembershipHero(UserSubscription sub) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0x3310B981),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: const Color(0x8010B981),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: Color(0xFF34D399),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'ACTIVE SUBSCRIBER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF34D399),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Expires in ${sub.daysRemaining} Days',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            sub.bhk.isNotEmpty ? '${sub.planName} — ${sub.bhk}' : sub.planName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Zero labor charge on all bookings • Valid until ${_formatDate(sub.endDate)}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),

          // Duration & Status Info Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Duration: ${sub.durationMonths} ${sub.durationMonths == 1 ? "Month" : "Months"}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
                Text(
                  'Paid ₹${sub.totalPaid}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF38BDF8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.bolt_rounded, size: 18),
                  label: const Text(
                    'Book Member Service',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationScreen(initialIndex: 1),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF475569)),
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  if (_plans.isNotEmpty) {
                    final target = _plans.firstWhere(
                      (p) => p.id == sub.planId,
                      orElse: () => _plans.first,
                    );
                    _openCheckoutSheet(target);
                  }
                },
                child: const Text(
                  'Renew',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




  // ── BHK Category Filter Chips ─────────────────────────────────────────────
  Widget _buildBhkFilterChips() {
    final bhkOptions = ['All', '1 RK', '1 BHK', '1.5 BHK', '2 BHK', '2.5 BHK', '3 BHK'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: bhkOptions.map((bhk) {
          final isSelected = _selectedBhkFilter == bhk;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                bhk == 'All' ? 'All BHKs' : bhk,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              showCheckmark: false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.full),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              onSelected: (_) => setState(() => _selectedBhkFilter = bhk),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Plan Card Anatomy ─────────────────────────────────────────────────────
  Widget _buildPlanCard(MembershipPlanItem plan) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.isPopular
              ? AppColors.primary
              : const Color(0xFFE2E8F0),
          width: plan.isPopular ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: plan.isPopular
                ? AppColors.primary.withValues(alpha: 0.08)
                : const Color(0x06000000),
            blurRadius: plan.isPopular ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Choice Tag
          if (plan.isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    plan.popularLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Plan Name & BHK Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        plan.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        plan.bhk,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  plan.subtext,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 14),

                // Pricing presentation
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '₹${plan.monthlyPrice}',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Text(
                          ' / month',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: Text(
                        'Yearly: ₹${plan.yearlyPrice}/mo',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                  ],
                ),

                // Yearly Savings Note (Green highlight)
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 12),
                  child: Text(
                    '⭐ ${plan.yearlyNote}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ),

                // Key Specs Pills (Inspections, Visits, AC, RO)
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _specBadge('🔍 ${plan.inspection}', const Color(0xFFEEF2FF), const Color(0xFF4F46E5)),
                    _specBadge('🛠️ ${plan.visits}', const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
                    _specBadge(
                      plan.acCovered ? '❄️ AC: Included ✅' : '❌ AC: No',
                      plan.acCovered ? const Color(0xFFEFF6FF) : const Color(0xFFFEF2F2),
                      plan.acCovered ? const Color(0xFF2563EB) : const Color(0xFFDC2626),
                    ),
                    _specBadge(
                      plan.roCovered ? '💧 RO: Included ✅' : '❌ RO: No',
                      plan.roCovered ? const Color(0xFFFAF5FF) : const Color(0xFFFEF2F2),
                      plan.roCovered ? const Color(0xFF9333EA) : const Color(0xFFDC2626),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),

                // Features Checklist
                ...plan.features.map((feat) {
                  final isExcluded = feat.contains('❌') || feat.toLowerCase().contains('not included');
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isExcluded
                              ? Icons.cancel_rounded
                              : Icons.check_circle_rounded,
                          size: 16,
                          color: isExcluded
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF10B981),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feat,
                            style: TextStyle(
                              fontSize: 13,
                              color: isExcluded
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF334155),
                              decoration: isExcluded
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Subscribe CTA Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: plan.isPopular
                          ? AppColors.primary
                          : const Color(0xFF0F172A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _openCheckoutSheet(plan),
                    child: const Text(
                      'View Plan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _specBadge(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ── Interactive Checkout & Coupon Application Sheet ─────────────────────────
class _CheckoutSheet extends StatefulWidget {
  final MembershipPlanItem plan;
  final int initialMonths;
  final List<MembershipCoupon> availableCoupons;
  final Function(String planName, int durationMonths, int totalPaid, String code,
      [String? paymentId, String? orderId]) onSubscribed;

  const _CheckoutSheet({
    required this.plan,
    required this.initialMonths,
    required this.availableCoupons,
    required this.onSubscribed,
  });

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  late int _months;
  final TextEditingController _couponController = TextEditingController();
  MembershipCoupon? _appliedCoupon;
  String _couponError = '';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _months = widget.initialMonths;
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCouponCode(String code) {
    final clean = code.trim().toUpperCase();
    final match = widget.availableCoupons.firstWhere(
      (c) => c.code.toUpperCase() == clean,
      orElse: () => const MembershipCoupon(
        code: '',
        discountPercentage: 0,
        description: '',
      ),
    );

    if (match.code.isNotEmpty) {
      setState(() {
        _appliedCoupon = match;
        _couponError = '';
        _couponController.text = match.code;
      });
    } else {
      setState(() {
        _appliedCoupon = null;
        _couponError = 'Invalid coupon code. Try QUICKOX20';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isYearly = _months == 12;
    final baseSubtotal = widget.plan.calculateTotal(_months);
    final couponDiscount = _appliedCoupon != null
        ? ((baseSubtotal * _appliedCoupon!.discountPercentage) / 100).round()
        : 0;
    final totalPayable = (baseSubtotal - couponDiscount).clamp(0, 999999);

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plan.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.plan.subtext,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.plan.bhk,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration selector with +/- stepper (1 to 12 Months)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Select Duration',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  if (_months == 12)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF86EFAC)),
                      ),
                      child: const Text(
                        'Save 20% on Yearly',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Stepper Row: [-] [Count Display] [+]
              Row(
                children: [
                  InkWell(
                    onTap: _months > 1
                        ? () => setState(() => _months--)
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _months > 1
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _months > 1
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.remove_rounded,
                        size: 22,
                        color: _months > 1
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: _months == 12
                            ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                            : AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _months == 12
                              ? const Color(0xFF16A34A).withValues(alpha: 0.4)
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_months ${_months == 1 ? "Month" : "Months"}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: _months == 12
                                  ? const Color(0xFF16A34A)
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _months == 12
                                ? 'Yearly Plan (Save 20%)'
                                : '₹${widget.plan.monthlyPrice} × $_months months',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                              color: _months == 12
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _months < 12
                        ? () => setState(() => _months++)
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 44,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _months < 12
                            ? const Color(0xFFF1F5F9)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _months < 12
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 22,
                        color: _months < 12
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quick Preset Chips (1 Mo, 3 Mo, 6 Mo, 12 Mo)
              Row(
                children: [1, 3, 6, 12].map((m) {
                  final isSel = _months == m;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(() => _months = m),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel
                                ? (m == 12
                                    ? const Color(0xFF16A34A)
                                    : AppColors.primary)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSel
                                  ? (m == 12
                                      ? const Color(0xFF16A34A)
                                      : AppColors.primary)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                m == 12 ? '⭐ 12 Mo' : '$m Mo',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isSel ? Colors.white : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Coupon Input Section (Clean single border, no double outlines)
              const Text(
                'Apply Promo Code',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextField(
                        controller: _couponController,
                        textCapitalization: TextCapitalization.characters,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter coupon (e.g. QUICKOX20)',
                          hintStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF94A3B8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 0),
                        minimumSize: const Size(80, 48),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _applyCouponCode(_couponController.text),
                      child: const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_couponError.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    _couponError,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              if (_appliedCoupon != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Color(0xFF16A34A),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Coupon "${_appliedCoupon!.code}" applied (${_appliedCoupon!.discountPercentage}% OFF)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Price Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _priceSummaryRow(
                      'Base Plan Rate',
                      '₹${isYearly ? widget.plan.yearlyPrice : widget.plan.monthlyPrice} / mo',
                    ),
                    const SizedBox(height: 6),
                    _priceSummaryRow(
                      'Duration Multiplier',
                      '$_months ${isYearly ? "Months (Yearly)" : "Months"}',
                    ),
                    const SizedBox(height: 6),
                    _priceSummaryRow('Subtotal', '₹$baseSubtotal'),
                    if (isYearly) ...[
                      const SizedBox(height: 6),
                      _priceSummaryRow(
                        'Yearly Savings (20%)',
                        '- ₹${widget.plan.yearlySavings()}',
                        isGreen: true,
                      ),
                    ],
                    if (_appliedCoupon != null) ...[
                      const SizedBox(height: 6),
                      _priceSummaryRow(
                        'Coupon Discount (${_appliedCoupon!.code})',
                        '- ₹$couponDiscount',
                        isGreen: true,
                      ),
                    ],
                    const SizedBox(height: 6),
                    _priceSummaryRow(
                      'Platform & Service Fee',
                      'FREE (₹0)',
                      isGreen: true,
                    ),
                    const Divider(height: 16, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Flexible(
                          child: Text(
                            'Total Payable',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '₹$totalPayable',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Proceed CTA button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isProcessing
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _isProcessing = true);
                          final subReferenceId =
                              'MEM_${widget.plan.id}_${DateTime.now().millisecondsSinceEpoch}';

                          final user = AuthService.instance.currentUser;
                          final customerName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Quickox Customer';
                          final customerEmail = user?.email.isNotEmpty == true ? user!.email : '';
                          final customerPhone = user?.phone?.isNotEmpty == true ? user!.phone! : '';
                          final userUid = user?.id;

                          final result = await RazorpayWebViewScreen.open(
                            context,
                            amount: totalPayable.toDouble(),
                            referenceType: 'MEMBERSHIP',
                            referenceId: subReferenceId,
                            title: '${widget.plan.name} (${widget.plan.bhk}) - $_months Months',
                            subtitle: 'Quickox Home Maintenance Membership',
                            customerName: customerName,
                            customerEmail: customerEmail,
                            customerPhone: customerPhone,
                            userFirebaseUid: userUid,
                            planId: widget.plan.id,
                            planAmount: totalPayable.toDouble(),
                            referralCode: _appliedCoupon?.code,
                          );

                          if (!mounted) return;
                          setState(() => _isProcessing = false);

                          if (result != null && result.isSuccess) {
                            widget.onSubscribed(
                              widget.plan.name,
                              _months,
                              totalPayable,
                              _appliedCoupon?.code ?? '',
                              result.paymentId,
                              result.orderId,
                            );
                          } else if (result != null &&
                              result.errorMessage != null &&
                              !result.isSuccess &&
                              result.errorMessage != 'Payment cancelled by user' &&
                              result.errorMessage != 'Payment cancelled') {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Payment not completed: ${result.errorMessage}'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  child: _isProcessing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Proceed & Pay ₹$totalPayable',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceSummaryRow(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isGreen ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
