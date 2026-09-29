import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_services_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'category_detail_screen.dart';
import 'home_service_categories_screen.dart';
import 'sub_services_screen.dart';

/// Top-Level Services Screen (Tier 1 of Multi-Tier Service Flow)
/// Displays all 8 Super-App Service Verticals matching explore_service.jsx:
/// 1. Home Service (leads to HomeServiceCategoriesScreen -> CategoryDetailScreen -> ServiceDetailOverviewScreen)
/// 2. Food Delivery (leads to SubServicesScreen)
/// 3. Bike & Cab Service (leads to SubServicesScreen)
/// 4. Any Kind of Event Booking (leads to SubServicesScreen)
/// 5. Emergency Ambulance (leads to SubServicesScreen)
/// 6. Medicine Delivery (leads to SubServicesScreen)
/// 7. Room Booking (leads to SubServicesScreen)
/// 8. QUICKOX ELECTRA Scooty (leads to SubServicesScreen)
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({
    super.key,
    this.onNavigateTab,
  });

  final ValueChanged<int>? onNavigateTab;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseServicesService _servicesService = FirebaseServicesService();

  String _searchQuery = '';
  List<ServiceCategoryItem> _homeCategories =
      FirebaseServicesService.defaultCategories;
  bool _isLoading = false;

  /// Default 8 Super App Service Verticals matching explore_service.jsx & multiServiceData.js
  static const List<_ServiceVerticalData> _allVerticals = [
    _ServiceVerticalData(
      id: 'home_care',
      title: 'Home Service',
      description: 'Doorstep AC, Electrical, Plumbing, RO & Appliance Repairs',
      imageUrl: 'assets/images/ac.png',
      badgeText: 'Popular',
      tags: ['AC Service', 'Electrical Services', 'Plumbing Services'],
      fallbackIcon: Icons.home_repair_service_rounded,
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
    ),
    _ServiceVerticalData(
      id: 'food_delivery',
      title: 'Food Delivery',
      description: 'Top Rated Restaurants, Cloud Kitchens & Fast Doorstep Feasts',
      imageUrl:
          'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=600&auto=format&fit=crop&q=80',
      badgeText: '25-35 Min',
      tags: ['Biryani', 'Thali', 'Rolls', 'Desserts'],
      fallbackIcon: Icons.restaurant_rounded,
      color: Color(0xFFEA580C),
      bgColor: Color(0xFFFFF7ED),
    ),
    _ServiceVerticalData(
      id: 'bike_cab',
      title: 'Bike & Cab Service',
      description: 'Instant Affordable City Commute, Bike Taxis, Autos & Sedans',
      imageUrl:
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=600&auto=format&fit=crop&q=80',
      badgeText: 'From ₹25',
      tags: ['Bike Taxi', 'City Auto', 'Cab Mini', 'Sedan Prime'],
      fallbackIcon: Icons.directions_car_rounded,
      color: Color(0xFF0891B2),
      bgColor: Color(0xFFECFEFF),
    ),
    _ServiceVerticalData(
      id: 'event_booking',
      title: 'Any Kind of Event Booking',
      description: 'Turnkey Ceremonies, Catering, Floral Mandap Decor & Photography',
      imageUrl:
          'https://images.unsplash.com/photo-1519741497674-611481863552?w=600&auto=format&fit=crop&q=80',
      badgeText: 'Custom Quotes',
      tags: ['Marriage', 'Birthday', 'Rice Ceremony', 'Corporate'],
      fallbackIcon: Icons.celebration_rounded,
      color: Color(0xFF9333EA),
      bgColor: Color(0xFFFAF5FF),
    ),
    _ServiceVerticalData(
      id: 'ambulance',
      title: 'Emergency Ambulance',
      description: '24/7 Rapid Medical Dispatch, Ventilator Support & ICU on Wheels',
      imageUrl:
          'https://images.unsplash.com/photo-1587745416684-47953f16f02f?w=600&auto=format&fit=crop&q=80',
      badgeText: 'SOS 24/7',
      tags: ['10-15 Min ETA', 'Oxygen & ICU', 'Paramedics'],
      fallbackIcon: Icons.emergency_rounded,
      color: Color(0xFFDC2626),
      bgColor: Color(0xFFFEF2F2),
    ),
    _ServiceVerticalData(
      id: 'medicine_delivery',
      title: 'Medicine Delivery',
      description: 'Prescription Rx Verification, Pain Relief, First Aid & Wellness',
      imageUrl:
          'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=600&auto=format&fit=crop&q=80',
      badgeText: '30-Min Express',
      tags: ['Flat 20% Off', 'Rx Upload', 'First Aid'],
      fallbackIcon: Icons.medication_rounded,
      color: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
    ),
    _ServiceVerticalData(
      id: 'room_booking',
      title: 'Room Booking',
      description: 'Verified Boutique Hotels, Cozy Homestays & Flexible Hourly Micro-Stays',
      imageUrl:
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=600&auto=format&fit=crop&q=80',
      badgeText: 'Hourly & Nightly',
      tags: ['Hotels', 'Hourly Stays', 'Homestays'],
      fallbackIcon: Icons.hotel_rounded,
      color: Color(0xFF4F46E5),
      bgColor: Color(0xFFEEF2FF),
    ),
    _ServiceVerticalData(
      id: 'electra_scooty',
      title: 'QUICKOX ELECTRA Scooty',
      description: 'Smart Eco EV Scooter Rentals, Free Home Test Rides & Battery Swap Hubs',
      imageUrl:
          'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=600&auto=format&fit=crop&q=80',
      badgeText: 'Zero Emission',
      tags: ['Doorstep Test Ride', 'Battery Swap', 'Smart EV'],
      fallbackIcon: Icons.electric_scooter_rounded,
      color: Color(0xFF0D9488),
      bgColor: Color(0xFFF0FDFA),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final fetched = await _servicesService.fetchCategories();
      final homeOnly = fetched.where((c) =>
          FirebaseServicesService.isHomeServiceCategory(c.id) &&
          FirebaseServicesService.isHomeServiceCategory(c.title)).toList();
      if (mounted && homeOnly.isNotEmpty) {
        setState(() {
          _homeCategories = homeOnly;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleVerticalTap(_ServiceVerticalData vertical) {
    if (vertical.id == 'home_care' || vertical.title == 'Home Service') {
      // Flow Tier 1 -> Tier 2: Open Home Service Categories
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomeServiceCategoriesScreen(
            serviceTitle: vertical.title,
            serviceSubtitle: vertical.description,
          ),
        ),
      );
    } else {
      // Flow Tier 1 -> Tier 2: Open other vertical sub-services
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SubServicesScreen(
            categoryTitle: vertical.title,
            categorySubtitle: vertical.description,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanQuery = _searchQuery.trim().toLowerCase();

    // 1. Filtered Verticals
    final filteredVerticals = cleanQuery.isEmpty
        ? _allVerticals
        : _allVerticals.where((v) {
            return v.title.toLowerCase().contains(cleanQuery) ||
                v.description.toLowerCase().contains(cleanQuery) ||
                v.tags.any((t) => t.toLowerCase().contains(cleanQuery));
          }).toList();

    // 2. Direct Matching Home Service Categories for search cross-discovery
    final matchingHomeCategories = cleanQuery.isEmpty
        ? <ServiceCategoryItem>[]
        : _homeCategories.where((c) {
            return c.title.toLowerCase().contains(cleanQuery) ||
                c.desc.toLowerCase().contains(cleanQuery) ||
                c.tags.any((t) => t.toLowerCase().contains(cleanQuery));
          }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCategories,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // ── Header Section ───────────────────────────────────────────
                Text(
                  'Services',
                  style: AppTextStyles.h2.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Search Bar ────────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgPrimary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText:
                          'Search all services (AC repair, biryani, bike cab, ambulance...)',
                      hintStyle: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textMuted,
                        size: 22,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Action Buttons Row ─────────────────────────────────────────
                Row(
                  children: [
                    // Book Inspection Button (Filled Blue)
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        onPressed: () {
                          widget.onNavigateTab?.call(3); // Book tab
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Book Inspection',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // View Membership Plans Button (Outlined Blue)
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        onPressed: () {
                          widget.onNavigateTab?.call(2); // Membership tab
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.workspace_premium_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Membership Plans',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Section Title: Explore All Categories ──────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Explore All Categories',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isLoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      Text(
                        cleanQuery.isEmpty
                            ? '${_allVerticals.length} services'
                            : '${filteredVerticals.length + matchingHomeCategories.length} results',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Direct Matching Categories in Search Mode ───────────────────
                if (cleanQuery.isNotEmpty && matchingHomeCategories.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: Text(
                      'Matching Home Categories (${matchingHomeCategories.length})',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: matchingHomeCategories.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = matchingHomeCategories[index];
                      return GestureDetector(
                        onTap: () {
                          // Drill directly to CategoryDetailScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryDetailScreen(
                                categoryName: item.title,
                                headerTitle: item.title,
                                headerSubtitle: item.desc,
                              ),
                            ),
                          );
                        },
                        child: _HorizontalCategorySearchResultCard(item: item),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (filteredVerticals.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Services Verticals (${filteredVerticals.length})',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],

                // ── Main Service Verticals List ──────────────────────────────
                if (filteredVerticals.isEmpty && matchingHomeCategories.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xxl),
                    margin: const EdgeInsets.only(top: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.search_off_rounded,
                          size: 44,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'No services found for "$_searchQuery"',
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try searching for "AC", "Plumbing", "Food", "Cab", or "Ambulance"',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredVerticals.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = filteredVerticals[index];
                      return GestureDetector(
                        onTap: () => _handleVerticalTap(item),
                        child: _HorizontalVerticalCard(item: item),
                      );
                    },
                  ),
                const SizedBox(height: AppSpacing.xl),

                // ── Why Choose Quickox Banner ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why Choose Quickox?',
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _TrustPillar(
                              icon: Icons.verified_user_rounded,
                              iconColor: AppColors.primary,
                              title: 'Verified\nProfessionals',
                            ),
                          ),
                          Expanded(
                            child: _TrustPillar(
                              icon: Icons.star_border_rounded,
                              iconColor: Color(0xFF2563EB),
                              title: 'Quality\nAssured',
                            ),
                          ),
                          Expanded(
                            child: _TrustPillar(
                              icon: Icons.access_time_rounded,
                              iconColor: Color(0xFF2563EB),
                              title: 'On-Time\nGuarantee',
                            ),
                          ),
                          Expanded(
                            child: _TrustPillar(
                              icon: Icons.sell_outlined,
                              iconColor: Color(0xFF2563EB),
                              title: 'Transparent\nPricing',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Service Vertical Data Model ───────────────────────────────────────────────

class _ServiceVerticalData {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String badgeText;
  final List<String> tags;
  final IconData fallbackIcon;
  final Color color;
  final Color bgColor;

  const _ServiceVerticalData({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.badgeText,
    required this.tags,
    required this.fallbackIcon,
    this.color = const Color(0xFF2563EB),
    this.bgColor = const Color(0xFFEFF6FF),
  });
}

// ── Horizontal Vertical Card Widget ──────────────────────────────────────────

class _HorizontalVerticalCard extends StatelessWidget {
  const _HorizontalVerticalCard({required this.item});

  final _ServiceVerticalData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
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
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Left: Card Image with Badge Overlay ──────────────────────────
            SizedBox(
              width: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImageWidget(item.imageUrl),
                  if (item.badgeText.isNotEmpty)
                    Positioned(
                      top: 5,
                      left: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x18000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          item.badgeText,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: item.color,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // ── Center: Title, Description & Tags ─────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (item.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: item.tags.take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── Right: Chevron Arrow ─────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
        loadingBuilder: (_, child, prog) {
          if (prog == null) return child;
          return _buildPlaceholder();
        },
      );
    }
    final assetPath = path.startsWith('/') ? path.substring(1) : path;
    if (assetPath.startsWith('assets/')) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: item.bgColor,
      child: Center(
        child: Icon(
          item.fallbackIcon,
          color: item.color,
          size: 28,
        ),
      ),
    );
  }
}

// ── Horizontal Category Search Result Card ────────────────────────────────────

class _HorizontalCategorySearchResultCard extends StatelessWidget {
  const _HorizontalCategorySearchResultCard({required this.item});

  final ServiceCategoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: const Color(0xFF93C5FD)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: double.infinity,
            child: _buildImageWidget(item.imageUrl),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (item.desc.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.desc,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }
    final assetPath = path.startsWith('/') ? path.substring(1) : path;
    if (assetPath.startsWith('assets/')) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: item.bgColor,
      child: Center(
        child: Icon(
          item.fallbackIcon,
          color: item.color,
          size: 24,
        ),
      ),
    );
  }
}

// ── Trust Pillar Helper Widget ────────────────────────────────────────────────

class _TrustPillar extends StatelessWidget {
  const _TrustPillar({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
