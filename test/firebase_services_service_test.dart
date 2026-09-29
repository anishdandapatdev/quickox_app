import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:quickox_technician_app/core/services/firebase_services_service.dart';

void main() {
  group('FirebaseServicesService Tests', () {
    test('defaultServices has 13 services matching explore_service.jsx', () {
      expect(FirebaseServicesService.defaultServices.length, 13);
      final titles = FirebaseServicesService.defaultServices
          .map((s) => s.title)
          .toList();

      expect(titles.contains('AC Deep Jet Cleaning & Servicing'), isTrue);
      expect(titles.contains('AC Gas Leakage Check & Refilling'), isTrue);
      expect(titles.contains('Switchboard & Socket Restoration'), isTrue);
      expect(titles.contains('Water Purifier RO Filter & Membrane Replacement'),
          isTrue);
      expect(titles.contains('Pipe Leakage & Tap Valve Repair'), isTrue);
    });

    test('fetchServices with limit returns exact count', () async {
      final service = FirebaseServicesService();
      final services = await service.fetchServices(limit: 4);
      expect(services.length, 4);
    });

    test('fetchServices parses mock Firestore JSON accurately', () async {
      final mockClient = MockClient((request) async {
        final mockJson = '''
        {
          "documents": [
            {
              "name": "projects/home-service-haldia/databases/(default)/documents/services/test1",
              "fields": {
                "title": {"stringValue": "Custom AC Jet Service"},
                "category": {"stringValue": "❄️ AC Service"},
                "desc": {"stringValue": "High pressure jet pump wash."},
                "price": {"stringValue": "549"},
                "rating": {"stringValue": "4.9"},
                "frequency": {"stringValue": "One-Time"},
                "isActive": {"booleanValue": true}
              }
            },
            {
              "name": "projects/home-service-haldia/databases/(default)/documents/services/test2",
              "fields": {
                "title": {"stringValue": "Inactive Service"},
                "isActive": {"booleanValue": false}
              }
            }
          ]
        }
        ''';
        return http.Response(mockJson, 200, headers: {'content-type': 'application/json'});
      });

      final service = FirebaseServicesService(client: mockClient);
      final list = await service.fetchServices();

      expect(list.length, 1);
      expect(list.first.title, 'Custom AC Jet Service');
      expect(list.first.category, 'AC Service');
      expect(list.first.price, '₹ 549/-');
      expect(list.first.rating, '4.9');
    });

    test('fetchServices connects to real Firestore or falls back gracefully', () async {
      final service = FirebaseServicesService();
      final list = await service.fetchServices(limit: 4);
      expect(list.length, 4);
      for (final s in list) {
        expect(s.title.isNotEmpty, isTrue);
        expect(s.price.isNotEmpty, isTrue);
      }
    });

    test('defaultVerticals has 8 Super App verticals matching multiServiceData.js', () {
      expect(FirebaseServicesService.defaultVerticals.length, 8);
      final ids = FirebaseServicesService.defaultVerticals.map((v) => v.id).toList();
      expect(ids, containsAll([
        'home_care',
        'food_delivery',
        'bike_cab',
        'event_booking',
        'ambulance',
        'medicine_delivery',
        'room_booking',
        'electra_scooty',
      ]));
    });

    test('fetchVerticals returns 8 verticals with fallback and Firestore enhancement', () async {
      final service = FirebaseServicesService();
      final verticals = await service.fetchVerticals();
      expect(verticals.length, 8);
      expect(verticals.any((v) => v.id == 'home_care'), isTrue);
      expect(verticals.any((v) => v.id == 'medicine_delivery'), isTrue);
      expect(verticals.any((v) => v.id == 'food_delivery'), isTrue);
    });

    test('fetchCategories returns categories with fallback or Firestore integration', () async {
      final service = FirebaseServicesService();
      final categories = await service.fetchCategories();
      expect(categories.isNotEmpty, isTrue);
      final titles = categories.map((c) => c.title.toLowerCase()).toList();
      expect(titles.any((t) => t.contains('ac')), isTrue);
      expect(titles.any((t) => t.contains('electrical')), isTrue);
      expect(titles.any((t) => t.contains('plumbing')), isTrue);
    });

    test('fetchServicesForCategory filters by category, frequency and query', () async {
      final service = FirebaseServicesService();

      // Non-home category
      final foodServices = await service.fetchServicesForCategory(categoryName: 'Food Delivery');
      expect(foodServices.isNotEmpty, isTrue);
      expect(foodServices.any((s) => s.title.contains('Tiffin')), isTrue);

      // Home category with frequency filter
      final oneTimeAc = await service.fetchServicesForCategory(
        categoryName: 'AC',
        frequency: 'One-Time',
      );
      expect(oneTimeAc.isNotEmpty, isTrue);
      for (final s in oneTimeAc) {
        expect(s.frequency.toLowerCase(), 'one-time');
      }

      // Query filter
      final searchFiltered = await service.fetchServicesForCategory(
        categoryName: 'All',
        query: 'Switchboard',
      );
      expect(searchFiltered.isNotEmpty, isTrue);
      expect(searchFiltered.first.title.toLowerCase().contains('switchboard'), isTrue);
    });

    test('isHomeServiceCategory accurately identifies home vs non-home service verticals', () {
      // Home service categories
      expect(FirebaseServicesService.isHomeServiceCategory('AC Service'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Electrical Services'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Plumbing Services'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('RO Water Purifier'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Water Pump'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Geyser'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Ceiling Fan'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Carpentry Services'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Painting Services'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Cleaning Services'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Pest Control'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Inverter & Battery'), isTrue);
      expect(FirebaseServicesService.isHomeServiceCategory('Solar Services'), isTrue);

      // Other Super App verticals should be strictly excluded
      expect(FirebaseServicesService.isHomeServiceCategory('food_delivery'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('Food Delivery'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('bike_cab'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('Bike & Cab Service'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('ambulance'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('Emergency Ambulance'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('medicine_delivery'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('Medicine Delivery'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('room_booking'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('Room Booking'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('electra_scooty'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('Electra Scooty'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('event_booking'), isFalse);
      expect(FirebaseServicesService.isHomeServiceCategory('Event Booking'), isFalse);
    });

    test('fetchCategories strictly excludes non-home verticals', () async {
      final service = FirebaseServicesService();
      final categories = await service.fetchCategories();
      for (final c in categories) {
        expect(FirebaseServicesService.isHomeServiceCategory(c.id), isTrue);
        expect(FirebaseServicesService.isHomeServiceCategory(c.title), isTrue);
      }
    });

    test('fetchServiceDetail returns rich model with inclusions, FAQs and steps', () async {
      final service = FirebaseServicesService();
      final detail = await service.fetchServiceDetail('AC Deep Cleaning');
      expect(detail.heroTitle.isNotEmpty, isTrue);
      expect(detail.heroDesc.isNotEmpty, isTrue);
      expect(detail.inclusions.isNotEmpty, isTrue);
      expect(detail.faqs.isNotEmpty, isTrue);
      expect(detail.howItWorks.isNotEmpty, isTrue);
    });
  });
}
