import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/booking_payment_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/razorpay_webview_screen.dart';
import '../../navigation/main_navigation_screen.dart';

enum PaymentMethodType {
  razorpay,
  doorstep,
}

/// Screen allowing the user to select an appointment date & time slot,
/// optionally request a top-rated technician, select payment method (Razorpay online vs Doorstep),
/// view dynamic booking summary, and complete payment with full Razorpay integration and
/// real-time Firestore sync matching the admin panel and web app.
class ChooseAppointmentSlotScreen extends StatefulWidget {
  const ChooseAppointmentSlotScreen({
    super.key,
    this.serviceTitle = 'Water Pump Installation, Uninstallation, Repair',
    this.parentCategory = 'Electronics Services',
    this.serviceAddress = 'Chas Road, Purulia, West Bengal 723101',
    this.selectedIssue = 'Power Failure',
    this.issueDesc = '',
    this.uploadedPhotos = const [],
    this.preferredDate,
    this.basePrice = 249,
  });

  final String serviceTitle;
  final String parentCategory;
  final String serviceAddress;
  final String selectedIssue;
  final String issueDesc;
  final List<String> uploadedPhotos;
  final DateTime? preferredDate;
  final int basePrice;

  @override
  State<ChooseAppointmentSlotScreen> createState() =>
      _ChooseAppointmentSlotScreenState();
}

class _ChooseAppointmentSlotScreenState
    extends State<ChooseAppointmentSlotScreen> {
  late final List<Map<String, String>> _dates;
  int _selectedDateIndex = 0;
  String _selectedSlot = '01:00 PM - 03:00 PM';
  bool _requestTopRatedTechnician = true;
  PaymentMethodType _selectedPaymentMethod = PaymentMethodType.razorpay;
  bool _isProcessing = false;

  final BookingPaymentService _paymentService = BookingPaymentService();

  final List<String> _morningSlots = const [
    '09:00 AM - 11:00 AM',
    '11:00 AM - 01:00 PM',
  ];

  final List<String> _afternoonSlots = const [
    '01:00 PM - 03:00 PM',
    '03:00 PM - 05:00 PM',
    '05:00 PM - 07:00 PM',
  ];

  final List<String> _eveningSlots = const [
    '07:00 PM - 09:00 PM',
    '09:00 PM - 11:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _dates = _generateDates();

    if (widget.preferredDate != null) {
      final preferredIso = _formatIso(widget.preferredDate!);
      final idx = _dates.indexWhere((d) => d['iso'] == preferredIso);
      if (idx != -1) {
        _selectedDateIndex = idx;
      }
    }
  }

  String _formatIso(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  List<Map<String, String>> _generateDates() {
    final now = DateTime.now();
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const fullDayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    const fullMonthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return List.generate(7, (i) {
      final dt = now.add(Duration(days: i));
      final day = dayNames[dt.weekday - 1];
      final fullDay = fullDayNames[dt.weekday - 1];
      final month = monthNames[dt.month - 1];
      final fullMonth = fullMonthNames[dt.month - 1];
      final dateStr = dt.day.toString();
      final fullStr = '$fullDay, $dateStr $fullMonth ${dt.year}';
      final iso = _formatIso(dt);

      return {
        'day': day,
        'date': dateStr,
        'month': month,
        'full': fullStr,
        'iso': iso,
      };
    });
  }

  Future<void> _handleProceed() async {
    if (_selectedPaymentMethod == PaymentMethodType.razorpay) {
      _openRazorpayCheckoutSheet();
    } else {
      _processDoorstepBooking();
    }
  }

  Future<void> _processDoorstepBooking() async {
    setState(() => _isProcessing = true);
    final bookingId = 'BK-${DateTime.now().millisecondsSinceEpoch}';
    final selectedDateStr = _dates[_selectedDateIndex]['full']!;

    final user = AuthService.instance.currentUser;
    final customerName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Quickox Customer';
    final customerEmail = user?.email.isNotEmpty == true ? user!.email : 'customer@quickox.com';
    final customerPhone = user?.phone?.isNotEmpty == true ? user!.phone! : '+91 9876543210';
    final userUid = user?.id;

    try {
      await _paymentService.saveBookingToFirestore(
        bookingId: bookingId,
        userId: userUid,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        serviceTitle: widget.serviceTitle,
        parentCategory: widget.parentCategory,
        selectedIssue: widget.selectedIssue,
        issueDesc: widget.issueDesc,
        serviceAddress: widget.serviceAddress,
        scheduledDate: selectedDateStr,
        scheduledSlot: _selectedSlot,
        amount: widget.basePrice,
        paymentMethod: 'pay_on_doorstep',
        paymentStatus: 'pending',
        requestTopRatedTechnician: _requestTopRatedTechnician,
        photos: widget.uploadedPhotos,
      );
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isProcessing = false);

    _showBookingConfirmedDialog(
      bookingId: bookingId,
      paymentMethod: 'Pay on Doorstep',
      paymentStatus: 'Pending (Pay Post Service)',
      isPaid: false,
    );
  }

  Future<void> _openRazorpayCheckoutSheet() async {
    final messenger = ScaffoldMessenger.of(context);
    final bookingId = 'BK-${DateTime.now().millisecondsSinceEpoch}';

    final user = AuthService.instance.currentUser;
    final customerName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Quickox Customer';
    final customerEmail = user?.email.isNotEmpty == true ? user!.email : '';
    final customerPhone = user?.phone?.isNotEmpty == true ? user!.phone! : '';
    final userUid = user?.id;

    final result = await RazorpayWebViewScreen.open(
      context,
      amount: widget.basePrice.toDouble(),
      referenceType: 'INSPECTION',
      referenceId: bookingId,
      title: widget.serviceTitle,
      subtitle: '${widget.selectedIssue} • ${widget.parentCategory}',
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      userFirebaseUid: userUid,
    );

    if (result != null && result.isSuccess) {
      final paymentId = result.paymentId ??
          'pay_${DateTime.now().millisecondsSinceEpoch}';
      final orderId = result.orderId ??
          'order_${DateTime.now().millisecondsSinceEpoch}';

      setState(() => _isProcessing = true);
      final selectedDateStr = _dates[_selectedDateIndex]['full']!;

      await _paymentService.saveBookingToFirestore(
        bookingId: bookingId,
        userId: userUid,
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        serviceTitle: widget.serviceTitle,
        parentCategory: widget.parentCategory,
        selectedIssue: widget.selectedIssue,
        issueDesc: widget.issueDesc,
        serviceAddress: widget.serviceAddress,
        scheduledDate: selectedDateStr,
        scheduledSlot: _selectedSlot,
        amount: widget.basePrice,
        paymentMethod: 'razorpay',
        paymentStatus: 'paid',
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        requestTopRatedTechnician: _requestTopRatedTechnician,
        photos: widget.uploadedPhotos,
      );

      if (!mounted) return;
      setState(() => _isProcessing = false);

      _showBookingConfirmedDialog(
        bookingId: bookingId,
        paymentMethod: 'Razorpay Online',
        paymentStatus: 'Paid Successfully',
        razorpayPaymentId: paymentId,
        isPaid: true,
      );
    } else if (result != null &&
        result.errorMessage != null &&
        !result.isSuccess &&
        result.errorMessage != 'Payment cancelled by user' &&
        result.errorMessage != 'Payment cancelled') {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Payment not completed: ${result.errorMessage}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showBookingConfirmedDialog({
    required String bookingId,
    required String paymentMethod,
    required String paymentStatus,
    String? razorpayPaymentId,
    required bool isPaid,
  }) {
    final selectedDateStr = _dates[_selectedDateIndex]['full']!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF16A34A),
                size: 48,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              isPaid ? 'Payment Confirmed & Booked!' : 'Appointment Confirmed!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Your service for "${widget.serviceTitle}" is confirmed for $selectedDateStr at $_selectedSlot.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF64748B),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),

            // Reference & Payment Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Booking ID',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        bookingId,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  if (razorpayPaymentId != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Razorpay Ref',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          razorpayPaymentId,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment Status',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        paymentStatus,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isPaid
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '₹${widget.basePrice}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Technician Assigned Note
            if (_requestTopRatedTechnician)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_pin_circle_rounded,
                        size: 16, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rohit Kumar assigned • Doorstep inspection included',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 18),
            // Primary action: View My Bookings (Index 3)
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                label: const Text(
                  'View My Bookings',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialIndex: 3),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Secondary action: Back to Home (Index 0)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigationScreen(initialIndex: 0),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Back to Home',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── Scrollable Body ─────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // ── Header: Back button + Title & Subtitle ──────────────
                    _buildHeader(context),

                    const SizedBox(height: 14),

                    // ── Trust Badges Row ────────────────────────────────────
                    _buildTrustBadgesRow(),

                    const SizedBox(height: 20),

                    // ── 1. Select Date ──────────────────────────────────────
                    _buildSelectDateSection(),

                    const SizedBox(height: 22),

                    // ── 2. Select Time Slot ─────────────────────────────────
                    _buildSelectTimeSlotSection(),

                    const SizedBox(height: 22),

                    // ── 3. Prefer a Top-Rated Technician? ───────────────────
                    _buildTopRatedTechnicianSection(),

                    const SizedBox(height: 22),

                    // ── 4. Select Payment Method (Razorpay vs Doorstep) ─────
                    _buildPaymentMethodSection(),

                    const SizedBox(height: 22),

                    // ── Booking Summary Card ────────────────────────────────
                    _buildBookingSummaryCard(),

                    const SizedBox(height: 16),

                    // ── What's Included Box ─────────────────────────────────
                    _buildWhatsIncludedBox(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Sticky Bottom Action Bar ────────────────────────────────────
            _buildStickyBottomBar(),
          ],
        ),
      ),
    );
  }

  // ── Header Widget ─────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppBackButton(
          onTap: () => Navigator.pop(context),
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Choose Appointment Slot',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Select a convenient date and time for your home visit.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40), // Balance AppBackButton
      ],
    );
  }

  // ── Trust Badges Row ──────────────────────────────────────────────────────

  Widget _buildTrustBadgesRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MiniBadge(
            icon: Icons.verified_user_rounded,
            title: 'Verified\nProfessionals',
          ),
          _MiniBadge(
            icon: Icons.access_time_rounded,
            title: 'On-Time\nService',
          ),
          _MiniBadge(
            icon: Icons.shield_outlined,
            title: 'Up to 30 Days\nWarranty',
          ),
          _MiniBadge(
            icon: Icons.lock_outline_rounded,
            title: 'Secure & Safe',
          ),
        ],
      ),
    );
  }

  // ── 1. Select Date Section ────────────────────────────────────────────────

  Widget _buildSelectDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Select Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // Horizontal Date Cards List
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_dates.length, (index) {
              final d = _dates[index];
              final isSelected = _selectedDateIndex == index;

              return Padding(
                padding:
                    EdgeInsets.only(right: index < _dates.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = index),
                  child: Container(
                    width: 52,
                    height: 68,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                d['day']!,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                d['date']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? const Color(0xFF1E3A8A)
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                d['month']!,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 13,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),

        // Selected Date Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDCFCE7)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Selected Date: ${_dates[_selectedDateIndex]['full']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 2. Select Time Slot Section ───────────────────────────────────────────

  Widget _buildSelectTimeSlotSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Select Time Slot',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // Morning Slots
        _buildSlotGroup(
          emoji: '☀️',
          label: 'MORNING SLOTS (9 AM - 1 PM)',
          slots: _morningSlots,
        ),
        const SizedBox(height: 12),

        // Afternoon Slots
        _buildSlotGroup(
          emoji: '⛅',
          label: 'AFTERNOON SLOTS (1 PM - 7 PM)',
          slots: _afternoonSlots,
        ),
        const SizedBox(height: 12),

        // Evening Slots
        _buildSlotGroup(
          emoji: '🌙',
          label: 'EVENING SLOTS (7 PM - 11 PM)',
          slots: _eveningSlots,
        ),
        const SizedBox(height: 12),

        // Flexibility Info Box
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Flexibility: You can reschedule or cancel your appointment free of charge up to 2 hours before the scheduled time slot.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF1E3A8A),
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlotGroup({
    required String emoji,
    required String label,
    required List<String> slots,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: slots.map((slot) {
            final isSelected = _selectedSlot == slot;
            return GestureDetector(
              onTap: () => setState(() => _selectedSlot = slot),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFF1E293B),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── 3. Prefer a Top-Rated Technician? ─────────────────────────────────────

  Widget _buildTopRatedTechnicianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. Prefer a Top-Rated Technician? (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
          ),
          child: Row(
            children: [
              // Technician Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Image.asset(
                  AppAssets.technicianRohit,
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => Image.asset(
                    AppAssets.technicianAvatar,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e2, s2) => Container(
                      width: 46,
                      height: 46,
                      color: const Color(0xFFEFF6FF),
                      child: const Icon(Icons.person, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Rohit Kumar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Top Rated',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Row(
                      children: [
                        Icon(Icons.star_rounded,
                            size: 13, color: Color(0xFFF59E0B)),
                        SizedBox(width: 2),
                        Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD97706),
                          ),
                        ),
                        SizedBox(width: 3),
                        Text(
                          '(450+ verified jobs)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      '8 Years Certified Experience',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Request Button / Checkbox
              InkWell(
                onTap: () {
                  setState(() {
                    _requestTopRatedTechnician = !_requestTopRatedTechnician;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: _requestTopRatedTechnician
                        ? const Color(0xFFEFF6FF)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _requestTopRatedTechnician
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _requestTopRatedTechnician
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 16,
                        color: _requestTopRatedTechnician
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Request This\nTechnician',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: _requestTopRatedTechnician
                              ? const Color(0xFF1E3A8A)
                              : const Color(0xFF475569),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 4. Select Payment Method Section ──────────────────────────────────────

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Select Payment Method',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // Option 1: Razorpay Online (Instant, Cards, UPI, Netbanking)
        GestureDetector(
          onTap: () => setState(
              () => _selectedPaymentMethod = PaymentMethodType.razorpay),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == PaymentMethodType.razorpay
                  ? const Color(0xFFEFF6FF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedPaymentMethod == PaymentMethodType.razorpay
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
                width:
                    _selectedPaymentMethod == PaymentMethodType.razorpay ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _RadioCircle(
                  isSelected:
                      _selectedPaymentMethod == PaymentMethodType.razorpay,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Pay Online via Razorpay',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'RECOMMENDED',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'UPI (Google Pay, PhonePe, Paytm), Cards, Net Banking',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C2340),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Razorpay',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Option 2: Pay on Doorstep (Post Service)
        GestureDetector(
          onTap: () => setState(
              () => _selectedPaymentMethod = PaymentMethodType.doorstep),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _selectedPaymentMethod == PaymentMethodType.doorstep
                  ? const Color(0xFFEFF6FF)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedPaymentMethod == PaymentMethodType.doorstep
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
                width:
                    _selectedPaymentMethod == PaymentMethodType.doorstep ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _RadioCircle(
                  isSelected:
                      _selectedPaymentMethod == PaymentMethodType.doorstep,
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pay on Doorstep (Post Service)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Pay cash or UPI directly to technician after satisfaction',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.handshake_outlined,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Booking Summary Card ──────────────────────────────────────────────────

  Widget _buildBookingSummaryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 18,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 8),
              Text(
                'Booking Summary',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Service Item Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  size: 18,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.serviceTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${widget.parentCategory} • ${widget.selectedIssue}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Details Table
          _buildSummaryLine(
            'Selected Date',
            _dates[_selectedDateIndex]['full']!,
          ),
          const SizedBox(height: 6),
          _buildSummaryLine('Time Slot', _selectedSlot),
          const SizedBox(height: 6),
          _buildSummaryLine('Issue Category', widget.selectedIssue),
          const SizedBox(height: 6),
          _buildSummaryLine(
            'Inspection / Visit Charge',
            'FREE',
            isGreen: true,
          ),
          const SizedBox(height: 6),
          _buildSummaryLine('Estimated Service Base', '₹${widget.basePrice}'),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),

          // Estimated Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Estimated Total',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '₹${widget.basePrice}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Free inspection banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shield_outlined,
                  size: 13,
                  color: Color(0xFF16A34A),
                ),
                SizedBox(width: 5),
                Text(
                  'Free inspection included with visit',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, {bool isGreen = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isGreen ? const Color(0xFF16A34A) : const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // ── What's Included Box ───────────────────────────────────────────────────

  Widget _buildWhatsIncludedBox() {
    const included = [
      'Home inspection & diagnosis',
      'Expert repair & installation',
      'Up to 30 days service warranty',
      'On-time service',
      'No hidden charges',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 6),
              Text(
                "What's Included",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...included.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Sticky Bottom Action Bar ──────────────────────────────────────────────

  Widget _buildStickyBottomBar() {
    final isRazorpay = _selectedPaymentMethod == PaymentMethodType.razorpay;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _isProcessing ? null : _handleProceed,
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isRazorpay) ...[
                          const Icon(Icons.flash_on_rounded,
                              size: 17, color: Color(0xFFFDE047)),
                          const SizedBox(width: 6),
                          Text(
                            'Pay ₹${widget.basePrice} with Razorpay',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Confirm Booking (Pay ₹${widget.basePrice} Later)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isRazorpay
                    ? Icons.verified_user_outlined
                    : Icons.lock_outline_rounded,
                size: 12,
                color: isRazorpay
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFD97706),
              ),
              const SizedBox(width: 4),
              Text(
                isRazorpay
                    ? 'Secured by Razorpay 256-bit encryption'
                    : 'No upfront advance needed. Pay upon completion.',
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Private Helper Widgets ────────────────────────────────────────────────────

class _RadioCircle extends StatelessWidget {
  const _RadioCircle({required this.isSelected});
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2563EB),
                ),
              ),
            )
          : null,
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF2563EB)),
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
            height: 1.15,
          ),
        ),
      ],
    );
  }
}

/// Razorpay Standard Checkout in-app bottom sheet modal
class _RazorpayCheckoutModal extends StatefulWidget {
  const _RazorpayCheckoutModal({
    required this.orderId,
    required this.amount,
    required this.serviceTitle,
    required this.onPaymentSuccess,
  });

  final String orderId;
  final int amount;
  final String serviceTitle;
  final void Function(String paymentId, String signature) onPaymentSuccess;

  @override
  State<_RazorpayCheckoutModal> createState() => _RazorpayCheckoutModalState();
}

class _RazorpayCheckoutModalState extends State<_RazorpayCheckoutModal> {
  int _selectedMethod = 0; // 0: UPI, 1: Card, 2: NetBanking
  final TextEditingController _upiController =
      TextEditingController(text: 'customer@okaxis');
  bool _isAuthorizing = false;

  @override
  void dispose() {
    _upiController.dispose();
    super.dispose();
  }

  void _triggerPayment() {
    setState(() => _isAuthorizing = true);

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      final paymentId =
          'pay_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(900) + 100}';
      final signature = 'sig_${DateTime.now().millisecondsSinceEpoch}';
      widget.onPaymentSuccess(paymentId, signature);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),

            // Razorpay Header Brand
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF0C2340), // Razorpay dark navy
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Razorpay Trusted Business',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          widget.serviceTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Amount to Pay',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 9.5,
                        ),
                      ),
                      Text(
                        '₹${widget.amount}.00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Order ID Subheader
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF1E293B),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order ID: ${widget.orderId}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(Icons.lock, size: 10, color: Color(0xFF22C55E)),
                      SizedBox(width: 4),
                      Text(
                        '256-bit SSL Secure',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Payment Mode',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mode Tabs
                  Row(
                    children: [
                      _buildMethodTab(
                        title: 'UPI / QR',
                        icon: Icons.qr_code_rounded,
                        index: 0,
                      ),
                      const SizedBox(width: 8),
                      _buildMethodTab(
                        title: 'Cards',
                        icon: Icons.credit_card_rounded,
                        index: 1,
                      ),
                      const SizedBox(width: 8),
                      _buildMethodTab(
                        title: 'NetBanking',
                        icon: Icons.account_balance_rounded,
                        index: 2,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // UPI View
                  if (_selectedMethod == 0) ...[
                    // UPI Apps quick row
                    Row(
                      children: [
                        _buildUpiAppChip('Google Pay', Colors.red.shade400),
                        const SizedBox(width: 8),
                        _buildUpiAppChip('PhonePe', const Color(0xFF5F259F)),
                        const SizedBox(width: 8),
                        _buildUpiAppChip('Paytm', const Color(0xFF00B9F1)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _upiController,
                      decoration: InputDecoration(
                        labelText: 'Enter UPI ID (e.g. mobile@upi)',
                        labelStyle: const TextStyle(fontSize: 11),
                        suffixIcon: const Icon(Icons.check_circle,
                            color: Color(0xFF16A34A), size: 18),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ] else if (_selectedMethod == 1) ...[
                    // Mock Card Inputs
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Card Number',
                            style: TextStyle(
                                fontSize: 10.5, color: Color(0xFF64748B)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '•••• •••• •••• 4242',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Valid: 12/28',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFF64748B))),
                              Text('CVV: •••',
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFF64748B))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // NetBanking Banks
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: ['HDFC', 'ICICI', 'SBI', 'Axis', 'Kotak']
                          .map((bank) => Chip(
                                label: Text(bank,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                                backgroundColor: const Color(0xFFEFF6FF),
                              ))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Pay Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isAuthorizing ? null : _triggerPayment,
                      child: _isAuthorizing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Authorizing with Bank...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'PAY ₹${widget.amount}.00 NOW',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Powered by Razorpay • Live Gateway rzp_live_TUmszmWULXlswC',
                      style: TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTab({
    required String title,
    required IconData icon,
    required int index,
  }) {
    final isSelected = _selectedMethod == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2563EB)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF1E3A8A)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpiAppChip(String name, Color dotColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
