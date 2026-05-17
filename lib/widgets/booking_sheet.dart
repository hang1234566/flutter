import 'package:flutter/material.dart';
import '../models/flight.dart';
import '../services/api_service.dart';
import '../utils/flight_format.dart';

Future<bool?> showFlightBookingSheet(
  BuildContext context,
  Flight flight, {
  VoidCallback? onSuccess,
}) {
  final nameController = TextEditingController();
  final seatsController = TextEditingController(text: '1');
  final formKey = GlobalKey<FormState>();

  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      var submitting = false;
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Đặt vé',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${flight.from} → ${flight.to}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatFlightDate(flight.depart),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Họ tên hành khách',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Nhập tên hành khách' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: seatsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Số ghế (còn ${flight.seatsAvailable})',
                          prefixIcon: const Icon(Icons.event_seat_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        validator: (v) {
                          final n = int.tryParse(v ?? '') ?? 0;
                          if (n < 1) return 'Tối thiểu 1 ghế';
                          if (n > flight.seatsAvailable) {
                            return 'Chỉ còn ${flight.seatsAvailable} ghế';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Tổng: ${formatPrice(flight.price * (int.tryParse(seatsController.text) ?? 1))}',
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: submitting ? null : () => Navigator.pop(ctx, false),
                              child: const Text('Hủy'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: FilledButton(
                              onPressed: submitting || flight.seatsAvailable < 1
                                  ? null
                                  : () async {
                                      if (!formKey.currentState!.validate()) return;
                                      setSheetState(() => submitting = true);
                                      try {
                                        final seats = int.parse(seatsController.text);
                                        final name = nameController.text.trim();
                                        final booking = await ApiService.instance.bookFlight(
                                          flight.id,
                                          name,
                                          seats,
                                        );
                                        if (!context.mounted) return;
                                        Navigator.pop(ctx, true);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Đặt vé thành công · Mã ${booking.id}',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                        onSuccess?.call();
                                      } catch (e) {
                                        setSheetState(() => submitting = false);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString().replaceFirst('Exception: ', '')),
                                            backgroundColor: Colors.red.shade700,
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                              child: submitting
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Xác nhận · ${formatPrice(flight.price)}',
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
