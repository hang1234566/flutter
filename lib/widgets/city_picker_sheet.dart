import 'package:flutter/material.dart';

import '../utils/flight_format.dart';

Future<String?> showCityPickerSheet(BuildContext context, {required String title}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.45),
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 6, 0),
              child: Row(
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kFlightCities.map((city) {
                    return _CityChip(
                      city: city,
                      onTap: () => Navigator.pop(ctx, city),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _CityChip extends StatelessWidget {
  const _CityChip({required this.city, required this.onTap});

  final String city;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF4F7F6),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                cityCode(city),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF00A884),
                ),
              ),
              const SizedBox(width: 6),
              Text(city, style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
