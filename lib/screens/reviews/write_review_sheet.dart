import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/reviews/reviews_bloc.dart';
import '../../blocs/subscription/subscription_bloc.dart';

/// A modal bottom sheet that lets an eligible user write a review.
///
/// [_rating] is stored as 1–5 stars. On submit it is multiplied by 2 so the
/// backend receives a value in the 1–10 range it expects (2, 4, 6, 8, 10).
/// Reviews fetched back show (rating / 2).round() filled stars.
class WriteReviewSheet extends StatefulWidget {
  const WriteReviewSheet({
    super.key,
    required this.subscription,
    required this.serviceId,
  });

  final SubscriptionModel subscription;
  final int serviceId;

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);
  static const _gold   = Color(0xFFFFB020);

  // 1–5 stars; multiplied by 2 before sending to backend.
  int _rating = 0;
  final _commentCtrl = TextEditingController();

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  // ── Validation & submission ───────────────────────────────────────────────

  void _submit(BuildContext context) {
    if (_rating < 1) {
      _snack(context, 'Please select a star rating.');
      return;
    }
    final comment = _commentCtrl.text.trim();
    context.read<ReviewsBloc>().add(ReviewSubmitRequested(
      serviceId:      widget.serviceId,
      subscriptionId: widget.subscription.apiId,
      rating:         _rating * 2, // map 1–5 → 2–10
      comment:        comment.isEmpty ? null : comment,
    ));
  }

  void _snack(BuildContext context, String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? _orange : _cyan,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── Rating label ──────────────────────────────────────────────────────────

  String get _ratingLabel {
    switch (_rating) {
      case 1:  return 'Poor';
      case 2:  return 'Average';
      case 3:  return 'Good';
      case 4:  return 'Great';
      case 5:  return 'Excellent!';
      default: return 'Tap a star to rate';
    }
  }

  Color get _ratingLabelColor {
    if (_rating == 0) return _muted;
    if (_rating == 1) return _orange;
    if (_rating == 2) return _muted;
    return _gold;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReviewsBloc, ReviewsState>(
      listener: (context, state) {
        if (state is! ReviewsData) return;
        if (state.submitSuccess) {
          context.read<ReviewsBloc>().add(const ReviewSubmitReset());
          _snack(context, 'Review submitted! Thank you.', isError: false);
          Navigator.of(context).pop();
        } else if (state.submitError != null) {
          _snack(context, state.submitError!);
          context.read<ReviewsBloc>().add(const ReviewSubmitReset());
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          24, 20, 24,
          MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Drag handle ──────────────────────────────────────────────────
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Header ───────────────────────────────────────────────────────
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(widget.subscription.serviceIcon,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subscription.serviceName,
                    style: const TextStyle(
                        color: _white, fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  const Text('Write a review',
                      style: TextStyle(color: _muted, fontSize: 12)),
                ],
              )),
            ]),
            const SizedBox(height: 24),

            // ── Rating ───────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Your Rating',
                    style: TextStyle(
                        color: _white, fontSize: 13, fontWeight: FontWeight.w800)),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _ratingLabel,
                    key: ValueKey(_rating),
                    style: TextStyle(
                        color: _ratingLabelColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () => setState(() => _rating = star),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      _rating >= star
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: _gold,
                      size: 40,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // ── Comment (optional) ───────────────────────────────────────────
            Row(children: [
              const Text('Comment',
                  style: TextStyle(
                      color: _white, fontSize: 13, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Text('optional',
                  style: TextStyle(
                      color: _muted.withValues(alpha: 0.65), fontSize: 11)),
            ]),
            const SizedBox(height: 10),
            TextField(
              controller: _commentCtrl,
              maxLines: 3,
              maxLength: 500,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(color: _white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Share your experience (optional)…',
                hintStyle: TextStyle(
                    color: _muted.withValues(alpha: 0.60), fontSize: 13),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                counterStyle:
                    TextStyle(color: _muted.withValues(alpha: 0.60)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _cyan, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Submit button ────────────────────────────────────────────────
            BlocBuilder<ReviewsBloc, ReviewsState>(
              builder: (context, state) {
                final loading   = state is ReviewsData && state.isSubmitting;
                final canSubmit = _rating >= 1 && !loading;
                return SizedBox(
                  width: double.infinity, height: 54,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: canSubmit
                          ? const LinearGradient(colors: [
                              Color(0xFF18E8F2), Color(0xFF0BB8C1)])
                          : null,
                      color: canSubmit
                          ? null
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                    child: ElevatedButton(
                      onPressed: canSubmit ? () => _submit(context) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:     Colors.transparent,
                        shadowColor:         Colors.transparent,
                        foregroundColor:     Colors.black,
                        disabledForegroundColor: _muted,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  color: _cyan, strokeWidth: 2.5))
                          : const Text('Submit Review',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
