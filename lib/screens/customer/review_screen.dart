import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../data/dummy_data.dart';
import '../../models/models.dart';

class ReviewScreen extends StatefulWidget {
  final AppointmentModel appointment;
  const ReviewScreen({super.key, required this.appointment});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')),
      );
      return;
    }

    // Add review
    barberReviews.add(
      ReviewModel(
        id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
        barberId: widget.appointment.barberId,
        customerId: widget.appointment.customerId,
        customerName: widget.appointment.customerName,
        customerInitial: widget.appointment.customerInitial,
        rating: _rating,
        comment: _commentCtrl.text.trim(),
        date: 'Just now',
      ),
    );

    // Mark appointment reviewLeft = true using copyWith
    final idx = customerBookings.indexWhere(
      (b) => b.id == widget.appointment.id,
    );
    if (idx != -1) {
      customerBookings[idx] = customerBookings[idx].copyWith(reviewLeft: true);
    }

    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Leave a Review',
          style: TextStyle(
            color: AppTheme.textDark,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: _submitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appointment summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.secondary.withValues(alpha: 0.12),
                child: Text(
                  widget.appointment.customerInitial,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.appointment.barberName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${widget.appointment.serviceName} · ${widget.appointment.date}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textGrey,
                      ),
                    ),
                    Text(
                      '₹${widget.appointment.price}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
        const Text(
          'How was your experience?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your feedback helps other customers',
          style: TextStyle(fontSize: 13, color: AppTheme.textGrey),
        ),

        const SizedBox(height: 24),

        // Stars
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.star_rounded,
                    size: 44,
                    color: i < _rating
                        ? const Color(0xFFEF9F27)
                        : AppTheme.border,
                  ),
                ),
              ),
            ),
          ),
        ),

        if (_rating > 0) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              ['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent!'][_rating],
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _rating >= 4
                    ? AppTheme.primary
                    : _rating == 3
                    ? const Color(0xFFEF9F27)
                    : const Color(0xFFE24B4A),
              ),
            ),
          ),
        ],

        const SizedBox(height: 24),
        const Text(
          'Write a comment (optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _commentCtrl,
          maxLines: 4,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Tell others about your experience...',
            hintStyle: const TextStyle(color: AppTheme.textGrey, fontSize: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            filled: true,
            fillColor: AppTheme.surface,
          ),
        ),

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondary),
          child: const Text('Submit Review'),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              size: 56,
              color: Color(0xFFEF9F27),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Review Submitted!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thank you for your feedback.\nIt helps other customers make better choices.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondary,
            ),
            child: const Text('Back to Bookings'),
          ),
        ],
      ),
    );
  }
}
