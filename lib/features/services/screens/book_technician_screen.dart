import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/common_widgets.dart';
import 'choose_appointment_slot_screen.dart';

/// Model representing a photo uploaded from camera or gallery
class UploadedPhotoItem {
  final String path;
  final String name;
  final Uint8List? bytes;

  const UploadedPhotoItem({
    required this.path,
    required this.name,
    this.bytes,
  });
}

/// Screen allowing the user to configure and book a technician
/// matching the user mockup: issue categories grid, issue description,
/// photo upload, service address, preferred date, and continue to choose slot.
class BookTechnicianScreen extends StatefulWidget {
  const BookTechnicianScreen({
    super.key,
    this.serviceTitle = 'Electronics Services',
    this.parentCategory = 'Home Service',
    this.basePrice = 249,
  });

  final String serviceTitle;
  final String parentCategory;
  final int basePrice;

  @override
  State<BookTechnicianScreen> createState() => _BookTechnicianScreenState();
}

class _BookTechnicianScreenState extends State<BookTechnicianScreen> {
  int _selectedIssueIndex = 0;
  final TextEditingController _descController = TextEditingController();
  final List<UploadedPhotoItem> _uploadedPhotos = [];
  final ImagePicker _picker = ImagePicker();
  String _serviceAddress = 'Chas Road, Purulia, West Bengal 723101';
  DateTime _selectedDate = DateTime.now();

  List<_IssueCategory> _getIssueCategories() {
    final query = '${widget.serviceTitle} ${widget.parentCategory}'.toLowerCase();

    if (query.contains('ac') || query.contains('air condition') || query.contains('cooling')) {
      return const [
        _IssueCategory(
          title: 'Not Cooling',
          subtitle: 'Weak or no cooling airflow',
          icon: Icons.ac_unit_rounded,
        ),
        _IssueCategory(
          title: 'Gas Leak / Refill',
          subtitle: 'Low refrigerant gas, leak fix',
          icon: Icons.propane_tank_outlined,
        ),
        _IssueCategory(
          title: 'Water Leakage',
          subtitle: 'Water dripping inside room',
          icon: Icons.water_drop_outlined,
        ),
        _IssueCategory(
          title: 'Noise / Vibration',
          subtitle: 'Loud sound from indoor/outdoor unit',
          icon: Icons.volume_up_outlined,
        ),
        _IssueCategory(
          title: 'Regular Service',
          subtitle: 'Deep cleaning, foam jet service',
          icon: Icons.cleaning_services_rounded,
        ),
        _IssueCategory(
          title: 'Installation',
          subtitle: 'Uninstallation or new AC fit',
          icon: Icons.build_rounded,
        ),
        _IssueCategory(
          title: 'Power / Tripping',
          subtitle: 'AC not turning on or tripping MCB',
          icon: Icons.bolt_rounded,
        ),
        _IssueCategory(
          title: 'Others',
          subtitle: 'PCB repair, remote sensor, etc.',
          icon: Icons.more_horiz_rounded,
        ),
      ];
    } else if (query.contains('plumb') ||
        query.contains('pipe') ||
        query.contains('water pump') ||
        query.contains('pump') ||
        query.contains('tap') ||
        query.contains('tank')) {
      return const [
        _IssueCategory(
          title: 'Tap & Mixer',
          subtitle: 'Dripping tap, mixer repair',
          icon: Icons.water_damage_rounded,
        ),
        _IssueCategory(
          title: 'Pipe Leakage',
          subtitle: 'Concealed or open pipe leak',
          icon: Icons.plumbing_rounded,
        ),
        _IssueCategory(
          title: 'Blockage / Drain',
          subtitle: 'Blocked sink, basin or drain',
          icon: Icons.cleaning_services_rounded,
        ),
        _IssueCategory(
          title: 'Toilet & Flush',
          subtitle: 'Flush tank, seat, jet spray',
          icon: Icons.wc_rounded,
        ),
        _IssueCategory(
          title: 'Water Tank',
          subtitle: 'Tank overflow, valve, cleaning',
          icon: Icons.storage_rounded,
        ),
        _IssueCategory(
          title: 'Motor & Pump',
          subtitle: 'Submersible, booster pump issue',
          icon: Icons.settings_power_rounded,
        ),
        _IssueCategory(
          title: 'Shower Fitting',
          subtitle: 'Shower installation or repair',
          icon: Icons.shower_rounded,
        ),
        _IssueCategory(
          title: 'Others',
          subtitle: 'General plumbing work',
          icon: Icons.more_horiz_rounded,
        ),
      ];
    } else if (query.contains('refrigerat') || query.contains('fridge')) {
      return const [
        _IssueCategory(
          title: 'Not Cooling',
          subtitle: 'Freezer or fridge not cold',
          icon: Icons.kitchen_rounded,
        ),
        _IssueCategory(
          title: 'Excess Freezing',
          subtitle: 'Ice buildup in freezer',
          icon: Icons.ac_unit_rounded,
        ),
        _IssueCategory(
          title: 'Gas Leakage',
          subtitle: 'Compressor running but no cooling',
          icon: Icons.propane_tank_outlined,
        ),
        _IssueCategory(
          title: 'Strange Noise',
          subtitle: 'Compressor or fan humming/rattling',
          icon: Icons.volume_up_outlined,
        ),
        _IssueCategory(
          title: 'Water Leakage',
          subtitle: 'Water pooling inside or underneath',
          icon: Icons.water_drop_outlined,
        ),
        _IssueCategory(
          title: 'Door / Gasket',
          subtitle: 'Rubber seal loose or not closing',
          icon: Icons.door_front_door_outlined,
        ),
        _IssueCategory(
          title: 'Power / PCB',
          subtitle: 'No lights or fridge dead',
          icon: Icons.bolt_rounded,
        ),
        _IssueCategory(
          title: 'Others',
          subtitle: 'Thermostat, bulb or general fix',
          icon: Icons.more_horiz_rounded,
        ),
      ];
    } else if (query.contains('wash') || query.contains('laundry')) {
      return const [
        _IssueCategory(
          title: 'Not Spinning',
          subtitle: 'Drum not rotating or slow spin',
          icon: Icons.local_laundry_service_rounded,
        ),
        _IssueCategory(
          title: 'Water Drainage',
          subtitle: 'Water not draining out',
          icon: Icons.water_drop_outlined,
        ),
        _IssueCategory(
          title: 'No Water Inlet',
          subtitle: 'Water not filling up inside drum',
          icon: Icons.shower_rounded,
        ),
        _IssueCategory(
          title: 'Vibration / Noise',
          subtitle: 'Violent shaking during spin cycle',
          icon: Icons.vibration_rounded,
        ),
        _IssueCategory(
          title: 'Power / Error',
          subtitle: 'Error code on display, no power',
          icon: Icons.bolt_rounded,
        ),
        _IssueCategory(
          title: 'Door / Lid Issue',
          subtitle: 'Door lock stuck or broken switch',
          icon: Icons.lock_outline_rounded,
        ),
        _IssueCategory(
          title: 'Drum Cleaning',
          subtitle: 'Deep descaling & tub cleaning',
          icon: Icons.cleaning_services_rounded,
        ),
        _IssueCategory(
          title: 'Others',
          subtitle: 'Belt, motor or PCB repair',
          icon: Icons.more_horiz_rounded,
        ),
      ];
    } else if (query.contains('ro') || query.contains('purifier') || query.contains('filter')) {
      return const [
        _IssueCategory(
          title: 'Filter Change',
          subtitle: 'Sediment, carbon, membrane change',
          icon: Icons.filter_alt_outlined,
        ),
        _IssueCategory(
          title: 'Bad Taste/Odour',
          subtitle: 'Water tastes weird or has smell',
          icon: Icons.local_drink_rounded,
        ),
        _IssueCategory(
          title: 'Water Leakage',
          subtitle: 'Leakage from pipe or filter body',
          icon: Icons.water_drop_outlined,
        ),
        _IssueCategory(
          title: 'No Water Flow',
          subtitle: 'Very slow or zero water dispensing',
          icon: Icons.speed_rounded,
        ),
        _IssueCategory(
          title: 'Not Powering On',
          subtitle: 'SMPS adapter or motor dead',
          icon: Icons.bolt_rounded,
        ),
        _IssueCategory(
          title: 'Continuous Waste',
          subtitle: 'Waste water draining non-stop',
          icon: Icons.replay_rounded,
        ),
        _IssueCategory(
          title: 'Installation',
          subtitle: 'Uninstallation or new RO setup',
          icon: Icons.build_rounded,
        ),
        _IssueCategory(
          title: 'Others',
          subtitle: 'TDS issue, UV lamp, pump repair',
          icon: Icons.more_horiz_rounded,
        ),
      ];
    }

    // Default Electrical / Electronics
    return const [
      _IssueCategory(
        title: 'Power Failure',
        subtitle: 'No power, tripping, MCB issues',
        icon: Icons.bolt_rounded,
      ),
      _IssueCategory(
        title: 'Switch & Socket',
        subtitle: 'Loose, damaged or not working',
        icon: Icons.toggle_on_outlined,
      ),
      _IssueCategory(
        title: 'Lighting & Fixtures',
        subtitle: 'Flickering, LED, ceiling lights',
        icon: Icons.lightbulb_outline_rounded,
      ),
      _IssueCategory(
        title: 'Wiring & Rewiring',
        subtitle: 'New wiring, old wiring replacement',
        icon: Icons.cable_rounded,
      ),
      _IssueCategory(
        title: 'Fan',
        subtitle: 'Ceiling/exhaust fan issues',
        icon: Icons.mode_fan_off_rounded,
      ),
      _IssueCategory(
        title: 'Appliance Installation',
        subtitle: 'AC, TV, fridge, etc. installation',
        icon: Icons.kitchen_rounded,
      ),
      _IssueCategory(
        title: 'MCB & Fuse Box',
        subtitle: 'MCB trip, fuse issue, box replacement',
        icon: Icons.settings_input_component_rounded,
      ),
      _IssueCategory(
        title: 'Others',
        subtitle: 'Other electrical issues',
        icon: Icons.more_horiz_rounded,
      ),
    ];
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (_uploadedPhotos.length >= 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 5 photos can be uploaded'),
            backgroundColor: Color(0xFFD97706),
          ),
        );
        return;
      }

      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1600,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _uploadedPhotos.add(UploadedPhotoItem(
            path: file.path,
            name: file.name,
            bytes: bytes,
          ));
        });
      }
    } catch (e) {
      debugPrint('[BookTechnicianScreen] Image pick error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access camera/photos: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  Future<void> _pickMultiFromGallery() async {
    try {
      final remaining = 5 - _uploadedPhotos.length;
      if (remaining <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 5 photos can be uploaded'),
            backgroundColor: Color(0xFFD97706),
          ),
        );
        return;
      }

      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1600,
        limit: remaining,
      );

      if (files.isNotEmpty) {
        for (final file in files.take(remaining)) {
          final bytes = await file.readAsBytes();
          _uploadedPhotos.add(UploadedPhotoItem(
            path: file.path,
            name: file.name,
            bytes: bytes,
          ));
        }
        setState(() {});
      }
    } catch (e) {
      debugPrint('[BookTechnicianScreen] Multi-image pick error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access gallery: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  void _showAddPhotoModal() {
    if (_uploadedPhotos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 photos can be uploaded'),
          backgroundColor: Color(0xFFD97706),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Upload Photo of Issue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Take a photo or choose from your device gallery',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Take Photo with Camera',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Capture the damaged part directly'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFDCFCE7),
                  child: Icon(Icons.photo_library_rounded, color: Color(0xFF16A34A)),
                ),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select photos from your device gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickMultiFromGallery();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditAddressDialog() {
    final controller = TextEditingController(text: _serviceAddress);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Service Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: TextField(
          controller: controller,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Enter complete street address, city, pincode',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _serviceAddress = controller.text.trim());
              }
              Navigator.pop(dialogCtx);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _navigateToChooseSlot() {
    final categories = _getIssueCategories();
    final selectedCategory =
        categories[_selectedIssueIndex.clamp(0, categories.length - 1)];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChooseAppointmentSlotScreen(
          serviceTitle: widget.serviceTitle,
          parentCategory: widget.parentCategory,
          serviceAddress: _serviceAddress,
          selectedIssue: selectedCategory.title,
          issueDesc: _descController.text.trim(),
          uploadedPhotos: _uploadedPhotos.map((p) => p.path).toList(),
          preferredDate: _selectedDate,
          basePrice: widget.basePrice,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final dayName = weekdays[dt.weekday - 1];
    final monthName = months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
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

                    // ── Header: Back button + Title & Category Subtitle ─────
                    _buildHeader(context),

                    const SizedBox(height: 14),

                    // ── 3 Badges Row ────────────────────────────────────────
                    _buildBadgesRow(),

                    const SizedBox(height: 20),

                    // ── 1. Select the Issue Category ────────────────────────
                    _buildSelectIssueCategorySection(),

                    const SizedBox(height: 22),

                    // ── 2. Describe the Issue ───────────────────────────────
                    _buildDescribeIssueSection(),

                    const SizedBox(height: 22),

                    // ── 3. Add Photos (Optional) ────────────────────────────
                    _buildAddPhotosSection(),

                    const SizedBox(height: 22),

                    // ── 4. Service Address ──────────────────────────────────
                    _buildServiceAddressSection(),

                    const SizedBox(height: 22),

                    // ── 5. Preferred Date ───────────────────────────────────
                    _buildPreferredDateSection(context),

                    const SizedBox(height: 16),

                    // ── Safe, Verified & Professional Service Banner ────────
                    _buildSafeServiceBanner(),

                    const SizedBox(height: 14),

                    // ── Verified Professionals Banner (Placed at the end, no forward icon) ─
                    _buildVerifiedProfessionalsBanner(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Bottom Button & Security Disclaimer ─────────────────────────
            _buildBottomBar(),
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
            children: [
              const Text(
                'Book a Technician',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    size: 14,
                    color: Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    widget.serviceTitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 40), // Balance 40px circular back button
      ],
    );
  }

  // ── Verified Professionals Banner (At the end, without forward icon) ──────

  Widget _buildVerifiedProfessionalsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Color(0xFF2563EB),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verified Professionals',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Skilled & background verified technicians at your doorstep',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 3 Badges Row ──────────────────────────────────────────────────────────

  Widget _buildBadgesRow() {
    return Row(
      children: const [
        Expanded(
          child: _BadgePill(
            icon: Icons.access_time_rounded,
            iconColor: Color(0xFF2563EB),
            label: 'On-time Service',
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: _BadgePill(
            icon: Icons.shield_outlined,
            iconColor: Color(0xFF7C3AED),
            label: 'Up to 30 Days Warranty',
          ),
        ),
        SizedBox(width: 6),
        Expanded(
          child: _BadgePill(
            icon: Icons.sell_outlined,
            iconColor: Color(0xFFD97706),
            label: 'Transparent Pricing',
          ),
        ),
      ],
    );
  }

  // ── 1. Select the Issue Category ──────────────────────────────────────────

  Widget _buildSelectIssueCategorySection() {
    final categories = _getIssueCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '1. Select the Issue Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Category: ${widget.serviceTitle}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4 Columns Grid (or 4x2 in screenshot)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisExtent: 110,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final item = categories[index];
            final isSelected = _selectedIssueIndex == index;

            return GestureDetector(
              onTap: () => setState(() => _selectedIssueIndex = index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFDBEAFE)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              size: 18,
                              color: isSelected
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? const Color(0xFF1E3A8A)
                                  : const Color(0xFF0F172A),
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 7.5,
                              color: Color(0xFF64748B),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Top-right checkmark when selected
                    if (isSelected)
                      const Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── 2. Describe the Issue ─────────────────────────────────────────────────

  Widget _buildDescribeIssueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Describe the Issue',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _descController,
                maxLines: 4,
                maxLength: 300,
                buildCounter: (_, {required currentLength, required isFocused, maxLength}) =>
                    Text(
                  '$currentLength/$maxLength',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                ),
                style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  hintText:
                      'Please describe what is happening (e.g., switch is not working, no power in one room, AC not starting, strange sound, etc.)',
                  hintStyle: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── 3. Add Photos (Optional) ──────────────────────────────────────────────

  Widget _buildAddPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '3. Add Photos (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${_uploadedPhotos.length}/5 uploaded',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _uploadedPhotos.isEmpty
                    ? const Color(0xFF64748B)
                    : const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Upload photos of the damaged part, switch, appliance or area to help our technician understand the issue better.',
          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
        ),
        const SizedBox(height: 12),

        // Horizontal list of photo cards + Add button
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Add button (only if < 5)
              if (_uploadedPhotos.length < 5)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: _showAddPhotoModal,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF93C5FD),
                          width: 1.5,
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            size: 22,
                            color: Color(0xFF2563EB),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '+ Add Photo',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Uploaded Photos
              ...List.generate(_uploadedPhotos.length, (index) {
                final photo = _uploadedPhotos[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildPhotoThumbnail(photo, index),
                );
              }),

              // Helper message if empty
              if (_uploadedPhotos.isEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 15, color: Color(0xFF64748B)),
                      SizedBox(width: 6),
                      Text(
                        'Tap "+ Add Photo" to take or pick photos',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(UploadedPhotoItem photo, int index) {
    return Stack(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFCBD5E1)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: photo.bytes != null
              ? Image.memory(
                  photo.bytes!,
                  width: 84,
                  height: 84,
                  fit: BoxFit.cover,
                )
              : (!kIsWeb && File(photo.path).existsSync())
                  ? Image.file(
                      File(photo.path),
                      width: 84,
                      height: 84,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image_rounded,
                            size: 24, color: Color(0xFF94A3B8)),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image_rounded,
                          size: 26, color: Color(0xFF2563EB)),
                    ),
        ),
        // Remove button
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _uploadedPhotos.removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xCC0F172A),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── 4. Service Address ────────────────────────────────────────────────────

  Widget _buildServiceAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. Service Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // Selected Address Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.radio_button_checked_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Current Location',
                          style: TextStyle(
                            fontSize: 12.5,
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
                            'HOME',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _serviceAddress,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Edit Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: const Size(0, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _showEditAddressDialog,
                icon: const Icon(Icons.edit_outlined, size: 13),
                label: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Add New Address Dashed Button
        InkWell(
          onTap: _showEditAddressDialog,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFBFDBFE),
                style: BorderStyle.solid,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 16, color: Color(0xFF2563EB)),
                SizedBox(width: 4),
                Text(
                  'Add New Address',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── 5. Preferred Date ─────────────────────────────────────────────────────

  Widget _buildPreferredDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5. Preferred Date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        InkWell(
          onTap: () => _pickDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Safe, Verified & Professional Service Banner ──────────────────────────

  Widget _buildSafeServiceBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: Color(0xFF16A34A),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Safe, Verified & Professional Service',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '100% background checked, certified professionals with up to 30 days post-repair warranty.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF475569),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Button & Security Disclaimer ───────────────────────────────────

  Widget _buildBottomBar() {
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
              onPressed: _navigateToChooseSlot,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Continue to Choose Slot',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 12,
                color: Color(0xFFD97706),
              ),
              SizedBox(width: 4),
              Text(
                'You can review all details before final booking.',
                style: TextStyle(
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

// ── Private Helper Models & Widgets ───────────────────────────────────────────

class _IssueCategory {
  const _IssueCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
