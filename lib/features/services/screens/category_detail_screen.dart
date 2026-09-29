import 'package:flutter/material.dart';
import '../../../core/services/firebase_services_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'service_detail_overview_screen.dart';

/// Screen 2: Filtered Category Services Grid
/// Exactly matches home_service_web/src/features/services/service_category_screen.jsx
/// with search box, frequency pills (All / One-Time / Monthly), counter,
/// and dynamic service cards loaded from Firebase Firestore backend.
class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    this.categoryName = 'Doorstep Home Services & Repairs',
    this.headerTitle,
    this.headerSubtitle,
  });

  final String categoryName;
  final String? headerTitle;
  final String? headerSubtitle;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseServicesService _servicesService = FirebaseServicesService();

  String _searchQuery = '';
  String _activeFrequency = 'All'; // 'All', 'One-Time', 'Monthly'
  late List<ServiceItem> _services;
  bool _isLoading = false;
  bool _isSearchOpen = false;

  @override
  void initState() {
    super.initState();
    final initialList = FirebaseServicesService.defaultServices.where((s) {
      final c = widget.categoryName.toLowerCase();
      return s.category.toLowerCase().contains(c) ||
          c.contains(s.category.toLowerCase()) ||
          s.categoryId.toLowerCase().contains(c);
    }).toList();
    _services = initialList.isNotEmpty
        ? initialList
        : FirebaseServicesService.defaultServices;
    _loadServices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadServices() async {
    try {
      final list = await _servicesService.fetchServicesForCategory(
        categoryName: widget.categoryName,
        frequency: _activeFrequency,
        query: _searchQuery,
      );
      if (mounted && list.isNotEmpty) {
        setState(() {
          _services = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onFrequencyChanged(String freq) {
    if (_activeFrequency == freq) return;
    setState(() {
      _activeFrequency = freq;
    });
    _loadServices();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadServices();
  }

  void _handleReset() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _activeFrequency = 'All';
      _isSearchOpen = false;
    });
    _loadServices();
  }

  String _formatCategoryTitle() {
    final cat = widget.headerTitle ?? widget.categoryName;
    if (cat.toLowerCase().contains('service') ||
        cat.toLowerCase().contains('repair')) {
      return cat;
    }
    return '$cat Services';
  }

  @override
  Widget build(BuildContext context) {
    final title = _formatCategoryTitle();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadServices,
          color: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Navigation Bar (Header with Title Left & Search Right) ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: _isSearchOpen
                    ? _buildSearchHeader(title)
                    : _buildDefaultHeader(title),
              ),

              // ── Filter Options (All Service, One-Time, Monthly) ─────────────
              _buildFilterOptions(),

              // ── Active Filter & Results Counter Bar ─────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'Results for "$_searchQuery"'
                            : _activeFrequency == 'All'
                                ? 'All Available Services'
                                : '$_activeFrequency Services',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${_services.length} ',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                          TextSpan(
                            text: _services.length == 1 ? 'service' : 'services',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable Body with Services List ──────────────────────────
              Expanded(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  children: [
                    // Services Cards List
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    else if (_services.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No Services Found for $title',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.labelMd.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try changing your search query or switching filter options.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: _handleReset,
                              child: const Text('View All Services'),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _services.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final svc = _services[index];
                          return _ServiceGridCard(
                            service: svc,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailOverviewScreen(
                                    service: svc,
                                    serviceTitle: svc.title,
                                    serviceSubtitle: svc.desc,
                                    parentCategory: widget.categoryName,
                                    relatedServicesList: _services,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header Builders ─────────────────────────────────────────────────────────

  Widget _buildCircleButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  Widget _buildDefaultHeader(String title) {
    return Row(
      children: [
        _buildCircleButton(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.left,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildCircleButton(
          onTap: () {
            setState(() => _isSearchOpen = true);
          },
          child: const Icon(
            Icons.search_rounded,
            size: 20,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader(String title) {
    return Row(
      children: [
        _buildCircleButton(
          onTap: () {
            setState(() {
              _isSearchOpen = false;
              _searchQuery = '';
              _searchController.clear();
            });
            _loadServices();
          },
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Search $title...',
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _buildCircleButton(
          onTap: () {
            setState(() {
              _isSearchOpen = false;
              _searchQuery = '';
              _searchController.clear();
            });
            _loadServices();
          },
          child: const Icon(
            Icons.close_rounded,
            size: 20,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  // ── Modern Filter Options Row ───────────────────────────────────────────────

  Widget _buildFilterOptions() {
    final options = [
      {
        'id': 'All',
        'label': 'All Services',
        'icon': Icons.grid_view_rounded,
        'inactiveIconColor': const Color(0xFF64748B),
      },
      {
        'id': 'One-Time',
        'label': 'One-Time Service',
        'icon': Icons.bolt_rounded,
        'inactiveIconColor': const Color(0xFF2563EB),
      },
      {
        'id': 'Monthly',
        'label': 'Monthly Service',
        'icon': Icons.calendar_today_rounded,
        'inactiveIconColor': const Color(0xFF475569),
      },
    ];

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: options.map((opt) {
            final isSelected = _activeFrequency == opt['id'];
            final isLast = opt['id'] == options.last['id'];
            final iconColor = isSelected
                ? Colors.white
                : (opt['inactiveIconColor'] as Color);

            return Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 10),
              child: InkWell(
                onTap: () => _onFrequencyChanged(opt['id'] as String),
                borderRadius: BorderRadius.circular(24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1E60F9) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1E60F9)
                          : const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF1E60F9).withValues(alpha: 0.28),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x06000000),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        opt['icon'] as IconData,
                        size: 15,
                        color: iconColor,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        opt['label'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Private Service Grid Card (matching service_category_screen.jsx) ─────────

class _ServiceGridCard extends StatelessWidget {
  const _ServiceGridCard({
    required this.service,
    required this.onTap,
  });

  final ServiceItem service;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Image with Rating Badge ─────────────────────────────────────
          SizedBox(
            height: 165,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (service.imageUrl.startsWith('http'))
                  Image.network(
                    service.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
                  )
                else
                  Image.asset(
                    service.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
                  ),

                // Top-right Rating Pill
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x18000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: Color(0xFFF59E0B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          service.rating,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Card Details Body ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  service.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),

                // Badges row: Verified + Frequency
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    // Verified Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: Color(0xFF10B981),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Frequency Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: service.frequency.toLowerCase().contains('month')
                            ? const Color(0xFFF5F3FF)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            service.frequency.toLowerCase().contains('month')
                                ? Icons.calendar_month_rounded
                                : Icons.bolt_rounded,
                            size: 13,
                            color: service.frequency
                                    .toLowerCase()
                                    .contains('month')
                                ? const Color(0xFF7C3AED)
                                : const Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            service.frequency.toLowerCase().contains('month')
                                ? 'Monthly Sub'
                                : 'One-Time',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: service.frequency
                                      .toLowerCase()
                                      .contains('month')
                                  ? const Color(0xFF7C3AED)
                                  : const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Description
                Text(
                  service.desc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 16),

                // Price and View Service CTA Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Starting at',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            service.price,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: service.price.length > 20 ? 15 : 19,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1E60F9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onTap,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E60F9),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E60F9).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'View Service',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
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
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFF0F172A),
      child: Center(
        child: Text(
          service.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
