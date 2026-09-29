import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Super App Service Vertical Model matching explore_service.jsx & multiServiceData.js
class ServiceVerticalItem {
  final String id;
  final String name;
  final String tagline;
  final String badgeText;
  final bool isLive;
  final String imageUrl;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<String> tags;

  const ServiceVerticalItem({
    required this.id,
    required this.name,
    required this.tagline,
    required this.badgeText,
    this.isLive = true,
    required this.imageUrl,
    required this.icon,
    required this.color,
    required this.bgColor,
    this.tags = const [],
  });
}

/// Category Model matching Firestore 'serviceCategories' and explore_service.jsx
class ServiceCategoryItem {
  final String id;
  final String title;
  final String desc;
  final String imageUrl;
  final String? badgeText;
  final int sortOrder;
  final List<String> tags;
  final IconData fallbackIcon;
  final Color color;
  final Color bgColor;

  const ServiceCategoryItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.imageUrl,
    this.badgeText,
    this.sortOrder = 0,
    this.tags = const [],
    this.fallbackIcon = Icons.home_repair_service_rounded,
    this.color = const Color(0xFF2563EB),
    this.bgColor = const Color(0xFFEFF6FF),
  });
}

/// Service Detail Components matching Firestore 'serviceDetails' and service_detail_screen.jsx
class ServiceInclusion {
  final String title;
  final String desc;
  final IconData icon;

  const ServiceInclusion({
    required this.title,
    required this.desc,
    this.icon = Icons.check_circle_outline_rounded,
  });
}

class ServiceFaq {
  final String question;
  final String answer;

  const ServiceFaq({
    required this.question,
    required this.answer,
  });
}

class ServiceStep {
  final String step;
  final String title;
  final String desc;
  final IconData icon;

  const ServiceStep({
    required this.step,
    required this.title,
    required this.desc,
    this.icon = Icons.schedule_rounded,
  });
}

class ServiceMetric {
  final String label;
  final String value;
  final IconData icon;

  const ServiceMetric({
    required this.label,
    required this.value,
    this.icon = Icons.star_rounded,
  });
}

class ServiceDetailModel {
  final String heroTitle;
  final String heroDesc;
  final String technicianImageUrl;
  final String emergencyPhone;
  final String emergencyWhatsApp;
  final String bookCTALabel;
  final String partsCTALabel;
  final List<String> featurePills;
  final List<ServiceInclusion> inclusions;
  final List<ServiceFaq> faqs;
  final List<ServiceStep> howItWorks;
  final List<ServiceMetric> metrics;

  const ServiceDetailModel({
    required this.heroTitle,
    required this.heroDesc,
    this.technicianImageUrl = '',
    this.emergencyPhone = '+919046599109',
    this.emergencyWhatsApp = '+919046599109',
    this.bookCTALabel = 'Book Technician',
    this.partsCTALabel = 'Shop Parts',
    this.featurePills = const [
      'Verified Professionals',
      'On-time Service',
      'Warranty Assured',
      'Transparent Pricing',
    ],
    this.inclusions = const [],
    this.faqs = const [],
    this.howItWorks = const [],
    this.metrics = const [],
  });
}

/// Model representing a Dynamic Service matching Firestore and explore_service.jsx
class ServiceItem {
  final String id;
  final String title;
  final String desc;
  final String category;
  final String categoryId;
  final String price;
  final String? originalPrice;
  final String rating;
  final String frequency;
  final String imageUrl;
  final String tag;

  const ServiceItem({
    required this.id,
    required this.title,
    required this.desc,
    required this.category,
    required this.categoryId,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.frequency,
    required this.imageUrl,
    this.tag = 'Popular',
  });

  ServiceItem copyWith({
    String? id,
    String? title,
    String? desc,
    String? category,
    String? categoryId,
    String? price,
    String? originalPrice,
    String? rating,
    String? frequency,
    String? imageUrl,
    String? tag,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      frequency: frequency ?? this.frequency,
      imageUrl: imageUrl ?? this.imageUrl,
      tag: tag ?? this.tag,
    );
  }
}

/// Firebase Service connecting to the 'home-service-haldia' Firestore collections:
/// - 'services'
/// - 'serviceCategories'
/// - 'medicine_categories'
/// Mirrors home_service_web/src/features/services/explore_service.jsx & multiServiceData.js.
class FirebaseServicesService {
  static const String projectId = 'home-service-haldia';
  static const String firestoreBaseUrl =
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents';

  final http.Client _client;

  FirebaseServicesService({http.Client? client})
      : _client = client ?? http.Client();

  /// Default 8 Super App Service Verticals matching explore_service.jsx & multiServiceData.js
  static const List<ServiceVerticalItem> defaultVerticals = [
    ServiceVerticalItem(
      id: 'home_care',
      name: 'Home Service',
      tagline: 'AC, Electrical, Plumbing, RO & Appliance Repairs',
      badgeText: 'Live Now',
      isLive: true,
      imageUrl: 'assets/images/icon_home_service.png',
      icon: Icons.home_repair_service_rounded,
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFF1F3F6),
      tags: ['AC Jet Wash', 'Plumbing', 'Electrician'],
    ),
    ServiceVerticalItem(
      id: 'medicine_delivery',
      name: 'Medicine Delivery',
      tagline: 'Prescription Rx, Pain Relief, First Aid & Wellness',
      badgeText: 'Live Now',
      isLive: true,
      imageUrl: 'assets/images/icon_medicine_delivery.png',
      icon: Icons.medication_rounded,
      color: Color(0xFF059669),
      bgColor: Color(0xFFF1F3F6),
      tags: ['30-Min Delivery', 'Rx Upload', 'First Aid'],
    ),
    ServiceVerticalItem(
      id: 'food_delivery',
      name: 'Food Delivery',
      tagline: 'Tiffin, Home Cooked Meals & Cloud Kitchens',
      badgeText: 'Live Now',
      isLive: true,
      imageUrl: 'assets/images/icon_food_delivery.png',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFEA580C),
      bgColor: Color(0xFFF1F3F6),
      tags: ['Home Food', 'Tiffin', 'Restaurants'],
    ),
    ServiceVerticalItem(
      id: 'bike_cab',
      name: 'Bike & Cab Service',
      tagline: 'Instant Affordable City Commute, Taxis & Autos',
      badgeText: 'From ₹25',
      isLive: true,
      imageUrl: 'assets/images/icon_bike_cab.png',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF0891B2),
      bgColor: Color(0xFFF1F3F6),
      tags: ['Bike Taxi', 'Auto', 'Cab Mini'],
    ),
    ServiceVerticalItem(
      id: 'ambulance',
      name: 'Emergency Ambulance',
      tagline: '24/7 Rapid Medical Dispatch & ICU on Wheels',
      badgeText: 'SOS 24/7',
      isLive: true,
      imageUrl: 'https://images.unsplash.com/photo-1587745416684-47953f16f02f?w=300&auto=format&fit=crop&q=80',
      icon: Icons.medical_services_rounded,
      color: Color(0xFFDC2626),
      bgColor: Color(0xFFFEF2F2),
      tags: ['10-15 Min ETA', 'Oxygen & ICU', 'Paramedics'],
    ),
    ServiceVerticalItem(
      id: 'room_booking',
      name: 'Room Booking',
      tagline: 'Hotels, PG, Guest House & Student Rentals',
      badgeText: 'Coming Soon',
      isLive: false,
      imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=300&auto=format&fit=crop&q=80',
      icon: Icons.hotel_rounded,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
      tags: ['Hotels', 'PG Stays', 'Guest House'],
    ),
    ServiceVerticalItem(
      id: 'electra_scooty',
      name: 'Electra Scooty',
      tagline: 'Smart Electric Scooters & Battery Swap Network',
      badgeText: 'Coming Soon',
      isLive: false,
      imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=300&auto=format&fit=crop&q=80',
      icon: Icons.electric_scooter_rounded,
      color: Color(0xFF0D9488),
      bgColor: Color(0xFFF0FDFA),
      tags: ['Eco Rides', 'Battery Swap', 'Smart EV'],
    ),
    ServiceVerticalItem(
      id: 'event_booking',
      name: 'Event Booking',
      tagline: 'Marriage, Birthday, Rice Ceremony & Mandap Decor',
      badgeText: 'Coming Soon',
      isLive: false,
      imageUrl: 'https://images.unsplash.com/photo-1519741497674-611481863552?w=300&auto=format&fit=crop&q=80',
      icon: Icons.celebration_rounded,
      color: Color(0xFF9333EA),
      bgColor: Color(0xFFFAF5FF),
      tags: ['Weddings', 'Catering', 'Floral Decor'],
    ),
  ];

  /// Fetches service verticals dynamically from Firebase backend with fallback
  Future<List<ServiceVerticalItem>> fetchVerticals() async {
    try {
      // Connect to Firestore serviceCategories and medicine_categories to verify backend stats
      final catUri = Uri.parse('$firestoreBaseUrl/serviceCategories?pageSize=20');
      final medUri = Uri.parse('$firestoreBaseUrl/medicine_categories?pageSize=20');

      final responses = await Future.wait([
        _client.get(catUri).timeout(const Duration(seconds: 4)).catchError((_) => http.Response('{}', 500)),
        _client.get(medUri).timeout(const Duration(seconds: 4)).catchError((_) => http.Response('{}', 500)),
      ]);

      int homeServiceCatCount = 0;
      int medicineCatCount = 0;

      if (responses[0].statusCode == 200) {
        final data = json.decode(responses[0].body) as Map<String, dynamic>;
        homeServiceCatCount = (data['documents'] as List<dynamic>?)?.length ?? 0;
      }

      if (responses[1].statusCode == 200) {
        final data = json.decode(responses[1].body) as Map<String, dynamic>;
        medicineCatCount = (data['documents'] as List<dynamic>?)?.length ?? 0;
      }

      return defaultVerticals.map((vert) {
        if (vert.id == 'home_care' && homeServiceCatCount > 0) {
          return ServiceVerticalItem(
            id: vert.id,
            name: vert.name,
            tagline: '$homeServiceCatCount+ Categories • 50+ Doorstep Services',
            badgeText: 'Live Now',
            isLive: true,
            imageUrl: vert.imageUrl,
            icon: vert.icon,
            color: vert.color,
            bgColor: vert.bgColor,
            tags: ['AC Jet Wash', 'Plumbing', 'Electrician'],
          );
        }
        if (vert.id == 'medicine_delivery' && medicineCatCount > 0) {
          return ServiceVerticalItem(
            id: vert.id,
            name: vert.name,
            tagline: '$medicineCatCount+ Categories • Express 30m Doorstep',
            badgeText: 'Live Now',
            isLive: true,
            imageUrl: vert.imageUrl,
            icon: vert.icon,
            color: vert.color,
            bgColor: vert.bgColor,
            tags: ['30-Min Delivery', 'Rx Upload', 'First Aid'],
          );
        }
        return vert;
      }).toList();
    } catch (e) {
      debugPrint('FirebaseServicesService: fetchVerticals error: $e');
      return defaultVerticals;
    }
  }

  /// Default 13 fallback services matching explore_service.jsx lines 75-219
  static const List<ServiceItem> defaultServices = [
    ServiceItem(
      id: '1',
      title: 'AC Deep Jet Cleaning & Servicing',
      desc:
          'Intense high-pressure jet pump cleaning of indoor cooling coils, filters, drainage tray, and outdoor unit.',
      category: 'AC',
      categoryId: 'AC',
      price: '₹ 499/-',
      originalPrice: '₹ 699/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'assets/images/ac.png',
      tag: 'Best Seller',
    ),
    ServiceItem(
      id: '2',
      title: 'AC Gas Leakage Check & Refilling',
      desc:
          'Complete electronic leak testing, nitrogen pressure test, and 100% genuine refrigerant gas refill.',
      category: 'AC',
      categoryId: 'AC',
      price: '₹ 1,499/-',
      originalPrice: '₹ 1,899/-',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'assets/images/ac.png',
      tag: 'Instant Visit',
    ),
    ServiceItem(
      id: '3',
      title: 'Switchboard & Socket Restoration',
      desc:
          'Fix loose wiring, burned socket modules, sparking master switches, and modular board installations.',
      category: 'Electrical',
      categoryId: 'Electrical',
      price: '₹ 199/-',
      originalPrice: '₹ 299/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'assets/images/electrician.png',
      tag: 'Fast Booking',
    ),
    ServiceItem(
      id: '4',
      title: 'Water Purifier RO Filter & Membrane Replacement',
      desc:
          'Sediment pre-filter, carbon block, RO membrane replacement, and digital TDS mineral balancing.',
      category: 'RO',
      categoryId: 'RO',
      price: '₹ 649/-',
      originalPrice: '₹ 899/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'assets/images/ro.png',
      tag: 'Top Rated',
    ),
    ServiceItem(
      id: '5',
      title: 'Complete Home Wiring Health Check',
      desc:
          'Earthing voltage testing, MCB distribution board load balance audit, and short-circuit prevention survey.',
      category: 'Electrical',
      categoryId: 'Electrical',
      price: '₹ 499/-',
      originalPrice: '₹ 699/-',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'assets/images/electrician.png',
      tag: 'Safety First',
    ),
    ServiceItem(
      id: '6',
      title: 'Pipe Leakage & Tap Valve Repair',
      desc:
          'Under-sink pipe repair, angle valve replacements, leaking faucets, mixer cartridge fixes, and sealant renewal.',
      category: 'Plumbing',
      categoryId: 'Plumbing',
      price: '₹ 199/-',
      originalPrice: '₹ 299/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'assets/images/plumbing.png',
      tag: 'Essential',
    ),
    ServiceItem(
      id: '7',
      title: 'Ceiling Fan Repair & Speed Regulator',
      desc:
          'Motor capacitor replacement, bearing noise lubrication, blade balancing, and electronic regulator fixes.',
      category: 'Ceiling Fan',
      categoryId: 'Ceiling Fan',
      price: '₹ 249/-',
      originalPrice: '₹ 349/-',
      rating: '4.7',
      frequency: 'One-Time',
      imageUrl: 'assets/images/products/fan_capacitor.jpg',
      tag: 'Recommended',
    ),
    ServiceItem(
      id: '8',
      title: 'Bathroom & Kitchen Drainage Clearing',
      desc:
          'High-pressure mechanized drain snake unblocking for sinks, shower drains, floor traps, and pipeline blockages.',
      category: 'Plumbing',
      categoryId: 'Plumbing',
      price: '₹ 399/-',
      originalPrice: '₹ 549/-',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'assets/images/plumbing.png',
      tag: 'Quick Response',
    ),
    ServiceItem(
      id: '9',
      title: 'Water Pump Motor Troubleshooting & Rewinding',
      desc:
          'Submersible & monoblock pump capacitor replacement, motor impeller cleaning, and auto-cut switch setup.',
      category: 'Water Pump',
      categoryId: 'Water Pump',
      price: '₹ 499/-',
      originalPrice: '₹ 699/-',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'assets/images/products/solar_junction_box.jpg',
      tag: 'Heavy Duty',
    ),
    ServiceItem(
      id: '10',
      title: 'Geyser Heating Element & Thermostat Check',
      desc:
          'Descaling geyser heating tank, heating rod replacement, thermostat safety cut-off test, and valve servicing.',
      category: 'Geyser',
      categoryId: 'Geyser',
      price: '₹ 449/-',
      originalPrice: '₹ 599/-',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'assets/images/refrigerator_technician.jpg',
      tag: 'Winter Ready',
    ),
    ServiceItem(
      id: '11',
      title: 'Door Lock, Hinge & Furniture Carpentry',
      desc:
          'Smart door lock installation, mortise lock repair, kitchen drawer sliders, and cabinet hinge adjustments.',
      category: 'Carpentry',
      categoryId: 'Carpentry',
      price: '₹ 299/-',
      originalPrice: '₹ 449/-',
      rating: '4.7',
      frequency: 'One-Time',
      imageUrl: 'assets/images/products/cctv_camera_mount.jpg',
      tag: 'Expert Care',
    ),
    ServiceItem(
      id: '12',
      title: 'AC Monthly Annual Maintenance',
      desc:
          'Periodic preventative inspection, quarterly filter washes, thermostat calibration, and emergency callouts.',
      category: 'AC',
      categoryId: 'AC',
      price: '₹ 299/mo',
      originalPrice: '₹ 399/mo',
      rating: '4.9',
      frequency: 'Monthly',
      imageUrl: 'assets/images/ac.png',
      tag: 'Care Plan',
    ),
    ServiceItem(
      id: '13',
      title: 'RO Purifier Comprehensive Monthly Care',
      desc:
          'Monthly water quality test, scheduled filter replacement, UV lamp inspection, and pump pressure testing.',
      category: 'RO',
      categoryId: 'RO',
      price: '₹ 199/mo',
      originalPrice: '₹ 299/mo',
      rating: '4.8',
      frequency: 'Monthly',
      imageUrl: 'assets/images/ro.png',
      tag: 'Care Plan',
    ),
  ];

  /// Fetches services dynamically from Firestore collection 'services' with fallback.
  Future<List<ServiceItem>> fetchServices({int? limit}) async {
    try {
      final uri = Uri.parse('$firestoreBaseUrl/services?pageSize=50');
      final response = await _client.get(uri).timeout(
            const Duration(seconds: 5),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? documents = data['documents'];

        if (documents != null && documents.isNotEmpty) {
          final List<ServiceItem> fetched = [];

          for (final doc in documents) {
            final fields = doc['fields'] as Map<String, dynamic>?;
            if (fields == null) continue;

            // Check isActive
            final bool isActive = _extractBool(fields['isActive'], true);
            if (!isActive) continue;

            final String docPath = doc['name'] as String? ?? '';
            final String id = docPath.split('/').last;

            final String title = _extractString(
              fields['title'] ?? fields['name'] ?? fields['serviceName'],
              fallback: 'Service',
            );

            final String desc = _extractString(
              fields['desc'] ?? fields['description'] ?? fields['shortDesc'],
              fallback: 'Professional doorstep service by verified technician.',
            );

            final String rawCategory = _extractString(
              fields['category'] ??
                  fields['categoryName'] ??
                  fields['categoryId'],
              fallback: 'General',
            );
            // Clean emoji prefix from category for cleaner tag display
            final String cleanCategory = _cleanCategoryName(rawCategory);

            final String rawPrice = _extractPrice(fields['price']);
            final String price = _normalizePrice(rawPrice, cleanCategory);

            final String rating = _extractString(
              fields['rating'],
              fallback: '4.8',
            );

            final String frequency = _extractString(
              fields['frequency'],
              fallback: 'One-Time',
            );

            final String rawImage = _extractString(
              fields['imageUrl'] ??
                  fields['image'] ??
                  fields['photo'] ??
                  fields['photoUrl'],
              fallback: '',
            );
            final String imageUrl = _resolveImageUrl(rawImage, cleanCategory);

            final String tag = _extractTag(fields['tags']);

            fetched.add(
              ServiceItem(
                id: id,
                title: title,
                desc: desc,
                category: cleanCategory,
                categoryId: cleanCategory.toLowerCase(),
                price: price,
                originalPrice: _computeOriginalPrice(price),
                rating: rating,
                frequency: frequency,
                imageUrl: imageUrl,
                tag: tag,
              ),
            );
          }

          if (fetched.isNotEmpty) {
            if (limit != null && limit > 0) {
              return fetched.take(limit).toList();
            }
            return fetched;
          }
        }
      }
    } catch (e) {
      debugPrint('FirebaseServicesService: fetchServices error: $e');
    }

    // Return fallback catalog if network fails or collection is empty
    if (limit != null && limit > 0) {
      return defaultServices.take(limit).toList();
    }
    return defaultServices;
  }

  // ──────────────────────────── Service Categories ──────────────────────────

  /// Checks whether a given category ID or title belongs strictly to Doorstep Home Services
  /// and excludes all other Super App verticals (Food Delivery, Bike & Cab, Ambulance,
  /// Medicine Delivery, Hotel/Room Booking, Electra Scooty, Event Booking).
  static bool isHomeServiceCategory(String idOrTitle) {
    final lower = idOrTitle.trim().toLowerCase();

    // Explicit exclusions for other Super App verticals
    if (lower.contains('food') ||
        lower.contains('restaurant') ||
        lower.contains('tiffin') ||
        lower.contains('biryani') ||
        lower.contains('meal') ||
        lower.contains('kitchen')) {
      return false;
    }
    if (lower.contains('bike') ||
        lower.contains('cab') ||
        lower.contains('sedan') ||
        lower.contains('ride') ||
        lower.contains('taxi') ||
        lower.contains('auto rickshaw')) {
      return false;
    }
    if (lower.contains('ambulance') ||
        lower.contains('emergency ambulance') ||
        lower.contains('icu on wheels') ||
        lower.contains('hospital') ||
        lower.contains('paramedic')) {
      return false;
    }
    if (lower.contains('medicine') ||
        lower.contains('pharmacy') ||
        lower.contains('prescription') ||
        lower.contains('otc')) {
      return false;
    }
    // Room cleaning is a home service, but room/hotel/homestay booking is not
    if ((lower.contains('room') ||
            lower.contains('hotel') ||
            lower.contains('pg stay') ||
            lower.contains('homestay') ||
            lower.contains('guest house')) &&
        !lower.contains('clean')) {
      return false;
    }
    if (lower.contains('electra') ||
        lower.contains('scooty') ||
        lower.contains('scooter') ||
        lower.contains('battery swap')) {
      return false;
    }
    if (lower.contains('event') ||
        lower.contains('marriage') ||
        lower.contains('wedding') ||
        lower.contains('annaprashan') ||
        lower.contains('rice ceremony') ||
        lower.contains('party decor')) {
      return false;
    }

    return true;
  }

  /// Default categories matching Doorstep Home Services in Firestore & explore_service.jsx
  static const List<ServiceCategoryItem> defaultCategories = [
    ServiceCategoryItem(
      id: 'AC',
      title: 'AC Service',
      desc: 'Deep jet wash, cooling coil sanitization, gas refill & repair',
      imageUrl: 'assets/images/ac.png',
      badgeText: 'Live Now',
      sortOrder: 1,
      tags: ['AC Jet Wash', 'Gas Refill', 'Maintenance'],
      fallbackIcon: Icons.ac_unit_rounded,
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
    ),
    ServiceCategoryItem(
      id: 'Electrical',
      title: 'Electrical Services',
      desc: 'Switchboard restoration, home wiring, short circuit & MCB',
      imageUrl: 'assets/images/electrician.png',
      badgeText: 'Live Now',
      sortOrder: 2,
      tags: ['Switchboard', 'Wiring Check', 'MCB Setup'],
      fallbackIcon: Icons.bolt_rounded,
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
    ),
    ServiceCategoryItem(
      id: 'Plumbing',
      title: 'Plumbing Services',
      desc: 'Pipe leakages, taps, basin repair & mechanized drainage unblock',
      imageUrl: 'assets/images/plumbing.png',
      badgeText: 'Live Now',
      sortOrder: 3,
      tags: ['Leak Repair', 'Drain Snake', 'Tap Mixer'],
      fallbackIcon: Icons.plumbing_rounded,
      color: Color(0xFF0D9488),
      bgColor: Color(0xFFF0FDFA),
    ),
    ServiceCategoryItem(
      id: 'RO',
      title: 'RO Water Purifier',
      desc: 'Sediment filter, carbon block, RO membrane & digital TDS balance',
      imageUrl: 'assets/images/ro.png',
      badgeText: 'Live Now',
      sortOrder: 4,
      tags: ['RO Membrane', 'Sediment Filter', 'TDS Balance'],
      fallbackIcon: Icons.water_drop_rounded,
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFF0F9FF),
    ),
    ServiceCategoryItem(
      id: 'Water Pump',
      title: 'Water Pump Motors',
      desc: 'Submersible & monoblock troubleshooting, capacitor & rewinding',
      imageUrl: 'assets/images/products/solar_junction_box.jpg',
      badgeText: 'Live Now',
      sortOrder: 5,
      tags: ['Motor Rewind', 'Capacitor', 'Pump Fix'],
      fallbackIcon: Icons.waves_rounded,
      color: Color(0xFF0891B2),
      bgColor: Color(0xFFECFEFF),
    ),
    ServiceCategoryItem(
      id: 'Geyser',
      title: 'Geyser Maintenance',
      desc: 'Descaling tank, heating element, thermostat & safety valve',
      imageUrl: 'assets/images/refrigerator_technician.jpg',
      badgeText: 'Live Now',
      sortOrder: 6,
      tags: ['Heating Rod', 'Descaling', 'Thermostat'],
      fallbackIcon: Icons.local_fire_department_rounded,
      color: Color(0xFFE11D48),
      bgColor: Color(0xFFFFF1F2),
    ),
    ServiceCategoryItem(
      id: 'Ceiling Fan',
      title: 'Ceiling Fan Care',
      desc: 'Motor capacitor, bearing noise lubrication & electronic regulator',
      imageUrl: 'assets/images/products/fan_capacitor.jpg',
      badgeText: 'Live Now',
      sortOrder: 7,
      tags: ['Capacitor', 'Regulator', 'Bearing Noise'],
      fallbackIcon: Icons.mode_fan_off_rounded,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
    ServiceCategoryItem(
      id: 'CARPENTRYSERVICES',
      title: 'Carpentry Services',
      desc: 'Door lock, hinge repair, furniture carpentry & drawer sliders',
      imageUrl: 'assets/images/products/cctv_camera_mount.jpg',
      badgeText: 'Live Now',
      sortOrder: 8,
      tags: ['Door Lock', 'Hinges', 'Furniture Fix'],
      fallbackIcon: Icons.carpenter_rounded,
      color: Color(0xFFB45309),
      bgColor: Color(0xFFFEF3C7),
    ),
    ServiceCategoryItem(
      id: 'ELECTRONICSSERVICES',
      title: 'Electronics & Appliances',
      desc: 'TV, Refrigerator, Washing Machine, Microwave & appliances',
      imageUrl: 'assets/images/refrigerator_technician.jpg',
      badgeText: 'Live Now',
      sortOrder: 9,
      tags: ['Fridge', 'Washing Machine', 'Microwave'],
      fallbackIcon: Icons.kitchen_rounded,
      color: Color(0xFFEA580C),
      bgColor: Color(0xFFFFF7ED),
    ),
    ServiceCategoryItem(
      id: 'PAINTINGSERVICES',
      title: 'Painting Services',
      desc: 'Interior, exterior wall painting, waterproof primer & touch-ups',
      imageUrl: 'assets/images/products/cctv_camera_mount.jpg',
      badgeText: 'Live Now',
      sortOrder: 10,
      tags: ['Wall Painting', 'Interior', 'Waterproofing'],
      fallbackIcon: Icons.format_paint_rounded,
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
    ServiceCategoryItem(
      id: 'CLEANINGSERVICES',
      title: 'Cleaning Services',
      desc: 'Deep home cleaning, kitchen sanitization, bathroom scrubbing',
      imageUrl: 'assets/images/plumbing.png',
      badgeText: 'Live Now',
      sortOrder: 11,
      tags: ['Deep Cleaning', 'Sanitization', 'Floor Scrub'],
      fallbackIcon: Icons.cleaning_services_rounded,
      color: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
    ),
    ServiceCategoryItem(
      id: 'PESTCONTROL',
      title: 'Pest Control',
      desc: 'Cockroach, termite, bed bugs, mosquito & herbal pest spray',
      imageUrl: 'assets/images/electrician.png',
      badgeText: 'Live Now',
      sortOrder: 12,
      tags: ['Termite Spray', 'Cockroach Fix', 'Pest Spray'],
      fallbackIcon: Icons.pest_control_rounded,
      color: Color(0xFFDC2626),
      bgColor: Color(0xFFFEF2F2),
    ),
    ServiceCategoryItem(
      id: 'CCTVSECURITY',
      title: 'CCTV & Security',
      desc: 'Camera installation, DVR configuration, live feed setup & cabling',
      imageUrl: 'assets/images/products/cctv_camera_mount.jpg',
      badgeText: 'Live Now',
      sortOrder: 13,
      tags: ['CCTV Setup', 'DVR Fix', 'Night Vision'],
      fallbackIcon: Icons.videocam_rounded,
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
    ),
    ServiceCategoryItem(
      id: 'INVERTERBATTERY',
      title: 'Inverter & Battery',
      desc: 'Inverter wiring, battery health test, water top-up & backup fix',
      imageUrl: 'assets/images/products/solar_junction_box.jpg',
      badgeText: 'Live Now',
      sortOrder: 14,
      tags: ['Battery Check', 'Inverter Fix', 'Backup Test'],
      fallbackIcon: Icons.battery_charging_full_rounded,
      color: Color(0xFF16A34A),
      bgColor: Color(0xFFF0FDF4),
    ),
    ServiceCategoryItem(
      id: 'SOLARSERVICES',
      title: 'Solar Services',
      desc: 'Solar panel cleaning, inverter diagnostics & battery maintenance',
      imageUrl: 'assets/images/products/solar_junction_box.jpg',
      badgeText: 'Live Now',
      sortOrder: 15,
      tags: ['Solar Inverter', 'Panel Wash', 'Battery Setup'],
      fallbackIcon: Icons.wb_sunny_rounded,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFFFBEB),
    ),
  ];

  /// Fetches service categories dynamically from Firestore 'serviceCategories',
  /// strictly filtered to Doorstep Home Service categories only.
  Future<List<ServiceCategoryItem>> fetchCategories() async {
    try {
      final uri = Uri.parse('$firestoreBaseUrl/serviceCategories?pageSize=50');
      final response = await _client.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic>? documents = data['documents'];

        if (documents != null && documents.isNotEmpty) {
          final List<ServiceCategoryItem> fetched = [];

          for (final doc in documents) {
            final fields = doc['fields'] as Map<String, dynamic>?;
            if (fields == null) continue;

            final bool isActive = _extractBool(fields['isActive'], true);
            if (!isActive) continue;

            final String docPath = doc['name'] as String? ?? '';
            final String id = docPath.split('/').last;

            // Strictly filter to Home Service categories only
            if (!isHomeServiceCategory(id)) continue;

            final String rawTitle = _extractString(
              fields['title'] ?? fields['name'] ?? fields['categoryName'],
              fallback: id,
            );
            final String cleanTitle = _cleanCategoryName(rawTitle);

            if (!isHomeServiceCategory(cleanTitle)) continue;

            final String desc = _extractString(
              fields['desc'] ?? fields['description'],
              fallback: 'Professional doorstep repair and maintenance.',
            );

            final String rawImage = _extractString(
              fields['imageUrl'] ?? fields['image'],
              fallback: '',
            );
            final String imageUrl = _resolveImageUrl(rawImage, cleanTitle);

            final int sortOrder = int.tryParse(
                  _extractString(fields['sortOrder'], fallback: '99'),
                ) ??
                99;

            final List<String> tags = _defaultTagsForCategory(cleanTitle);

            fetched.add(
              ServiceCategoryItem(
                id: id,
                title: cleanTitle,
                desc: desc,
                imageUrl: imageUrl,
                badgeText: 'Live Now',
                sortOrder: sortOrder,
                tags: tags,
                fallbackIcon: _resolveCategoryIcon(cleanTitle),
                color: _resolveCategoryColor(cleanTitle),
                bgColor: _resolveCategoryBgColor(cleanTitle),
              ),
            );
          }

          if (fetched.isNotEmpty) {
            fetched.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
            return fetched;
          }
        }
      }
    } catch (e) {
      debugPrint('FirebaseServicesService: fetchCategories error: $e');
    }

    return defaultCategories
        .where((c) => isHomeServiceCategory(c.id) && isHomeServiceCategory(c.title))
        .toList();
  }

  // ──────────────────────────── Super App Verticals Catalogs ────────────────

  static const List<ServiceItem> foodDeliveryServices = [
    ServiceItem(
      id: 'food_1',
      title: 'Daily Home-Style Tiffin Service',
      desc: '4 Rotis, Seasonal Sabzi, Dal Tadka, Jeera Rice, Salad & Sweet.',
      category: 'Food Delivery',
      categoryId: 'food_delivery',
      price: '₹ 120/-',
      originalPrice: '₹ 150/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
      tag: 'Daily Tiffin',
    ),
    ServiceItem(
      id: 'food_2',
      title: 'Dum Biryani & Chicken Meal Combo',
      desc: 'Aromatic basmati rice, 2 juicy chicken pieces, boiled egg, raita & salad.',
      category: 'Food Delivery',
      categoryId: 'food_delivery',
      price: '₹ 180/-',
      originalPrice: '₹ 220/-',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=600&q=80',
      tag: 'Chef Special',
    ),
    ServiceItem(
      id: 'food_3',
      title: 'Monthly Daily Tiffin Subscription',
      desc: 'Nutritious lunch & dinner delivered everyday. Custom menu choice.',
      category: 'Food Delivery',
      categoryId: 'food_delivery',
      price: '₹ 2,999/mo',
      originalPrice: '₹ 3,600/mo',
      rating: '4.9',
      frequency: 'Monthly',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=600&q=80',
      tag: 'Monthly Plan',
    ),
    ServiceItem(
      id: 'food_4',
      title: 'Bengali Thali with Katla Fish Curry',
      desc: 'Steamed rice, Katla Kalia, Bhaja, Shukto, Musur Dal, Chutney & Papad.',
      category: 'Food Delivery',
      categoryId: 'food_delivery',
      price: '₹ 199/-',
      originalPrice: '₹ 249/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?auto=format&fit=crop&w=600&q=80',
      tag: 'Authentic',
    ),
  ];

  static const List<ServiceItem> bikeAndCabServices = [
    ServiceItem(
      id: 'ride_1',
      title: 'Instant City Bike Taxi',
      desc: 'Beat the traffic with swift doorstep bike rides with certified helmet.',
      category: 'Bike & Cab Service',
      categoryId: 'bike_cab',
      price: '₹ 25 Base',
      originalPrice: '₹ 40/-',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=600&q=80',
      tag: 'Fastest ETA',
    ),
    ServiceItem(
      id: 'ride_2',
      title: 'Metred City Auto Rickshaw',
      desc: 'Affordable group commute across Haldia and district checkpoints.',
      category: 'Bike & Cab Service',
      categoryId: 'bike_cab',
      price: '₹ 40 Base',
      originalPrice: '₹ 60/-',
      rating: '4.7',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=600&q=80',
      tag: 'Economical',
    ),
    ServiceItem(
      id: 'ride_3',
      title: 'AC Mini Hatchback Cab',
      desc: 'Air conditioned clean cars for comfortable point-to-point transfers.',
      category: 'Bike & Cab Service',
      categoryId: 'bike_cab',
      price: '₹ 99 Base',
      originalPrice: '₹ 149/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=600&q=80',
      tag: 'AC Ride',
    ),
    ServiceItem(
      id: 'ride_4',
      title: 'Doorstep Bike General Servicing',
      desc: 'Engine oil change, brake tuning, carburetor wash & chain lubrication.',
      category: 'Bike & Cab Service',
      categoryId: 'bike_cab',
      price: '₹ 399/-',
      originalPrice: '₹ 599/-',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80',
      tag: 'Doorstep Garage',
    ),
  ];

  static const List<ServiceItem> ambulanceServices = [
    ServiceItem(
      id: 'amb_1',
      title: 'Basic Life Support (BLS) Ambulance',
      desc: 'Oxygen cylinder, stretcher trolley, vital monitor & certified paramedic.',
      category: 'Emergency Ambulance',
      categoryId: 'ambulance',
      price: '₹ 999 Base',
      originalPrice: '₹ 1,499/-',
      rating: '5.0',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1587745416684-47953f16f02f?auto=format&fit=crop&w=600&q=80',
      tag: 'SOS 24/7',
    ),
    ServiceItem(
      id: 'amb_2',
      title: 'Advanced ICU on Wheels (ALS)',
      desc: 'Transport ventilator, cardiac defibrillator, suction unit & emergency doctor.',
      category: 'Emergency Ambulance',
      categoryId: 'ambulance',
      price: '₹ 2,499 Base',
      originalPrice: '₹ 3,500/-',
      rating: '5.0',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=600&q=80',
      tag: 'ICU Critical',
    ),
    ServiceItem(
      id: 'amb_3',
      title: 'Patient Transport Vehicle (PTV)',
      desc: 'Non-emergency patient hospital transfer for dialysis, scans & checkups.',
      category: 'Emergency Ambulance',
      categoryId: 'ambulance',
      price: '₹ 599 Base',
      originalPrice: '₹ 899/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1587745416684-47953f16f02f?auto=format&fit=crop&w=600&q=80',
      tag: 'Safe Transit',
    ),
  ];

  static const List<ServiceItem> medicineServices = [
    ServiceItem(
      id: 'med_1',
      title: 'Doctor Prescription (Rx) Order Delivery',
      desc: 'Upload prescription for 20% flat discount on 100% genuine medicines.',
      category: 'Medicine Delivery',
      categoryId: 'medicine_delivery',
      price: 'Flat 20% Off',
      originalPrice: 'MRP Rate',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=600&q=80',
      tag: 'Rx Verified',
    ),
    ServiceItem(
      id: 'med_2',
      title: 'First-Aid Kit & Home Medical Essentials',
      desc: 'Antiseptic liquid, sterile bandages, burn ointment, cotton roll & scissors.',
      category: 'Medicine Delivery',
      categoryId: 'medicine_delivery',
      price: '₹ 299/-',
      originalPrice: '₹ 399/-',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1471864190281-a93a3070b6de?auto=format&fit=crop&w=600&q=80',
      tag: 'Essential Kit',
    ),
    ServiceItem(
      id: 'med_3',
      title: 'Monthly Chronic Care Medicine Refill',
      desc: 'Automated 30-day doorstep delivery of Diabetes, BP, and Thyroid tablets.',
      category: 'Medicine Delivery',
      categoryId: 'medicine_delivery',
      price: '₹ 999/mo',
      originalPrice: '₹ 1,350/mo',
      rating: '4.9',
      frequency: 'Monthly',
      imageUrl: 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?auto=format&fit=crop&w=600&q=80',
      tag: 'Monthly Care',
    ),
  ];

  static const List<ServiceItem> roomBookingServices = [
    ServiceItem(
      id: 'room_1',
      title: 'Verified Executive PG & Hostels',
      desc: 'Furnished single/sharing room, high-speed WiFi, breakfast & housekeeping.',
      category: 'Room Booking',
      categoryId: 'room_booking',
      price: '₹ 4,500/mo',
      originalPrice: '₹ 5,500/mo',
      rating: '4.8',
      frequency: 'Monthly',
      imageUrl: 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=600&q=80',
      tag: 'No Brokerage',
    ),
    ServiceItem(
      id: 'room_2',
      title: 'Deluxe AC Hotel Room Day Stay',
      desc: 'AC room with attached washroom, smart TV, room service & sanitization.',
      category: 'Room Booking',
      categoryId: 'room_booking',
      price: '₹ 899/night',
      originalPrice: '₹ 1,499/night',
      rating: '4.7',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80',
      tag: 'Instant Check-in',
    ),
  ];

  static const List<ServiceItem> electraScootyServices = [
    ServiceItem(
      id: 'scooty_1',
      title: 'Free Doorstep Electric Scooty Test Ride',
      desc: 'Book a free doorstep test ride of Quickox Electra S1 Smart EV Scooter.',
      category: 'QUICKOX ELECTRA Scooty',
      categoryId: 'electra_scooty',
      price: 'Free Booking',
      originalPrice: '₹ 199/-',
      rating: '5.0',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=600&q=80',
      tag: 'Zero Cost',
    ),
    ServiceItem(
      id: 'scooty_2',
      title: 'EV Scooter Battery & Motor Health Check',
      desc: 'Full battery diagnostic, cell balancing, controller calibration & disc brakes.',
      category: 'QUICKOX ELECTRA Scooty',
      categoryId: 'electra_scooty',
      price: '₹ 299/-',
      originalPrice: '₹ 499/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?auto=format&fit=crop&w=600&q=80',
      tag: 'Certified Tech',
    ),
  ];

  static const List<ServiceItem> eventBookingServices = [
    ServiceItem(
      id: 'event_1',
      title: 'Birthday & Anniversary Balloon Theme Setup',
      desc: 'LED ring backdrop, balloon arch, cake table decoration & sound system.',
      category: 'Event Booking',
      categoryId: 'event_booking',
      price: '₹ 2,999/-',
      originalPrice: '₹ 4,500/-',
      rating: '4.9',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=600&q=80',
      tag: 'Custom Themes',
    ),
    ServiceItem(
      id: 'event_2',
      title: 'Wedding & Rice Ceremony Buffet Catering',
      desc: 'Multi-course Bengali & North Indian spread with trained waiters & cutlery.',
      category: 'Event Booking',
      categoryId: 'event_booking',
      price: '₹ 450/plate',
      originalPrice: '₹ 550/plate',
      rating: '4.8',
      frequency: 'One-Time',
      imageUrl: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?auto=format&fit=crop&w=600&q=80',
      tag: 'Per Plate Basis',
    ),
  ];

  /// Fetches services matching category, frequency and query with real Firestore integration
  Future<List<ServiceItem>> fetchServicesForCategory({
    required String categoryName,
    String frequency = 'All',
    String query = '',
  }) async {
    final normName = categoryName.trim().toLowerCase();

    // Check if category corresponds to a Super App vertical
    if (normName.contains('food')) {
      return _filterServicesList(foodDeliveryServices, frequency, query);
    }
    if (normName.contains('bike') || normName.contains('cab') || normName.contains('ride')) {
      return _filterServicesList(bikeAndCabServices, frequency, query);
    }
    if (normName.contains('ambulance')) {
      return _filterServicesList(ambulanceServices, frequency, query);
    }
    if (normName.contains('medicine') || normName.contains('pharma')) {
      return _filterServicesList(medicineServices, frequency, query);
    }
    if (normName.contains('room') || normName.contains('hotel') || normName.contains('pg')) {
      return _filterServicesList(roomBookingServices, frequency, query);
    }
    if (normName.contains('scooty') || normName.contains('electra')) {
      return _filterServicesList(electraScootyServices, frequency, query);
    }
    if (normName.contains('event') || normName.contains('marriage') || normName.contains('birthday')) {
      return _filterServicesList(eventBookingServices, frequency, query);
    }

    // Otherwise, fetch home services from Firestore backend
    final allServices = await fetchServices();

    final isGeneral = normName == 'all' ||
        normName == 'home service' ||
        normName.contains('doorstep') ||
        normName.contains('repair');

    final cleanTarget = _cleanCategoryName(categoryName).toLowerCase();

    final categoryFiltered = isGeneral
        ? allServices
        : allServices.where((svc) {
            final cat = svc.category.toLowerCase();
            return cat.contains(cleanTarget) ||
                cleanTarget.contains(cat) ||
                (cleanTarget.contains('electronic') &&
                    (cat.contains('fridge') ||
                        cat.contains('tv') ||
                        cat.contains('washer') ||
                        cat.contains('fan'))) ||
                (cleanTarget.contains('ac') && cat.contains('ac')) ||
                (cleanTarget.contains('plumb') && cat.contains('plumb')) ||
                (cleanTarget.contains('electr') && cat.contains('electr')) ||
                (cleanTarget.contains('ro') && cat.contains('ro')) ||
                (cleanTarget.contains('geyser') && cat.contains('geyser')) ||
                (cleanTarget.contains('pump') && cat.contains('pump'));
          }).toList();

    return _filterServicesList(categoryFiltered, frequency, query);
  }

  static List<ServiceItem> _filterServicesList(
    List<ServiceItem> list,
    String frequency,
    String query,
  ) {
    return list.where((svc) {
      if (frequency != 'All') {
        if (frequency == 'One-Time' && svc.frequency.toLowerCase() != 'one-time') {
          return false;
        }
        if (frequency == 'Monthly' && !svc.frequency.toLowerCase().contains('month')) {
          return false;
        }
      }

      if (query.trim().isNotEmpty) {
        final q = query.trim().toLowerCase();
        final match = svc.title.toLowerCase().contains(q) ||
            svc.desc.toLowerCase().contains(q) ||
            svc.category.toLowerCase().contains(q);
        if (!match) return false;
      }

      return true;
    }).toList();
  }

  /// Fetches service detail overview metadata from Firestore 'serviceDetails'
  Future<ServiceDetailModel> fetchServiceDetail(
    String serviceTitle, {
    String? category,
    String? serviceId,
  }) async {
    try {
      final docCandidates = <String>[];
      if (serviceId != null && serviceId.isNotEmpty) {
        docCandidates.add(serviceId.replaceAll('services/', '').replaceAll('/', '_'));
      }
      final sanitizedTitle = serviceTitle
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
      if (sanitizedTitle.isNotEmpty) {
        docCandidates.add(sanitizedTitle);
      }
      if (category != null && category.isNotEmpty) {
        final sanitizedCat = category.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
        docCandidates.add(sanitizedCat);
      }

      for (final docId in docCandidates.take(3)) {
        final uri = Uri.parse('$firestoreBaseUrl/serviceDetails/$docId');
        final res = await _client.get(uri).timeout(const Duration(seconds: 3));
        if (res.statusCode == 200) {
          final data = json.decode(res.body) as Map<String, dynamic>;
          final fields = data['fields'] as Map<String, dynamic>?;
          if (fields != null) {
            return _parseServiceDetailModel(fields, serviceTitle, category);
          }
        }
      }
    } catch (e) {
      debugPrint('FirebaseServicesService: fetchServiceDetail error: $e');
    }

    return _buildDefaultServiceDetail(serviceTitle, category);
  }

  static ServiceDetailModel _parseServiceDetailModel(
    Map<String, dynamic> fields,
    String fallbackTitle,
    String? category,
  ) {
    final heroTitle = _extractString(
      fields['heroTitle'],
      fallback: '$fallbackTitle Solutions',
    );
    final heroDesc = _extractString(
      fields['heroDesc'],
      fallback: 'Safe, reliable, and premium doorstep service by verified experts.',
    );
    final emergencyPhone = _extractString(
      fields['emergencyPhone'],
      fallback: '+919046599109',
    );
    final emergencyWhatsApp = _extractString(
      fields['emergencyWhatsApp'],
      fallback: '+919046599109',
    );
    final bookCTALabel = _extractString(
      fields['bookCTALabel'],
      fallback: 'Book Technician',
    );
    final partsCTALabel = _extractString(
      fields['partsCTALabel'],
      fallback: 'Shop Spare Parts',
    );

    // Inclusions
    final List<ServiceInclusion> inclusions = [];
    if (fields['inclusions'] != null && fields['inclusions']['arrayValue'] != null) {
      final values = fields['inclusions']['arrayValue']['values'] as List<dynamic>?;
      if (values != null) {
        for (final v in values) {
          if (v is Map<String, dynamic> && v.containsKey('mapValue')) {
            final f = v['mapValue']['fields'] as Map<String, dynamic>?;
            if (f != null) {
              final t = _extractString(f['title']);
              final d = _extractString(f['desc']);
              if (t.isNotEmpty) {
                inclusions.add(ServiceInclusion(title: t, desc: d));
              }
            }
          }
        }
      }
    }

    // FAQs
    final List<ServiceFaq> faqs = [];
    if (fields['faqs'] != null && fields['faqs']['arrayValue'] != null) {
      final values = fields['faqs']['arrayValue']['values'] as List<dynamic>?;
      if (values != null) {
        for (final v in values) {
          if (v is Map<String, dynamic> && v.containsKey('mapValue')) {
            final f = v['mapValue']['fields'] as Map<String, dynamic>?;
            if (f != null) {
              final q = _extractString(f['q'] ?? f['question']);
              final a = _extractString(f['a'] ?? f['answer']);
              if (q.isNotEmpty && a.isNotEmpty) {
                faqs.add(ServiceFaq(question: q, answer: a));
              }
            }
          }
        }
      }
    }

    // How it works
    final List<ServiceStep> howItWorks = [];
    if (fields['howItWorks'] != null && fields['howItWorks']['arrayValue'] != null) {
      final values = fields['howItWorks']['arrayValue']['values'] as List<dynamic>?;
      if (values != null) {
        for (final v in values) {
          if (v is Map<String, dynamic> && v.containsKey('mapValue')) {
            final f = v['mapValue']['fields'] as Map<String, dynamic>?;
            if (f != null) {
              final s = _extractString(f['step'], fallback: '1');
              final t = _extractString(f['title']);
              final d = _extractString(f['desc']);
              if (t.isNotEmpty) {
                howItWorks.add(ServiceStep(step: s, title: t, desc: d));
              }
            }
          }
        }
      }
    }

    final fallback = _buildDefaultServiceDetail(fallbackTitle, category);

    return ServiceDetailModel(
      heroTitle: heroTitle,
      heroDesc: heroDesc,
      emergencyPhone: emergencyPhone,
      emergencyWhatsApp: emergencyWhatsApp,
      bookCTALabel: bookCTALabel,
      partsCTALabel: partsCTALabel,
      inclusions: inclusions.isNotEmpty ? inclusions : fallback.inclusions,
      faqs: faqs.isNotEmpty ? faqs : fallback.faqs,
      howItWorks: howItWorks.isNotEmpty ? howItWorks : fallback.howItWorks,
      metrics: fallback.metrics,
      featurePills: fallback.featurePills,
    );
  }

  static ServiceDetailModel _buildDefaultServiceDetail(
    String serviceTitle,
    String? category,
  ) {
    final cleanTitle = serviceTitle.endsWith('Solutions') ||
            serviceTitle.endsWith('Servicing') ||
            serviceTitle.endsWith('Service') ||
            serviceTitle.endsWith('Repair') ||
            serviceTitle.endsWith('Care') ||
            serviceTitle.length > 25
        ? serviceTitle
        : '$serviceTitle Solutions';
    return ServiceDetailModel(
      heroTitle: cleanTitle,
      heroDesc:
          'Safe, reliable, and premium doorstep service by background-verified professionals.',
      inclusions: const [
        ServiceInclusion(
          title: 'Standard Inspection & Diagnosis',
          desc: 'Comprehensive diagnostics to isolate root causes and evaluate wear.',
        ),
        ServiceInclusion(
          title: 'Precision Repair & Tuning',
          desc: 'Repaired using high-grade precision tools and certified manufacturer parts.',
        ),
        ServiceInclusion(
          title: 'Pre & Post Testing Safety Audit',
          desc: 'Electrical load and performance check before handoff.',
        ),
        ServiceInclusion(
          title: 'Cleanup & Warranty Handover',
          desc: 'Workspace sanitization and 30-day digital warranty generation.',
        ),
      ],
      faqs: const [
        ServiceFaq(
          question: 'Is inspection really free?',
          answer:
              'Yes! Initial home inspection is 100% free when you proceed with the repair service or hold a Quickox Care Club membership.',
        ),
        ServiceFaq(
          question: 'What if extra material is required?',
          answer:
              'Our technician will provide an itemized rate card before replacing any parts. You only pay for 100% genuine parts.',
        ),
        ServiceFaq(
          question: 'Do you provide a service warranty?',
          answer:
              'Yes! Every service comes with a 30-day post-service warranty. Any recurring issues are fixed completely free of cost.',
        ),
        ServiceFaq(
          question: 'How quickly can a technician arrive?',
          answer:
              'Our verified technicians typically arrive at your doorstep within 30 to 60 minutes of booking confirmation.',
        ),
        ServiceFaq(
          question: 'Are all technicians verified?',
          answer:
              'Yes, 100% of technicians undergo background verification, police clearance, and rigorous skill training.',
        ),
      ],
      howItWorks: const [
        ServiceStep(
          step: '1',
          title: 'Book a Service',
          desc: 'Select preferred date & time slot online in seconds.',
          icon: Icons.calendar_today_rounded,
        ),
        ServiceStep(
          step: '2',
          title: 'Expert Arrives',
          desc: 'Verified professional reaches your address on time.',
          icon: Icons.person_pin_circle_rounded,
        ),
        ServiceStep(
          step: '3',
          title: 'Inspection & Quote',
          desc: 'We diagnose the issue and explain the exact solution.',
          icon: Icons.search_rounded,
        ),
        ServiceStep(
          step: '4',
          title: 'Service Done',
          desc: 'High quality repair with genuine materials and tools.',
          icon: Icons.build_rounded,
        ),
        ServiceStep(
          step: '5',
          title: 'Relax & Enjoy',
          desc: 'Enjoy worry-free comfort backed by 30-day warranty.',
          icon: Icons.verified_user_rounded,
        ),
      ],
      metrics: const [
        ServiceMetric(
          label: 'Service Time',
          value: '30 - 90 mins',
          icon: Icons.schedule_rounded,
        ),
        ServiceMetric(
          label: 'Availability',
          value: 'All 7 Days',
          icon: Icons.event_available_rounded,
        ),
        ServiceMetric(
          label: 'Response Time',
          value: 'Within 60 mins',
          icon: Icons.electric_bolt_rounded,
        ),
        ServiceMetric(
          label: 'Warranty',
          value: 'Up to 30 Days',
          icon: Icons.shield_rounded,
        ),
      ],
    );
  }

  // ──────────────────────────── Helpers ────────────────────────────

  static List<String> _defaultTagsForCategory(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('ac')) return ['AC Jet Wash', 'Gas Refill', 'Maintenance'];
    if (cat.contains('electr')) return ['Switchboard', 'Wiring Check', 'MCB'];
    if (cat.contains('plumb')) return ['Leak Repair', 'Drain Snake', 'Tap Mixer'];
    if (cat.contains('ro')) return ['RO Membrane', 'Sediment Filter', 'TDS Balance'];
    if (cat.contains('pump')) return ['Motor Rewind', 'Capacitor', 'Pump Fix'];
    if (cat.contains('geyser')) return ['Heating Rod', 'Descaling', 'Thermostat'];
    if (cat.contains('fan')) return ['Capacitor', 'Regulator', 'Bearing Noise'];
    if (cat.contains('carpentr')) return ['Door Lock', 'Hinges', 'Furniture Fix'];
    if (cat.contains('paint')) return ['Wall Painting', 'Interior', 'Waterproofing'];
    if (cat.contains('clean')) return ['Deep Cleaning', 'Sanitization', 'Floor Scrub'];
    if (cat.contains('pest')) return ['Termite Spray', 'Cockroach Fix', 'Pest Spray'];
    if (cat.contains('cctv') || cat.contains('secur')) return ['CCTV Setup', 'DVR Fix', 'Night Vision'];
    if (cat.contains('inverter') || cat.contains('battery')) return ['Battery Check', 'Inverter Fix', 'Backup Test'];
    if (cat.contains('solar')) return ['Solar Inverter', 'Panel Wash', 'Battery Setup'];
    if (cat.contains('wash')) return ['Pressure Wash', 'Interior Foam', 'Doorstep'];
    return ['Doorstep Service', 'Verified Expert', 'Warranty'];
  }

  static IconData _resolveCategoryIcon(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('ac')) return Icons.ac_unit_rounded;
    if (cat.contains('electr')) return Icons.bolt_rounded;
    if (cat.contains('plumb')) return Icons.plumbing_rounded;
    if (cat.contains('ro')) return Icons.water_drop_rounded;
    if (cat.contains('pump')) return Icons.waves_rounded;
    if (cat.contains('geyser')) return Icons.local_fire_department_rounded;
    if (cat.contains('fan')) return Icons.mode_fan_off_rounded;
    if (cat.contains('carpentr')) return Icons.carpenter_rounded;
    if (cat.contains('paint')) return Icons.format_paint_rounded;
    if (cat.contains('clean')) return Icons.cleaning_services_rounded;
    if (cat.contains('pest')) return Icons.pest_control_rounded;
    if (cat.contains('cctv') || cat.contains('secur')) return Icons.videocam_rounded;
    if (cat.contains('inverter') || cat.contains('battery')) return Icons.battery_charging_full_rounded;
    if (cat.contains('solar')) return Icons.wb_sunny_rounded;
    if (cat.contains('wash')) return Icons.local_car_wash_rounded;
    return Icons.home_repair_service_rounded;
  }

  static Color _resolveCategoryColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('ac')) return const Color(0xFF0284C7);
    if (cat.contains('electr')) return const Color(0xFF2563EB);
    if (cat.contains('plumb')) return const Color(0xFF0D9488);
    if (cat.contains('ro')) return const Color(0xFF0284C7);
    if (cat.contains('pump')) return const Color(0xFF0891B2);
    if (cat.contains('geyser')) return const Color(0xFFE11D48);
    if (cat.contains('fan')) return const Color(0xFF7C3AED);
    if (cat.contains('carpentr')) return const Color(0xFFB45309);
    if (cat.contains('paint')) return const Color(0xFF7C3AED);
    if (cat.contains('clean')) return const Color(0xFF059669);
    if (cat.contains('pest')) return const Color(0xFFDC2626);
    if (cat.contains('cctv') || cat.contains('secur')) return const Color(0xFF0284C7);
    if (cat.contains('inverter') || cat.contains('battery')) return const Color(0xFF16A34A);
    if (cat.contains('solar')) return const Color(0xFFD97706);
    if (cat.contains('wash')) return const Color(0xFF0284C7);
    return const Color(0xFF2563EB);
  }

  static Color _resolveCategoryBgColor(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('ac')) return const Color(0xFFE0F2FE);
    if (cat.contains('electr')) return const Color(0xFFEFF6FF);
    if (cat.contains('plumb')) return const Color(0xFFF0FDFA);
    if (cat.contains('ro')) return const Color(0xFFF0F9FF);
    if (cat.contains('pump')) return const Color(0xFFECFEFF);
    if (cat.contains('geyser')) return const Color(0xFFFFF1F2);
    if (cat.contains('fan')) return const Color(0xFFF5F3FF);
    if (cat.contains('carpentr')) return const Color(0xFFFEF3C7);
    if (cat.contains('paint')) return const Color(0xFFF5F3FF);
    if (cat.contains('clean')) return const Color(0xFFECFDF5);
    if (cat.contains('pest')) return const Color(0xFFFEF2F2);
    if (cat.contains('cctv') || cat.contains('secur')) return const Color(0xFFE0F2FE);
    if (cat.contains('inverter') || cat.contains('battery')) return const Color(0xFFF0FDF4);
    if (cat.contains('solar')) return const Color(0xFFFFFBEB);
    if (cat.contains('wash')) return const Color(0xFFE0F2FE);
    return const Color(0xFFEFF6FF);
  }

  static String _extractString(Map<String, dynamic>? field,
      {String fallback = ''}) {
    if (field == null) return fallback;
    if (field.containsKey('stringValue')) {
      final val = field['stringValue'] as String;
      return val.trim().isNotEmpty ? val.trim() : fallback;
    }
    if (field.containsKey('integerValue')) {
      return field['integerValue'].toString();
    }
    if (field.containsKey('doubleValue')) {
      return field['doubleValue'].toString();
    }
    return fallback;
  }

  static bool _extractBool(Map<String, dynamic>? field, bool fallback) {
    if (field == null) return fallback;
    if (field.containsKey('booleanValue')) {
      return field['booleanValue'] as bool;
    }
    return fallback;
  }

  static String _extractPrice(Map<String, dynamic>? field) {
    if (field == null) return '';
    if (field.containsKey('stringValue')) {
      return (field['stringValue'] as String).trim();
    }
    if (field.containsKey('integerValue')) {
      return field['integerValue'].toString();
    }
    if (field.containsKey('doubleValue')) {
      return field['doubleValue'].toString();
    }
    return '';
  }

  static String _cleanCategoryName(String raw) {
    // Strips emojis, variation selectors, and symbols
    final clean = raw.replaceAll(
      RegExp(
        r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE00}-\u{FE0F}]',
        unicode: true,
      ),
      '',
    ).trim();
    return clean.isNotEmpty ? clean : 'General';
  }

  static String _normalizePrice(String rawPrice, String category) {
    if (rawPrice.isEmpty || rawPrice == '--') {
      final cat = category.toLowerCase();
      if (cat.contains('ac')) return '₹ 499/-';
      if (cat.contains('electr')) return '₹ 199/-';
      if (cat.contains('plumb')) return '₹ 199/-';
      if (cat.contains('ro')) return '₹ 649/-';
      if (cat.contains('pest')) return '₹ 799/-';
      if (cat.contains('geyser')) return '₹ 449/-';
      return '₹ 299/-';
    }

    if (rawPrice.startsWith('₹')) return rawPrice;
    if (RegExp(r'^\d+').hasMatch(rawPrice)) {
      return '₹ $rawPrice/-';
    }
    return rawPrice;
  }

  static String? _computeOriginalPrice(String price) {
    // If standard "₹ 499/-", compute ~30% higher for strikethrough savings
    final match = RegExp(r'₹\s*([0-9,]+)').firstMatch(price);
    if (match != null) {
      final numStr = match.group(1)!.replaceAll(',', '');
      final num = int.tryParse(numStr);
      if (num != null && num > 0) {
        final orig = (num * 1.35).round();
        return '₹ $orig/-';
      }
    }
    return null;
  }

  static String _extractTag(Map<String, dynamic>? field) {
    if (field != null && field.containsKey('arrayValue')) {
      final values = field['arrayValue']['values'] as List<dynamic>?;
      if (values != null && values.isNotEmpty) {
        final first = values[0] as Map<String, dynamic>?;
        if (first != null && first.containsKey('stringValue')) {
          final t = first['stringValue'] as String;
          if (t.trim().isNotEmpty) return t.trim();
        }
      }
    }
    return 'Popular';
  }

  static String _resolveImageUrl(String raw, String category) {
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    final cat = category.toLowerCase();
    if (cat.contains('ac')) return 'assets/images/ac.png';
    if (cat.contains('electr')) return 'assets/images/electrician.png';
    if (cat.contains('plumb') || cat.contains('clean')) return 'assets/images/plumbing.png';
    if (cat.contains('ro')) return 'assets/images/ro.png';
    if (cat.contains('fan')) return 'assets/images/products/fan_capacitor.jpg';
    if (cat.contains('pump') || cat.contains('solar') || cat.contains('inverter') || cat.contains('battery')) {
      return 'assets/images/products/solar_junction_box.jpg';
    }
    if (cat.contains('carpentr') || cat.contains('cctv') || cat.contains('paint')) {
      return 'assets/images/products/cctv_camera_mount.jpg';
    }
    return 'assets/images/refrigerator_technician.jpg';
  }
}
