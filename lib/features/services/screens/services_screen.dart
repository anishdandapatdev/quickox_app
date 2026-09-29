import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_services_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'category_detail_screen.dart';

/// Service Categories Catalog Screen matching the website explore_service.jsx
/// and connected to Firebase Firestore backend with dynamic loading and pull-to-refresh.
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
  List<ServiceCategoryItem> _categories =
      FirebaseServicesService.defaultCategories;
  bool _isLoading = false;

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
          _categories = homeOnly;
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

  @override
  Widget build(BuildContext context) {
    final activeList = _categories.isNotEmpty
        ? _categories.where((c) =>
            FirebaseServicesService.isHomeServiceCategory(c.id) &&
            FirebaseServicesService.isHomeServiceCategory(c.title)).toList()
        : FirebaseServicesService.defaultCategories;

    final filteredCategories = _searchQuery.isEmpty
        ? activeList
        : activeList.where((c) {
            final q = _searchQuery.toLowerCase();
            return c.title.toLowerCase().contains(q) ||
                c.desc.toLowerCase().contains(q) ||
                c.tags.any((t) => t.toLowerCase().contains(q));
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
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search home services (AC repair, plumbing, etc.)',
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
                            horizontal: 10,
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
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Book Inspection',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
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
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 8,
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
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Membership Plans',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
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

                // ── Section Title: Explore All Service Categories ──────────────
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
                        '${filteredCategories.length} categories',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Category Cards List (Card image + title name cleanly) ─────
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCategories.length,
                  separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = filteredCategories[index];
                    return GestureDetector(
                      onTap: () {
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
                      child: _HorizontalCategoryCard(item: item),
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

// ── Private Clean Card Helper Widgets ─────────────────────────────────────────

class _HorizontalCategoryCard extends StatelessWidget {
  const _HorizontalCategoryCard({required this.item});

  final ServiceCategoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
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
      child: Row(
        children: [
          // ── Left: Card Image ────────────────────────────────────────────────
          SizedBox(
            width: 104,
            height: double.infinity,
            child: _buildImageWidget(item.imageUrl),
          ),
          const SizedBox(width: 14),

          // ── Center: Title Name (clean image + title style) ───────────────────
          Expanded(
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
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.desc.isNotEmpty) ...[
                  const SizedBox(height: 3),
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

          // ── Right: Chevron Arrow ───────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(right: 12),
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
