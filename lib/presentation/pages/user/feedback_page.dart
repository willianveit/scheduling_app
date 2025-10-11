import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scheduling_app/core/enums/user_role.dart';
import 'package:scheduling_app/presentation/providers/usecase_providers.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  final String slotId;
  final String storeId;
  final UserRole userRole;

  const FeedbackPage({
    super.key,
    required this.slotId,
    required this.storeId,
    this.userRole = UserRole.client,
  });

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _feedbackController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your feedback'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final submitFeedback = ref.read(submitFeedbackProvider);

      await submitFeedback(
        storeId: widget.storeId,
        slotId: widget.slotId,
        feedback: _feedbackController.text.trim(),
        userRole: widget.userRole,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit feedback: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provide Feedback'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.rate_review, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              widget.userRole == UserRole.client
                  ? 'How was your consultation?'
                  : 'Consultation Notes',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.userRole == UserRole.client
                  ? 'Please share your experience with us'
                  : 'Add notes about the consultation',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _feedbackController,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: 'Your Feedback',
                hintText: 'Enter your feedback here...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitFeedback,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(_isSubmitting ? 'Submitting...' : 'Submit Feedback'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Skip for Now'),
            ),
          ],
        ),
      ),
    );
  }
}
