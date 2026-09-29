import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_bookings_service.dart';
import '../../../core/services/firebase_services_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../bookings/screens/bookings_screen.dart';
import '../../services/screens/category_detail_screen.dart';

/// Customer Home Screen featuring:
/// - Horizontal auto-scrolling promotional Image Carousel (replaces search bar)
/// - Real-time Super App Service Verticals in horizontal circular layout (Home Service, Medicine Delivery, Food Delivery, Bike & Cab)
/// - Popular Service Categories from Services screen in horizontal circular layout
/// - Quickox Care Club VIP Membership Card
/// - Recent Bookings section tracking live customer bookings
/// - Dynamic Real-time Services (3 or 4 services loaded from Firebase Firestore with fallback)
/// - "View All" button linking directly to the Services Screen (tab 1)
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onNavigateTab,
    this.servicesService,
    this.autoPlaySlider = true,
  });

  final ValueChanged<int> onNavigateTab;
  final FirebaseServicesService? servicesService;
  final bool autoPlaySlider;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirebaseServicesService _servicesService;
  List<ServiceVerticalItem> _verticals = FirebaseServicesService.defaultVerticals;
  List<ServiceItem> _services = [];
  List<ServiceBookingItem> _recentBookings = _defaultRecentBookings;
  bool _isLoadingServices = true;

  static const List<ServiceBookingItem> _defaultRecentBookings = [
    ServiceBookingItem(
      orderId: 'QX-98241',
      serviceName: 'AC Deep Clean & Jet Service',
      category: 'AC Care',
      serviceIcon: Icons.ac_unit_rounded,
      dateTime: '22 May 2026 • 02:30 PM',
      technicianName: 'Sanjay Mukherjee',
      technicianPhone: '+91 98321 45670',
      technicianRole: 'Certified AC Specialist',
      status: 'ACTIVE',
      statusSubtitle: 'Confirmed',
      locationTitle: 'Home',
      locationSubtitle: 'Haldia Central, WB',
      durationText: '45m • In Progress',
      price: '₹ 499/-',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _servicesService = widget.servicesService ?? FirebaseServicesService();
    _loadServices();
  }

  Future<void> _loadServices() async {
    if (!mounted) return;
    setState(() => _isLoadingServices = true);

    try {
      // Fetch dynamic verticals, services & recent bookings from Firebase
      final results = await Future.wait([
        _servicesService.fetchVerticals(),
        _servicesService.fetchServices(limit: 4),
        FirebaseBookingsService().fetchBookings().catchError((_) => <ServiceBookingItem>[]),
      ]);

      if (mounted) {
        setState(() {
          _verticals = results[0] as List<ServiceVerticalItem>;
          _services = results[1] as List<ServiceItem>;
          final bookings = results[2] as List<ServiceBookingItem>;
          if (bookings.isNotEmpty) {
            _recentBookings = bookings;
          }
          _isLoadingServices = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _verticals = FirebaseServicesService.defaultVerticals;
          _services = FirebaseServicesService.defaultServices.take(4).toList();
          _isLoadingServices = false;
        });
      }
    }
  }

  void _onVerticalTapped(ServiceVerticalItem vert) {
    if (vert.id == 'home_care') {
      widget.onNavigateTab(1); // Go to services catalog tab
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryDetailScreen(
            headerTitle: vert.name,
            headerSubtitle: vert.tagline,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        elevation: 0,
        titleSpacing: AppSpacing.lg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Haldia Central, WB',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ],
            ),
            Text(
              'Home Service Priority Zone',
              style: AppTextStyles.bodySm.copyWith(fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                border: Border.all(color: AppColors.border),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadServices,
        color: AppColors.primary,
        backgroundColor: AppColors.bgPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.sm),

              // ── Horizontal Image Carousel (Replaces Search Bar) ─────────────
              _HomeImageSlider(
                onNavigateTab: widget.onNavigateTab,
                autoPlay: widget.autoPlaySlider,
              ),

              const SizedBox(height: AppSpacing.md),

              // ── 1. Our Services (Top 4 Verticals in Horizontal Circles) ───
              _buildOurServicesSection(),

              const SizedBox(height: AppSpacing.xl),

              // ── 2. Popular Services (Horizontal Circles + Pricing List) ───
              _buildPopularServicesSection(),

              const SizedBox(height: AppSpacing.xl),

              // ── 3. Quickox Care Club VIP Membership Card ──────────────────
              _buildMembershipSection(),

              const SizedBox(height: AppSpacing.xl),

              // ── 4. Recent Bookings Section ────────────────────────────────
              _buildRecentBookingsSection(),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  // ── 1. Our Services Section ───────────────────────────────────────────────
  Widget _buildOurServicesSection() {
    final top4 = _verticals.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Our Services', style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      'Super App verticals loaded from backend',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.onNavigateTab(1), // go to services
                child: Text(
                  'View All',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Horizontal Row of 4 Circular Services in an Elevated White Card Box
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFEEF2F6),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C0F172A),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: top4.map((vert) {
                return Expanded(
                  child: _ServiceCircleItem(
                    title: vert.name,
                    imageUrl: vert.imageUrl,
                    icon: vert.icon,
                    color: vert.color,
                    bgColor: vert.bgColor,
                    onTap: () => _onVerticalTapped(vert),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── 2. Popular Services Section ───────────────────────────────────────────
  Widget _buildPopularServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Popular Services', style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      'Real-time verified pricing in Haldia',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.onNavigateTab(1), // go to services
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Horizontal Scrolling Circular Categories
        SizedBox(
          height: 104,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            scrollDirection: Axis.horizontal,
            itemCount: _popularCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final cat = _popularCategories[index];
              return _PopularCategoryCircleItem(
                category: cat,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryDetailScreen(
                        headerTitle: cat.title,
                        headerSubtitle: cat.desc,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Dynamic Services Price List Cards
        if (_isLoadingServices)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: List.generate(
                3,
                (index) => Container(
                  height: 84,
                  margin: const EdgeInsets.only(bottom: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: _services
                  .map(
                    (service) => _ServiceListCard(
                      service: service,
                      onBook: () => widget.onNavigateTab(1),
                    ),
                  )
                  .toList(),
            ),
          ),

        const SizedBox(height: AppSpacing.sm),

        // View All Services Full-Width CTA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              onPressed: () => widget.onNavigateTab(1),
              icon: const Icon(
                Icons.grid_view_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              label: const Text(
                'View All Services Catalog →',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 3. Quickox Care Club VIP Membership Card ──────────────────────────────
  Widget _buildMembershipSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: GestureDetector(
        onTap: () => widget.onNavigateTab(2), // Navigate to Membership tab
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0C2340), Color(0xFF1E3A8A), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -25,
                top: -25,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('👑', style: TextStyle(fontSize: 10)),
                              SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'CARE CLUB VIP',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: const Text(
                          'Save 25%',
                          style: TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Main heading
                  const Text(
                    'Quickox Care Club Membership',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Save up to 25% on every booking with membership',
                    style: TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Perks pills
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildMembershipPerkPill('Free Inspections'),
                      _buildMembershipPerkPill('20% Off Repairs'),
                      _buildMembershipPerkPill('Priority Tech Dispatch'),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // CTA Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1A000000),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Explore Plans →',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFF1E3A8A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.verified_user_rounded,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipPerkPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 12, color: Color(0xFF34D399)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Recent Bookings Section ────────────────────────────────────────────
  Widget _buildRecentBookingsSection() {
    final bookings = _recentBookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Bookings', style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      'Track active & recent doorstep services',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => widget.onNavigateTab(3), // Navigate to Bookings tab
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View All',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: bookings.take(2).map((booking) {
              return _RecentBookingCard(
                booking: booking,
                onTap: () => widget.onNavigateTab(3),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Horizontal Promotional Image Carousel Slider
// ─────────────────────────────────────────────────────────────────────────────

class _HomeImageSlider extends StatefulWidget {
  const _HomeImageSlider({
    required this.onNavigateTab,
    this.autoPlay = true,
  });

  final ValueChanged<int> onNavigateTab;
  final bool autoPlay;

  @override
  State<_HomeImageSlider> createState() => _HomeImageSliderState();
}

class _HomeImageSliderState extends State<_HomeImageSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  late final List<_SliderSlideData> _slides = [
    _SliderSlideData(
      badge: 'SUMMER SPECIAL • 20% OFF',
      title: 'AC Deep Jet Wash & Gas Check',
      subtitle: 'Doorstep technician within 2 hours • 30-Day Warranty',
      ctaText: 'Book AC Service',
      gradient: const LinearGradient(
        colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      assetImage: 'assets/images/ac.png',
      fallbackIcon: Icons.ac_unit_rounded,
      onTap: () => widget.onNavigateTab(1),
    ),
    _SliderSlideData(
      badge: 'CERTIFIED EXPERTS',
      title: 'Home Wiring & Electrical Audit',
      subtitle: 'Switchboard, MCB & earthing fixes by verified pros',
      ctaText: 'Book Electrician',
      gradient: const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF3730A3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      assetImage: 'assets/images/electrician.png',
      fallbackIcon: Icons.bolt_rounded,
      onTap: () => widget.onNavigateTab(1),
    ),
    _SliderSlideData(
      badge: 'HEALTH & PURITY',
      title: 'Pure & Safe Drinking Water',
      subtitle: 'Free digital TDS check with RO filter & membrane care',
      ctaText: 'Book RO Care',
      gradient: const LinearGradient(
        colors: [Color(0xFF0D9488), Color(0xFF115E59)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      assetImage: 'assets/images/ro.png',
      fallbackIcon: Icons.water_drop_rounded,
      onTap: () => widget.onNavigateTab(1),
    ),
    _SliderSlideData(
      badge: 'CARE CLUB MEMBERSHIP',
      title: 'Save Up To 25% On All Bookings',
      subtitle: '11 BHK tailored plans starting at ₹299/mo with priority visits',
      ctaText: 'Explore Plans →',
      gradient: const LinearGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      assetImage: 'assets/images/technician_avatar.jpg',
      fallbackIcon: Icons.workspace_premium_rounded,
      onTap: () => widget.onNavigateTab(2),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);

    final bool isTesting =
        !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (widget.autoPlay && !isTesting) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted || !_pageController.hasClients) return;
        final next = (_currentPage + 1) % _slides.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 172,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: slide.onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: slide.gradient,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Subtle background glow circle
                        Positioned(
                          right: -20,
                          top: -20,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),

                        // Content Row
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              // Left text column
                              Expanded(
                                flex: 6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.22),
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.full),
                                      ),
                                      child: Text(
                                        slide.badge,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          slide.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          slide.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.88),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.full),
                                      ),
                                      child: Text(
                                        slide.ctaText,
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: AppSpacing.sm),

                              // Right image thumbnail
                              Expanded(
                                flex: 4,
                                child: Center(
                                  child: Container(
                                    width: 86,
                                    height: 86,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withValues(alpha: 0.16),
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                    ),
                                    child: ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.md),
                                      child: Image.asset(
                                        slide.assetImage,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          slide.fallbackIcon,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 5,
              width: _currentPage == i ? 20 : 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? AppColors.primary
                    : AppColors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SliderSlideData {
  final String badge;
  final String title;
  final String subtitle;
  final String ctaText;
  final LinearGradient gradient;
  final String assetImage;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  const _SliderSlideData({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.gradient,
    required this.assetImage,
    required this.fallbackIcon,
    required this.onTap,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Dynamic Service List Card (matches explore_service.jsx item structure)
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceListCard extends StatelessWidget {
  const _ServiceListCard({
    required this.service,
    required this.onBook,
  });

  final ServiceItem service;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image / Thumbnail
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: _buildServiceImage(service.imageUrl, service.category),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Content info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            service.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              service.tag,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF059669),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          service.rating,
                          style: AppTextStyles.bodySm.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• ${service.frequency}',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),

          // Bottom Bar: Price & Book button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        service.price,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (service.originalPrice != null) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          service.originalPrice!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  minimumSize: const Size(54, 28),
                  elevation: 0,
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                onPressed: onBook,
                child: const Text(
                  'Book',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceImage(String url, String category) {
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(category),
      );
    }
    if (url.isNotEmpty && url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(category),
      );
    }
    return _fallbackIcon(category);
  }

  Widget _fallbackIcon(String category) {
    final cat = category.toLowerCase();
    IconData icon = Icons.home_repair_service_rounded;
    Color color = AppColors.primary;

    if (cat.contains('ac')) {
      icon = Icons.ac_unit_rounded;
      color = const Color(0xFF0284C7);
    } else if (cat.contains('electr')) {
      icon = Icons.bolt_rounded;
      color = const Color(0xFFEAB308);
    } else if (cat.contains('plumb')) {
      icon = Icons.water_drop_rounded;
      color = const Color(0xFF2563EB);
    } else if (cat.contains('ro')) {
      icon = Icons.water_rounded;
      color = const Color(0xFF0D9488);
    }

    return Center(
      child: Icon(icon, color: color, size: 28),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Circular Service Horizontal Item (Our Services - 4 Circles)
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceCircleItem extends StatelessWidget {
  const _ServiceCircleItem({
    required this.title,
    required this.imageUrl,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final String title;
  final String imageUrl;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF1F3F6),
            ),
            child: Center(
              child: SizedBox(
                width: 42,
                height: 42,
                child: _buildImageOrIcon(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: SizedBox(
              height: 32,
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF1E293B),
                  height: 1.2,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOrIcon() {
    if (imageUrl.startsWith('assets/')) {
      final double scale =
          (imageUrl.contains('home_service') || imageUrl.contains('medicine'))
              ? 1.18
              : 1.0;
      return Transform.scale(
        scale: scale,
        child: Image.asset(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(icon, color: color, size: 28),
        ),
      );
    }
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            Icon(icon, color: color, size: 28),
      );
    }
    return Icon(icon, color: color, size: 28);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Popular Categories Data & Circular Horizontal Item
// ─────────────────────────────────────────────────────────────────────────────

class _PopularCategoryData {
  final String id;
  final String title;
  final String desc;
  final String imageUrl;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _PopularCategoryData({
    required this.id,
    required this.title,
    required this.desc,
    required this.imageUrl,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}

const List<_PopularCategoryData> _popularCategories = [
  _PopularCategoryData(
    id: 'AC',
    title: 'AC Service',
    desc: 'Deep jet wash, cooling coil sanitization & gas refill',
    imageUrl: '',
    icon: Icons.ac_unit_rounded,
    color: Color(0xFF0284C7),
    bgColor: Color(0xFFF1F3F6),
  ),
  _PopularCategoryData(
    id: 'Electrical',
    title: 'Electrical',
    desc: 'Switchboard restoration, home wiring & short circuit fix',
    imageUrl: '',
    icon: Icons.bolt_rounded,
    color: Color(0xFFEAB308),
    bgColor: Color(0xFFF1F3F6),
  ),
  _PopularCategoryData(
    id: 'Plumbing',
    title: 'Plumbing',
    desc: 'Pipe leakages, taps, basin repair & drainage unblock',
    imageUrl: '',
    icon: Icons.plumbing_rounded,
    color: Color(0xFF0D9488),
    bgColor: Color(0xFFF1F3F6),
  ),
  _PopularCategoryData(
    id: 'RO',
    title: 'RO Purifier',
    desc: 'Sediment filter, carbon block, RO membrane & TDS balance',
    imageUrl: '',
    icon: Icons.water_drop_rounded,
    color: Color(0xFF2563EB),
    bgColor: Color(0xFFF1F3F6),
  ),
  _PopularCategoryData(
    id: 'Washing Machine',
    title: 'Washing Machine',
    desc: 'Drum spin balance, drain valve & motor repair',
    imageUrl: '',
    icon: Icons.local_laundry_service_rounded,
    color: Color(0xFF7C3AED),
    bgColor: Color(0xFFF1F3F6),
  ),
  _PopularCategoryData(
    id: 'Cleaning',
    title: 'Deep Cleaning',
    desc: 'Kitchen, bathroom, sofa & full home sanitization',
    imageUrl: '',
    icon: Icons.cleaning_services_rounded,
    color: Color(0xFFEA580C),
    bgColor: Color(0xFFF1F3F6),
  ),
  _PopularCategoryData(
    id: 'Painting',
    title: 'Painting',
    desc: 'Wall putty, waterproof primer & premium emulsion paint',
    imageUrl: '',
    icon: Icons.format_paint_rounded,
    color: Color(0xFF10B981),
    bgColor: Color(0xFFF1F3F6),
  ),
  _PopularCategoryData(
    id: 'Pest Control',
    title: 'Pest Control',
    desc: 'Herbal odorless gel for cockroaches, termites & bugs',
    imageUrl: '',
    icon: Icons.bug_report_rounded,
    color: Color(0xFFE11D48),
    bgColor: Color(0xFFF1F3F6),
  ),
];

class _PopularCategoryCircleItem extends StatelessWidget {
  const _PopularCategoryCircleItem({
    required this.category,
    required this.onTap,
  });

  final _PopularCategoryData category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 66,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF1F3F6),
              ),
              child: Center(
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                  color: Color(0xFF1E293B),
                  height: 1.15,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Booking Card Component
// ─────────────────────────────────────────────────────────────────────────────

class _RecentBookingCard extends StatelessWidget {
  const _RecentBookingCard({
    required this.booking,
    required this.onTap,
  });

  final ServiceBookingItem booking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isActive = booking.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        booking.orderId,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        booking.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusPill(booking.status, booking.statusSubtitle, isActive),
            ],
          ),
          const SizedBox(height: 10),

          // Service Title + Icon
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  booking.serviceIcon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            booking.dateTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySm.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
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

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 8),

          // Technician, Price & Track Order CTA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.bgSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.technicianName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            booking.price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(60, 28),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                onPressed: onTap,
                icon: const Icon(
                  Icons.near_me_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Track Order',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status, String subtitle, bool isActive) {
    Color bg;
    Color fg;
    if (isActive) {
      bg = const Color(0xFF10B981).withValues(alpha: 0.12);
      fg = const Color(0xFF059669);
    } else if (status == 'COMPLETED') {
      bg = const Color(0xFF3B82F6).withValues(alpha: 0.12);
      fg = const Color(0xFF2563EB);
    } else {
      bg = const Color(0xFFEF4444).withValues(alpha: 0.12);
      fg = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            isActive ? 'Active' : status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

