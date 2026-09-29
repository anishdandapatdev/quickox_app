import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_bookings_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../membership/screens/membership_screen.dart';
import '../../services/screens/services_screen.dart';

/// Data model representing a service booking record
class ServiceBookingItem {
  final String orderId;
  final String serviceName;
  final String category;
  final IconData serviceIcon;
  final String dateTime;
  final String technicianName;
  final String technicianPhone;
  final String technicianRole;
  final String status;
  final String statusSubtitle;
  final String locationTitle;
  final String locationSubtitle;
  final String durationText;
  final String price;
  final String otp;
  final String cancellationReason;

  const ServiceBookingItem({
    required this.orderId,
    required this.serviceName,
    required this.category,
    required this.serviceIcon,
    required this.dateTime,
    required this.technicianName,
    required this.technicianPhone,
    required this.technicianRole,
    required this.status,
    required this.statusSubtitle,
    required this.locationTitle,
    required this.locationSubtitle,
    required this.durationText,
    required this.price,
    this.otp = '',
    this.cancellationReason = '',
  });

  bool get isActive => status == 'ACTIVE' || status == 'IN PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
}

/// Shows the booking details bottom sheet directly from any screen.
/// This allows HomeScreen and other screens to open booking details
/// without needing to navigate to the full BookingsScreen first.
void showBookingDetailsSheet(BuildContext context, ServiceBookingItem booking) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4D4D8),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18181B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: booking.isActive
                        ? const Color(0xFF2563EB).withValues(alpha: 0.1)
                        : booking.isCompleted
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    booking.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: booking.isActive
                          ? const Color(0xFF2563EB)
                          : booking.isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF2F2F4)),
            const SizedBox(height: 8),

            // Service & ID
            Text(
              booking.serviceName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18181B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Booking ID: ${booking.orderId} • ${booking.dateTime}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF71717A)),
            ),
            const SizedBox(height: 14),

            // OTP banner for active bookings
            if (booking.isActive && booking.otp.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key_rounded, color: Color(0xFF2563EB), size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Service Verification Code',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E40AF),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.otp,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 4,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Cancellation banner
            if (booking.isCancelled && booking.cancellationReason.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFFEF4444), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        booking.cancellationReason,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Technician info card
            if (!booking.isCancelled) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.technicianName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18181B),
                            ),
                          ),
                          Text(
                            booking.technicianRole,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                          ),
                        ],
                      ),
                    ),
                    if (booking.isActive)
                      IconButton(
                        icon: const Icon(Icons.phone_rounded, color: Color(0xFF10B981)),
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Calling ${booking.technicianName} (${booking.technicianPhone})...',
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Location & Total row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Location',
                      style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                    ),
                    Text(
                      '${booking.locationTitle} • ${booking.locationSubtitle}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total Amount',
                      style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                    ),
                    Text(
                      booking.price,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF18181B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Close button
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
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Close Details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Data model representing a membership subscription record
class MembershipSubscriptionItem {
  final String membershipId;
  final String planName;
  final String durationLabel; // e.g. "1 Month", "3 Months", "6 Months", "1 Year"
  final String price;
  final String startDate;
  final String expiryDate;
  final int daysLeft;
  final double progress; // 0.0 to 1.0 (time elapsed)
  final String status; // "ACTIVE", "EXPIRING SOON", "EXPIRED"
  final List<String> perksUsed;
  final List<String> perksRemaining;

  const MembershipSubscriptionItem({
    required this.membershipId,
    required this.planName,
    required this.durationLabel,
    required this.price,
    required this.startDate,
    required this.expiryDate,
    required this.daysLeft,
    required this.progress,
    required this.status,
    required this.perksUsed,
    required this.perksRemaining,
  });

  bool get isActive => status == 'ACTIVE' || status == 'EXPIRING SOON';
  bool get isExpired => status == 'EXPIRED';
}

/// My Bookings & Subscriptions Screen with 2-Tier Architecture:
/// Tier 1: Main Category Switcher (Services vs. Membership Plans)
/// Tier 2: Status Filter Pills (Active, Completed, Cancelled / Active, Expired)
class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  // Tier 1: 0 = Services, 1 = Membership Plans
  int _selectedCategory = 0;

  // Tier 2 (Services): 0 = Active, 1 = Completed, 2 = Cancelled
  int _selectedServiceFilter = 0;

  // Tier 2 (Memberships): 0 = Active Plans, 1 = Expired / History
  int _selectedMembershipFilter = 0;

  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  final FirebaseBookingsService _bookingsService = FirebaseBookingsService();
  late List<ServiceBookingItem> _serviceBookings;

  @override
  void initState() {
    super.initState();
    _serviceBookings = List.from(_defaultServiceBookings);
    _searchFocusNode.addListener(_handleSearchFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadRemoteBookings();
      }
    });
  }

  Future<void> _loadRemoteBookings() async {
    try {
      final remote = await _bookingsService.fetchBookings();
      if (remote.isNotEmpty && mounted) {
        setState(() {
          final existingIds = remote.map((b) => b.orderId).toSet();
          final combined = [
            ...remote,
            ..._defaultServiceBookings.where((b) => !existingIds.contains(b.orderId)),
          ];
          _serviceBookings = combined;
        });
      }
    } catch (e) {
      debugPrint('[BookingsScreen] Fetch error: $e');
    }
  }

  void _handleSearchFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_handleSearchFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Sample Service Bookings Data (Fallback) ───────────────────────────────
  static const List<ServiceBookingItem> _defaultServiceBookings = [
    ServiceBookingItem(
      orderId: 'QX-98241',
      serviceName: 'AC Deep Clean & Jet Service',
      category: 'Home Service',
      serviceIcon: Icons.ac_unit_rounded,
      dateTime: '22 May 2026 • 02:30 PM',
      technicianName: 'Sanjay Mukherjee',
      technicianPhone: '+91 98321 45670',
      technicianRole: 'Certified AC Specialist',
      status: 'ACTIVE',
      statusSubtitle: 'Confirmed',
      locationTitle: 'Home',
      locationSubtitle: 'Salt Lake, Sector V',
      durationText: '45m • In Progress',
      price: '₹499',
      otp: '4821',
    ),
    ServiceBookingItem(
      orderId: 'QX-87119',
      serviceName: 'Switchboard & Socket Installation',
      category: 'Electrical Service',
      serviceIcon: Icons.electrical_services_rounded,
      dateTime: '12 Sep 2026 • 11:00 AM',
      technicianName: 'Amitava Roy',
      technicianPhone: '+91 98765 12345',
      technicianRole: 'Licensed Electrician',
      status: 'COMPLETED',
      statusSubtitle: 'Paid & Closed',
      locationTitle: 'Home',
      locationSubtitle: 'New Town, Action Area 1',
      durationText: '1h 15m • Completed',
      price: '₹349',
    ),
    ServiceBookingItem(
      orderId: 'QX-84902',
      serviceName: 'Bathroom Tap Leakage Repair',
      category: 'Plumbing Service',
      serviceIcon: Icons.plumbing_rounded,
      dateTime: '28 Aug 2026 • 04:15 PM',
      technicianName: 'Bikash Das',
      technicianPhone: '+91 98450 67890',
      technicianRole: 'Master Plumber',
      status: 'COMPLETED',
      statusSubtitle: 'Paid & Closed',
      locationTitle: 'Home',
      locationSubtitle: 'Park Street, Flat 4B',
      durationText: '35m • Completed',
      price: '₹299',
    ),
    ServiceBookingItem(
      orderId: 'QX-79102',
      serviceName: 'Kitchen Exhaust Fan Installation',
      category: 'Appliance Repair',
      serviceIcon: Icons.handyman_rounded,
      dateTime: '15 Jul 2026 • 01:00 PM',
      technicianName: 'Ramesh Sen',
      technicianPhone: '+91 98111 22334',
      technicianRole: 'Technician',
      status: 'CANCELLED',
      statusSubtitle: 'Cancelled',
      locationTitle: 'Home',
      locationSubtitle: 'Gariahat, Kolkata',
      durationText: 'Cancelled',
      price: '₹399',
      cancellationReason: 'Cancelled by Customer • Refund ₹399 Credited to UPI',
    ),
  ];

  // ── Sample Membership Plans Data (Monthly, 3 Months, 6 Months, etc.) ──────
  static const List<MembershipSubscriptionItem> _memberships = [
    MembershipSubscriptionItem(
      membershipId: 'QX-MEM-3091',
      planName: 'Quickox Plus Care Club',
      durationLabel: '3 Months Plan',
      price: '₹999 / 3 months',
      startDate: '28 Aug 2026',
      expiryDate: '28 Nov 2026',
      daysLeft: 42,
      progress: 0.53,
      status: 'ACTIVE',
      perksUsed: [
        '1 of 2 Free AC Jet Services used',
      ],
      perksRemaining: [
        '1 Free AC Jet Service available',
        '2 Free Home Safety Audits available',
        '100% Free Labor on Electrical & Plumbing',
        'Priority 30-min Emergency Dispatch',
      ],
    ),
    MembershipSubscriptionItem(
      membershipId: 'QX-MEM-1044',
      planName: 'Quickox Essential Care',
      durationLabel: '1 Month Plan',
      price: '₹499 / month',
      startDate: '15 Jul 2026',
      expiryDate: '15 Aug 2026',
      daysLeft: 0,
      progress: 1.0,
      status: 'EXPIRED',
      perksUsed: [
        '1 Free Home Safety Audit used',
      ],
      perksRemaining: [
        '15% discount on all service labor',
        '30-day post-service warranty',
      ],
    ),
  ];

  int get _matchingServicesCount {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _serviceBookings.length;
    return _serviceBookings.where((b) {
      return b.serviceName.toLowerCase().contains(query) ||
          b.orderId.toLowerCase().contains(query) ||
          b.category.toLowerCase().contains(query) ||
          b.technicianName.toLowerCase().contains(query) ||
          b.locationSubtitle.toLowerCase().contains(query) ||
          b.locationTitle.toLowerCase().contains(query);
    }).length;
  }

  int get _matchingMembershipsCount {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _memberships.length;
    return _memberships.where((m) {
      return m.planName.toLowerCase().contains(query) ||
          m.membershipId.toLowerCase().contains(query) ||
          m.durationLabel.toLowerCase().contains(query) ||
          m.perksRemaining.any((p) => p.toLowerCase().contains(query)) ||
          m.perksUsed.any((p) => p.toLowerCase().contains(query));
    }).length;
  }

  List<ServiceBookingItem> get _filteredServices {
    final query = _searchQuery.trim().toLowerCase();
    var list = _serviceBookings;
    if (_selectedServiceFilter == 0) {
      list = list.where((b) => b.isActive).toList();
    } else if (_selectedServiceFilter == 1) {
      list = list.where((b) => b.isCompleted).toList();
    } else {
      list = list.where((b) => b.isCancelled).toList();
    }

    if (query.isEmpty) return list;

    final queryFiltered = list.where((b) {
      return b.serviceName.toLowerCase().contains(query) ||
          b.orderId.toLowerCase().contains(query) ||
          b.category.toLowerCase().contains(query) ||
          b.technicianName.toLowerCase().contains(query) ||
          b.locationSubtitle.toLowerCase().contains(query) ||
          b.locationTitle.toLowerCase().contains(query);
    }).toList();

    if (queryFiltered.isEmpty) {
      return _serviceBookings.where((b) {
        return b.serviceName.toLowerCase().contains(query) ||
            b.orderId.toLowerCase().contains(query) ||
            b.category.toLowerCase().contains(query) ||
            b.technicianName.toLowerCase().contains(query) ||
            b.locationSubtitle.toLowerCase().contains(query) ||
            b.locationTitle.toLowerCase().contains(query);
      }).toList();
    }

    return queryFiltered;
  }

  List<MembershipSubscriptionItem> get _filteredMemberships {
    final query = _searchQuery.trim().toLowerCase();
    var list = _memberships;
    if (_selectedMembershipFilter == 0) {
      list = list.where((m) => m.isActive).toList();
    } else {
      list = list.where((m) => m.isExpired).toList();
    }

    if (query.isEmpty) return list;

    final queryFiltered = list.where((m) {
      return m.planName.toLowerCase().contains(query) ||
          m.membershipId.toLowerCase().contains(query) ||
          m.durationLabel.toLowerCase().contains(query) ||
          m.perksRemaining.any((p) => p.toLowerCase().contains(query)) ||
          m.perksUsed.any((p) => p.toLowerCase().contains(query));
    }).toList();

    if (queryFiltered.isEmpty) {
      return _memberships.where((m) {
        return m.planName.toLowerCase().contains(query) ||
            m.membershipId.toLowerCase().contains(query) ||
            m.durationLabel.toLowerCase().contains(query) ||
            m.perksRemaining.any((p) => p.toLowerCase().contains(query)) ||
            m.perksUsed.any((p) => p.toLowerCase().contains(query));
      }).toList();
    }

    return queryFiltered;
  }

  void _showServiceDetailsSheet(ServiceBookingItem booking) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18181B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: booking.isActive
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : booking.isCompleted
                              ? AppColors.success.withValues(alpha: 0.1)
                              : const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: booking.isActive
                            ? AppColors.primary
                            : booking.isCompleted
                                ? AppColors.success
                                : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF2F2F4)),
              const SizedBox(height: 8),

              // Service & ID
              Text(
                booking.serviceName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Booking ID: ${booking.orderId} • ${booking.dateTime}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 14),

              // Start OTP banner for Active bookings
              if (booking.isActive && booking.otp.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.key_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Service Verification Code',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E40AF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              booking.otp,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 4,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Cancellation info banner if cancelled
              if (booking.isCancelled && booking.cancellationReason.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          booking.cancellationReason,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Technician info card
              if (!booking.isCancelled) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.technicianName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF18181B),
                              ),
                            ),
                            Text(
                              booking.technicianRole,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF71717A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (booking.isActive)
                        IconButton(
                          icon: const Icon(
                            Icons.phone_rounded,
                            color: AppColors.success,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Calling ${booking.technicianName} (${booking.technicianPhone})...',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Location & Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF71717A),
                    ),
                  ),
                  Text(
                    booking.price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF18181B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Close / Done button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Close Details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

  void _showMembershipDetailsSheet(MembershipSubscriptionItem membership) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4D4D8),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Membership Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18181B),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: membership.isActive
                          ? AppColors.success.withValues(alpha: 0.1)
                          : const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      membership.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: membership.isActive
                            ? AppColors.success
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFF2F2F4)),
              const SizedBox(height: 8),

              Text(
                membership.planName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ID: ${membership.membershipId} • ${membership.durationLabel}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF71717A),
                ),
              ),
              const SizedBox(height: 14),

              // Validity Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: membership.isActive
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFF4F4F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: membership.isActive
                        ? const Color(0xFFBFDBFE)
                        : const Color(0xFFE4E4E7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      membership.isActive
                          ? Icons.verified_rounded
                          : Icons.access_time_rounded,
                      color: membership.isActive
                          ? AppColors.primary
                          : const Color(0xFF71717A),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            membership.isActive
                                ? '${membership.daysLeft} Days Remaining'
                                : 'Membership Expired',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: membership.isActive
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF3F3F46),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Valid: ${membership.startDate} - ${membership.expiryDate}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF71717A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Included Perks
              const Text(
                'Plan Perks & Usage',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(height: 8),

              ...membership.perksRemaining.map(
                (perk) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          perk,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF3F3F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              ...membership.perksUsed.map(
                (perk) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.remove_circle_outline_rounded,
                        color: Color(0xFFA1A1AA),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          perk,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF71717A),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MembershipScreen(),
                          ),
                        );
                      },
                      child: Text(
                        membership.isActive ? 'Renew / Upgrade' : 'Renew Plan',
                        style: const TextStyle(fontWeight: FontWeight.w700),
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

  @override
  Widget build(BuildContext context) {
    final activeServicesCount = _serviceBookings.where((b) => b.isActive).length;
    final completedServicesCount = _serviceBookings.where((b) => b.isCompleted).length;
    final cancelledServicesCount = _serviceBookings.where((b) => b.isCancelled).length;

    final activeMembershipsCount = _memberships.where((m) => m.isActive).length;
    final expiredMembershipsCount = _memberships.where((m) => m.isExpired).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Neutral grey-white background
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadRemoteBookings,
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
              const SizedBox(height: AppSpacing.xs),

              // ── Header (Title + Search Toggle Button) ────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (Navigator.canPop(context)) ...[
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Color(0xFF18181B),
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                        ],
                        const Flexible(
                          child: Text(
                            'My Bookings',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF18181B),
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Search box icon on the right side beside My Bookings
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      setState(() {
                        _isSearchOpen = !_isSearchOpen;
                        if (_isSearchOpen) {
                          _searchFocusNode.requestFocus();
                        } else {
                          _searchFocusNode.unfocus();
                          _searchController.clear();
                          _searchQuery = '';
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _isSearchOpen ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isSearchOpen
                              ? AppColors.primary
                              : const Color(0xFFE5E5EA),
                          width: 0.8,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x05000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSearchOpen
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        color: _isSearchOpen
                            ? Colors.white
                            : const Color(0xFF18181B),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Track your service orders and membership subscriptions',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF71717A),
                  fontWeight: FontWeight.w400,
                ),
              ),

              // ── Smooth Animated Search Input Field ─────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.topCenter,
                child: _isSearchOpen
                    ? Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.full),
                                border: Border.all(
                                  color: _searchFocusNode.hasFocus
                                      ? AppColors.primary
                                      : const Color(0xFFD1D5DB),
                                  width: _searchFocusNode.hasFocus ? 1.8 : 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _searchFocusNode.hasFocus
                                        ? AppColors.primary.withValues(alpha: 0.08)
                                        : const Color(0x06000000),
                                    blurRadius: _searchFocusNode.hasFocus ? 8 : 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocusNode,
                                      onChanged: (val) {
                                        setState(() => _searchQuery = val);
                                      },
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF18181B),
                                      ),
                                      cursorColor: AppColors.primary,
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        hintText:
                                            'Search service, plan, technician, or ID...',
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        filled: false,
                                      ),
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                        color: Color(0xFF71717A),
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      splashRadius: 20,
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    ),
                                ],
                              ),
                            ),
                            if (_searchQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Results for "${_searchQuery.trim()}"',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF71717A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (_selectedCategory == 0 &&
                                      _matchingMembershipsCount > 0)
                                    InkWell(
                                      onTap: () => setState(
                                          () => _selectedCategory = 1),
                                      child: Text(
                                        'See in Memberships ($_matchingMembershipsCount) →',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  else if (_selectedCategory == 1 &&
                                      _matchingServicesCount > 0)
                                    InkWell(
                                      onTap: () => setState(
                                          () => _selectedCategory = 0),
                                      child: Text(
                                        'See in Services ($_matchingServicesCount) →',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Tier 1: Main Category Switcher (Services vs Memberships) ───
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x05000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _CategoryTabButton(
                        title: 'Services ($_matchingServicesCount)',
                        icon: Icons.home_repair_service_rounded,
                        isSelected: _selectedCategory == 0,
                        onTap: () => setState(() => _selectedCategory = 0),
                      ),
                    ),
                    Expanded(
                      child: _CategoryTabButton(
                        title: 'Membership Plans ($_matchingMembershipsCount)',
                        icon: Icons.workspace_premium_rounded,
                        isSelected: _selectedCategory == 1,
                        onTap: () => setState(() => _selectedCategory = 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Tier 2: Sub-filter Pills based on selected category ────────
              if (_selectedCategory == 0) ...[
                // Service status filter pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _PillChip(
                        label: 'Active ($activeServicesCount)',
                        icon: Icons.schedule_rounded,
                        isSelected: _selectedServiceFilter == 0,
                        onTap: () => setState(() => _selectedServiceFilter = 0),
                      ),
                      const SizedBox(width: 8),
                      _PillChip(
                        label: 'Completed ($completedServicesCount)',
                        icon: Icons.check_circle_outline_rounded,
                        isSelected: _selectedServiceFilter == 1,
                        onTap: () => setState(() => _selectedServiceFilter = 1),
                      ),
                      const SizedBox(width: 8),
                      _PillChip(
                        label: 'Cancelled ($cancelledServicesCount)',
                        icon: Icons.cancel_outlined,
                        isSelected: _selectedServiceFilter == 2,
                        onTap: () => setState(() => _selectedServiceFilter = 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Services List
                if (_filteredServices.isEmpty)
                  _buildEmptyState(
                    icon: _searchQuery.isNotEmpty
                        ? Icons.search_off_rounded
                        : _selectedServiceFilter == 0
                            ? Icons.schedule_rounded
                            : _selectedServiceFilter == 1
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                    message: _searchQuery.isNotEmpty
                        ? 'No services matching "$_searchQuery"'
                        : _selectedServiceFilter == 0
                            ? 'No active service bookings found'
                            : _selectedServiceFilter == 1
                                ? 'No completed bookings yet'
                                : 'No cancelled bookings',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredServices.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final booking = _filteredServices[index];
                      return _ServiceBookingCard(
                        booking: booking,
                        onViewDetails: () => _showServiceDetailsSheet(booking),
                      );
                    },
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Services Bottom Promo Card
                _buildActionBanner(
                  icon: Icons.handyman_rounded,
                  title: 'Need another service?',
                  subtitle: 'Book certified technicians with 30-day warranty',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ServicesScreen()),
                    );
                  },
                ),
              ] else ...[
                // Membership status filter pills
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _PillChip(
                        label: 'Active Plans ($activeMembershipsCount)',
                        icon: Icons.verified_rounded,
                        isSelected: _selectedMembershipFilter == 0,
                        onTap: () => setState(() => _selectedMembershipFilter = 0),
                      ),
                      const SizedBox(width: 8),
                      _PillChip(
                        label: 'Expired / History ($expiredMembershipsCount)',
                        icon: Icons.history_rounded,
                        isSelected: _selectedMembershipFilter == 1,
                        onTap: () => setState(() => _selectedMembershipFilter = 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Memberships List
                if (_filteredMemberships.isEmpty)
                  _buildEmptyState(
                    icon: _searchQuery.isNotEmpty
                        ? Icons.search_off_rounded
                        : Icons.workspace_premium_outlined,
                    message: _searchQuery.isNotEmpty
                        ? 'No plans matching "$_searchQuery"'
                        : _selectedMembershipFilter == 0
                            ? 'No active membership subscriptions'
                            : 'No past expired memberships',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredMemberships.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final membership = _filteredMemberships[index];
                      return _MembershipCard(
                        membership: membership,
                        onViewDetails: () =>
                            _showMembershipDetailsSheet(membership),
                        onRenew: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MembershipScreen(),
                            ),
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Memberships Bottom Promo Card
                _buildActionBanner(
                  icon: Icons.workspace_premium_rounded,
                  title: 'Explore All Membership Plans',
                  subtitle: 'Save up to ₹4,500/year with free visits & zero labor fee',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MembershipScreen()),
                    );
                  },
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFFA1A1AA)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF71717A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBanner({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UI Components
// ─────────────────────────────────────────────────────────────────────────────

/// Category Switcher Button for Tier 1
class _CategoryTabButton extends StatelessWidget {
  const _CategoryTabButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF71717A),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF71717A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pill Chip for Tier 2 Sub-Filters
class _PillChip extends StatelessWidget {
  const _PillChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF18181B) : const Color(0xFFE5E5EA),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF71717A),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF3F3F46),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Service Booking Card matching the visual mockup layout
class _ServiceBookingCard extends StatelessWidget {
  const _ServiceBookingCard({
    required this.booking,
    required this.onViewDetails,
  });

  final ServiceBookingItem booking;
  final VoidCallback onViewDetails;

  @override
  Widget build(BuildContext context) {
    final ribbonColor = booking.isActive
        ? AppColors.primary
        : booking.isCompleted
            ? AppColors.success
            : const Color(0xFFEF4444);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section with Ribbon Stack
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          booking.serviceIcon,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Service Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.serviceName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF18181B),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              booking.dateTime,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF71717A),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              booking.isCancelled
                                  ? booking.cancellationReason
                                  : '${booking.technicianName} • ${booking.technicianRole}',
                              style: TextStyle(
                                fontSize: 11,
                                color: booking.isCancelled
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF71717A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Right QR / Status
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 22),
                          Icon(
                            booking.isCancelled
                                ? Icons.cancel_outlined
                                : Icons.qr_code_2_rounded,
                            size: 24,
                            color: booking.isCancelled
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF18181B),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.statusSubtitle,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: booking.isCancelled
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Top-Right Ribbon Badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ribbonColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      booking.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            // Middle Section: Progress / Route Track
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Left: Service Location
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Service Location',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF71717A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.locationTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18181B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.locationSubtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF71717A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Middle: Timeline Track
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: booking.isCancelled
                                    ? const Color(0xFFA1A1AA)
                                    : const Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            Expanded(
                              child: CustomPaint(
                                size: const Size(double.infinity, 2),
                                painter: _DottedLinePainter(
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                            Icon(
                              booking.isActive
                                  ? Icons.handyman_rounded
                                  : booking.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                              size: 16,
                              color: ribbonColor,
                            ),
                            Expanded(
                              child: CustomPaint(
                                size: const Size(double.infinity, 2),
                                painter: _DottedLinePainter(
                                  color: const Color(0xFFCBD5E1),
                                ),
                              ),
                            ),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: booking.isActive
                                    ? const Color(0xFFEF4444)
                                    : booking.isCompleted
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFA1A1AA),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            booking.durationText,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E40AF),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right: Technician
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Technician',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF71717A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.isCancelled
                              ? 'N/A'
                              : booking.technicianName.split(' ').first,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18181B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          booking.isActive
                              ? 'Arriving soon'
                              : booking.isCompleted
                                  ? 'Job Done'
                                  : 'Cancelled',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF71717A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Bottom Strip: Booking ID & View Details
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F1FD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Booking ID: ${booking.orderId}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onViewDetails,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: Color(0xFF1D4ED8),
                        ),
                      ],
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
}

/// Membership Subscription Card (Monthly, 3 Months, 6 Months, etc.)
class _MembershipCard extends StatelessWidget {
  const _MembershipCard({
    required this.membership,
    required this.onViewDetails,
    required this.onRenew,
  });

  final MembershipSubscriptionItem membership;
  final VoidCallback onViewDetails;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final ribbonColor = membership.isActive
        ? const Color(0xFF10B981)
        : const Color(0xFF71717A);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5EA), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section with Ribbon
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: membership.isActive
                              ? const Color(0xFFEFF6FF)
                              : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.workspace_premium_rounded,
                          color: membership.isActive
                              ? AppColors.primary
                              : const Color(0xFF71717A),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              membership.planName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF18181B),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    membership.durationLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF3730A3),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    membership.price,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF71717A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Top-Right Ribbon Badge
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ribbonColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      membership.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Validity Countdown & Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            membership.isActive
                                ? '${membership.daysLeft} Days Remaining'
                                : 'Plan Expired',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: membership.isActive
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Expires: ${membership.expiryDate}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: membership.progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          membership.isActive
                              ? AppColors.primary
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Top Perks preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...membership.perksRemaining.take(2).map(
                        (perk) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF10B981),
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  perk,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF475569),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Bottom Strip: Membership ID & Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F1FD),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'ID: ${membership.membershipId}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D4ED8),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onViewDetails,
                        child: const Text(
                          'View Details',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: onRenew,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            membership.isActive ? 'Renew' : 'Renew Now',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dotted Line Custom Painter
class _DottedLinePainter extends CustomPainter {
  final Color color;
  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    final y = size.height / 2;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + dashWidth > size.width ? size.width : startX + dashWidth, y),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
