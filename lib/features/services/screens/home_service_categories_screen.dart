import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_services_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/common_widgets.dart';
import 'category_detail_screen.dart';

/// Screen 2 of the Home Service vertical: Service's Categories
/// Matches the web explore_service.jsx "home_care" view showing all
/// home service sub-categories (AC, Electrical, Plumbing, RO, Geyser, etc.)
class HomeServiceCategoriesScreen extends StatefulWidget {
  const HomeServiceCategoriesScreen({
    super.key,
    this.serviceTitle = 'Doorstep Home Services & Repairs',
    this.serviceSubtitle =
        'Select a category below to view services, inspect coverage, and book verified professionals instantly.',
  });

  final String serviceTitle;
  final String serviceSubtitle;

  @override
  State<HomeServiceCategoriesScreen> createState() =>
      _HomeServiceCategoriesScreenState();
}

class _HomeServiceCategoriesScreenState
    extends State<HomeServiceCategoriesScreen> {
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
    } catch (_) {
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
                const SizedBox(height: AppSpacing.sm),

                // ── Top Navigation Bar: Back Button + Header ─────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AppBackButton(
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.serviceTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.h2.copyWith(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.serviceSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                          'Search home categories (AC, plumbing, electrical, etc.)',
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

                // ── Section Title & Category Count ───────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Home Service Categories',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 17,
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

                // ── Category Cards List ───────────────────────────────────────
                if (filteredCategories.isEmpty)
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
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No categories found matching "$_searchQuery"',
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try searching for "AC", "Plumbing", "Electrical", etc.',
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
                    itemCount: filteredCategories.length,
                    separatorBuilder: (_, i) =>
                        const SizedBox(height: AppSpacing.sm),
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
                        child: _HomeCategoryHorizontalCard(item: item),
                      );
                    },
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

class _HomeCategoryHorizontalCard extends StatelessWidget {
  const _HomeCategoryHorizontalCard({required this.item});

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

          // ── Center: Title & Description ─────────────────────────────────────
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
