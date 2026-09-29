import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'service_detail_overview_screen.dart';

/// Screen displaying sub-services for a selected category in the exact same
/// horizontal card format, with interactive booking slots bottom sheet.
class SubServicesScreen extends StatelessWidget {
  const SubServicesScreen({
    super.key,
    required this.categoryTitle,
    this.categorySubtitle,
  });

  final String categoryTitle;
  final String? categorySubtitle;

  List<_SubServiceDetailItem> _getItemsForCategory() {
    switch (categoryTitle) {
      case 'Food Delivery':
        return const [
          _SubServiceDetailItem(
            title: 'Daily Home-Style Tiffin Service',
            description: '4 Rotis, Seasonal Sabzi, Dal, Jeera Rice, Fresh Salad',
            imageUrl:
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹120 / meal', 'Pure Veg & Non-Veg', 'Daily Tiffin'],
            fallbackIcon: Icons.restaurant_rounded,
            price: '₹120',
          ),
          _SubServiceDetailItem(
            title: 'North & South Indian Meal Combos',
            description: 'Chicken Curry, Paneer Butter Masala, Biryani Combos',
            imageUrl:
                'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹180', 'Hot Delivery', 'Chef Curated'],
            fallbackIcon: Icons.lunch_dining_rounded,
            price: '₹180',
          ),
          _SubServiceDetailItem(
            title: 'Healthy Diet & High-Protein Bowls',
            description: 'Sprouts, Grilled Paneer/Chicken, Fresh Fruits, Juices',
            imageUrl:
                'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹150', 'Organic', 'Low Calorie'],
            fallbackIcon: Icons.eco_rounded,
            price: '₹150',
          ),
        ];

      case 'Bike & Cab Service':
      case 'Bike & Cab':
        return const [
          _SubServiceDetailItem(
            title: 'Doorstep Bike General Service',
            description: 'Engine oil change, brake tuning, carburetor & wash',
            imageUrl:
                'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹399', '45 Mins', 'Genuine Oil'],
            fallbackIcon: Icons.two_wheeler_rounded,
            price: '₹399',
          ),
          _SubServiceDetailItem(
            title: 'Local City Cab / Auto Dispatch',
            description: 'Instant pickup, AC Hatchback & Sedan, verified drivers',
            imageUrl:
                'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['Instant', 'Zero Surge', 'GPS Monitored'],
            fallbackIcon: Icons.local_taxi_rounded,
            price: '₹149 Base',
          ),
          _SubServiceDetailItem(
            title: 'Inter-District Outstation Cab',
            description: 'Round trip & one-way with commercial permit vehicles',
            imageUrl:
                'https://images.unsplash.com/photo-1502877338535-766e1452684a?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹12 / km', 'Chauffeur', '24/7 Available'],
            fallbackIcon: Icons.directions_car_filled_rounded,
            price: '₹12/km',
          ),
        ];

      case 'Emergency Ambulance':
      case 'Ambulance SOS':
      case 'Ambulance':
        return const [
          _SubServiceDetailItem(
            title: 'Basic Life Support (BLS) Ambulance',
            description: 'Oxygen cylinder, stretcher, paramedic, first-aid kit',
            imageUrl:
                'https://images.unsplash.com/photo-1587745416684-47953f16f02f?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['15 Mins ETA', 'Oxygen Ready', 'Trained Paramedic'],
            fallbackIcon: Icons.emergency_rounded,
            price: 'Emergency SOS',
          ),
          _SubServiceDetailItem(
            title: 'Advanced ICU on Wheels (ALS)',
            description: 'Ventilator, cardiac monitor, suction machine, doctor',
            imageUrl:
                'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['ICU Setup', 'Doctor Onboard', 'Priority Green Corridor'],
            fallbackIcon: Icons.local_hospital_rounded,
            price: 'Priority Call',
          ),
        ];

      case 'Medicine Delivery':
        return const [
          _SubServiceDetailItem(
            title: 'Prescription Medicine Delivery',
            description: 'Upload doctor prescription for flat 20% off on all medicines',
            imageUrl:
                'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['Flat 20% Off', '2 Hours Delivery', 'Verified Pharmacy'],
            fallbackIcon: Icons.medication_rounded,
            price: '20% Discount',
          ),
          _SubServiceDetailItem(
            title: 'Daily Healthcare & OTC Products',
            description: 'Vitamins, pain relief, baby care, sanitizers, BP monitors',
            imageUrl:
                'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['Free Delivery', 'Same Day', '100% Genuine'],
            fallbackIcon: Icons.health_and_safety_rounded,
            price: 'Best Price',
          ),
        ];

      case 'Room Booking':
        return const [
          _SubServiceDetailItem(
            title: 'Verified Executive PG & Hostels',
            description: 'Furnished single/sharing room, WiFi, food, housekeeping',
            imageUrl:
                'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Coming Soon',
            badgeType: _BadgeType.comingSoon,
            tags: ['₹4,500 / mo', 'No Brokerage', 'WiFi Included'],
            fallbackIcon: Icons.hotel_rounded,
            price: '₹4,500/mo',
          ),
          _SubServiceDetailItem(
            title: 'Budget & Premium Hotel Day Stays',
            description: 'AC room, attached bath, TV, room service, instant check-in',
            imageUrl:
                'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Coming Soon',
            badgeType: _BadgeType.comingSoon,
            tags: ['₹899 / night', 'Couple Friendly', 'Clean Rooms'],
            fallbackIcon: Icons.king_bed_rounded,
            price: '₹899/night',
          ),
        ];

      case 'Event Booking (Birthday, Marriage, Rice ceremony)':
      case 'Any Kind of Event Booking':
      case 'Event Booking':
        return const [
          _SubServiceDetailItem(
            title: 'Birthday & Anniversary Event Setup',
            description: 'Theme balloon decoration, LED lights, DJ sound, cake table',
            imageUrl:
                'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Coming Soon',
            badgeType: _BadgeType.comingSoon,
            tags: ['Custom Themes', 'Full Setup', 'Photography'],
            fallbackIcon: Icons.celebration_rounded,
            price: 'Custom Quote',
          ),
          _SubServiceDetailItem(
            title: 'Wedding & Rice Ceremony Catering',
            description: 'Authentic multi-course Bengali & North Indian buffet menu',
            imageUrl:
                'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Coming Soon',
            badgeType: _BadgeType.comingSoon,
            tags: ['Per Plate Basis', 'Trained Waiters', 'Hygiene Assured'],
            fallbackIcon: Icons.dinner_dining_rounded,
            price: 'Per Plate',
          ),
        ];

      case 'QUICKOX ELECTRA Scooty':
      case 'Electra Scooty':
      case 'ELECTRA Scooty':
        return const [
          _SubServiceDetailItem(
            title: 'Doorstep Electric Scooty Test Ride',
            description: 'Free doorstep test ride with product specialist explanation',
            imageUrl:
                'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Coming Soon',
            badgeType: _BadgeType.comingSoon,
            tags: ['Free Test Ride', 'Doorstep', '120 KM Range'],
            fallbackIcon: Icons.electric_moped_rounded,
            price: 'Free',
          ),
          _SubServiceDetailItem(
            title: 'EV Battery & Motor Diagnostic',
            description: 'Full battery health checkup, controller tuning, brakes',
            imageUrl:
                'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Coming Soon',
            badgeType: _BadgeType.comingSoon,
            tags: ['₹299', 'Certified Tech', 'Quick Fix'],
            fallbackIcon: Icons.battery_charging_full_rounded,
            price: '₹299',
          ),
        ];

      // Default: Home Service
      default:
        return const [
          _SubServiceDetailItem(
            title: 'AC Deep Clean & Jet Wash Service',
            description:
                'Indoor & outdoor unit high-pressure jet wash, gas check & cooling coil sanitization',
            imageUrl:
                'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹599', '45 Mins', '30-Day Warranty'],
            fallbackIcon: Icons.ac_unit_rounded,
            price: '₹599',
          ),
          _SubServiceDetailItem(
            title: 'Switchboard & Electrical Wiring',
            description:
                'Short circuit fix, socket replacement, fuse repair & whole home safety inspection',
            imageUrl:
                'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹149', '30 Mins', 'Certified Expert'],
            fallbackIcon: Icons.bolt_rounded,
            price: '₹149',
          ),
          _SubServiceDetailItem(
            title: 'Plumbing & Pipe Leakage Repair',
            description:
                'Water tap repair, blockages clearance, leakage repair & drainage pipe cleaning',
            imageUrl:
                'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹199', '30 Mins', 'Verified Plumber'],
            fallbackIcon: Icons.water_drop_rounded,
            price: '₹199',
          ),
          _SubServiceDetailItem(
            title: 'RO Water Purifier Service & Filter Change',
            description:
                'Sediment and carbon filter replacement, membrane check, TDS level calibration',
            imageUrl:
                'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹499', '45 Mins', 'Genuine Filters'],
            fallbackIcon: Icons.water_damage_rounded,
            price: '₹499',
          ),
          _SubServiceDetailItem(
            title: 'Washing Machine Diagnostic & Repair',
            description:
                'Drum vibration fix, spin cycle issue, water inlet motor check, motherboard repair',
            imageUrl:
                'https://images.unsplash.com/photo-1610557892470-55d9e80c0bce?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹299', '60 Mins', '30-Day Warranty'],
            fallbackIcon: Icons.local_laundry_service_rounded,
            price: '₹299',
          ),
          _SubServiceDetailItem(
            title: 'Geyser & Water Heater Repair',
            description:
                'Heating coil replacement, thermostat repair, water leakage, tank cleaning',
            imageUrl:
                'https://images.unsplash.com/photo-1585338107529-13afc5f02586?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹349', '40 Mins', 'Quick Fix'],
            fallbackIcon: Icons.electric_bolt_rounded,
            price: '₹349',
          ),
          _SubServiceDetailItem(
            title: 'Refrigerator Repair, Installation Solutions',
            description:
                'Diagnose and fix common refrigerator problems, repair refrigerator along with installation service',
            imageUrl:
                'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=600&q=80',
            badgeText: 'Live Now',
            badgeType: _BadgeType.liveNow,
            tags: ['₹299', '45 Mins', '30-Day Warranty'],
            fallbackIcon: Icons.kitchen_rounded,
            price: '₹299',
          ),
        ];
    }
  }

  void _handleCardTap(BuildContext context, _SubServiceDetailItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceDetailOverviewScreen(
          serviceTitle: item.title,
          serviceSubtitle: item.description,
          parentCategory: categoryTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItemsForCategory();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar: Back Button + Title & Subtitle ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bgSecondary,
                        border: Border.all(color: AppColors.border),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, right: 28),
                      child: Column(
                        children: [
                          Text(
                            categoryTitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h3.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            categorySubtitle ??
                                'Select a service below to view pricing, inspect coverage, and book verified professionals instantly.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySm.copyWith(
                              fontSize: 11.5,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Divider(color: AppColors.border, height: 1),

            // ── Horizontal Cards List (Exact Same Format) ───────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: items.length,
                separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: () => _handleCardTap(context, item),
                    child: _SubServiceHorizontalCard(item: item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private Helper Widgets ────────────────────────────────────────────────────

enum _BadgeType { liveNow, comingSoon }

class _SubServiceDetailItem {
  const _SubServiceDetailItem({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.badgeText,
    required this.badgeType,
    required this.tags,
    required this.fallbackIcon,
    required this.price,
  });

  final String title;
  final String description;
  final String imageUrl;
  final String? badgeText;
  final _BadgeType badgeType;
  final List<String> tags;
  final IconData fallbackIcon;
  final String price;
}

class _SubServiceHorizontalCard extends StatelessWidget {
  const _SubServiceHorizontalCard({required this.item});

  final _SubServiceDetailItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 106,
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
          // ── Left: Image with Badge Overlay ────────────────────────────────
          SizedBox(
            width: 128,
            height: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, e, s) => Container(
                    color: AppColors.bgTertiary,
                    child: Center(
                      child: Icon(
                        item.fallbackIcon,
                        color: AppColors.textMuted,
                        size: 36,
                      ),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.bgTertiary,
                      child: const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Top-left Badge
                if (item.badgeText != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2.5,
                      ),
                      decoration: BoxDecoration(
                        color: item.badgeType == _BadgeType.liveNow
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: item.badgeType == _BadgeType.liveNow
                              ? const Color(0xFF86EFAC)
                              : const Color(0xFFFDE68A),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (item.badgeType == _BadgeType.liveNow)
                            Container(
                              width: 5.5,
                              height: 5.5,
                              margin: const EdgeInsets.only(right: 3.5),
                              decoration: const BoxDecoration(
                                color: Color(0xFF16A34A),
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const Padding(
                              padding: EdgeInsets.only(right: 3.5),
                              child: Icon(
                                Icons.access_time_rounded,
                                size: 9.5,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          Text(
                            item.badgeText!,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: item.badgeType == _BadgeType.liveNow
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Right: Content & Arrow ────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title + Subtitle and Circular Chevron
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySm.copyWith(
                                fontSize: 10.5,
                                height: 1.25,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
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

                  // Pill Tags Row
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    children: item.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
