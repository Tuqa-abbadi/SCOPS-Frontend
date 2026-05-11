import 'package:flutter/material.dart';

// ── Feedback / Rating Screen ──────────────────────────────────────────────
// TODO Sprint 4: wire _submit() to POST /feedback API with rating + comment.

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen>
    with TickerProviderStateMixin {
  int _rating      = 0;
  int _hoverRating = 0;
  final _commentCtrl = TextEditingController();
  String? _selectedTag;
  bool _submitted  = false;
  bool _loading    = false;

  late AnimationController _successCtrl;
  late Animation<double> _successAnim;

  static const _bg     = Color(0xFF020812);
  static const _card   = Color(0xFF07111C);
  static const _cyan   = Color(0xFF18E8F2);
  static const _orange = Color(0xFFFF5A14);
  static const _white  = Colors.white;
  static const _muted  = Color(0xFF9BA4B0);

  final _tags = [
    '👍 Easy to use',
    '🎨 Great design',
    '🔔 Helpful reminders',
    '🐛 Found a bug',
    '💡 Feature request',
    '🤔 Confusing UX',
  ];

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _successAnim = CurvedAnimation(parent: _successCtrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  String _ratingLabel(int r) {
    switch (r) {
      case 1: return 'Very poor 😞';
      case 2: return 'Poor 😕';
      case 3: return 'Okay 😐';
      case 4: return 'Good 😊';
      case 5: return 'Excellent! 🎉';
      default: return 'Tap a star to rate';
    }
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a rating first.'),
          backgroundColor: _orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _loading = true);

    // TODO Sprint 4: replace with real API call:
    // await FeedbackRepository.submit(
    //   rating: _rating,
    //   comment: _commentCtrl.text.trim(),
    //   tag: _selectedTag,
    // );
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() { _loading = false; _submitted = true; });
    _successCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _submitted ? _successView() : _formView(),
      ),
    );
  }

  Widget _formView() => Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 20, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: _white, size: 20),
                ),
                const Text('Feedback',
                    style: TextStyle(
                        color: _white, fontSize: 22, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prompt
                  const Text('How\'s your SCOPS experience?',
                      style: TextStyle(
                          color: _white, fontSize: 22, fontWeight: FontWeight.w900, height: 1.3)),
                  const SizedBox(height: 6),
                  const Text('Your feedback helps us improve the app for everyone.',
                      style: TextStyle(color: _muted, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 32),

                  // ── Star Rating ──────────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            final starVal = i + 1;
                            final filled  = starVal <= (_hoverRating > 0 ? _hoverRating : _rating);
                            return GestureDetector(
                              onTap: () => setState(() { _rating = starVal; _hoverRating = 0; }),
                              onTapDown: (_) => setState(() => _hoverRating = starVal),
                              onTapCancel: () => setState(() => _hoverRating = 0),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: AnimatedScale(
                                  scale: _hoverRating == starVal ? 1.3 : (_rating == starVal ? 1.15 : 1.0),
                                  duration: const Duration(milliseconds: 150),
                                  child: Icon(
                                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                                    size: 44,
                                    color: filled ? const Color(0xFFFFB020) : _muted.withOpacity(0.4),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            _ratingLabel(_hoverRating > 0 ? _hoverRating : _rating),
                            key: ValueKey(_hoverRating > 0 ? _hoverRating : _rating),
                            style: TextStyle(
                              color: _rating >= 4 ? _cyan : _rating >= 3 ? _muted : _orange,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Quick Tags ───────────────────────────────────────────
                  const Text('What stood out?',
                      style: TextStyle(color: _white, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _tags.map((tag) {
                      final selected = _selectedTag == tag;
                      return GestureDetector(
                        onTap: () => setState(() =>
                            _selectedTag = selected ? null : tag),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? _cyan.withOpacity(0.15) : _card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: selected ? _cyan.withOpacity(0.5) : Colors.white.withOpacity(0.08)),
                          ),
                          child: Text(tag,
                              style: TextStyle(
                                  color: selected ? _cyan : _muted,
                                  fontSize: 12,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // ── Comment Box ──────────────────────────────────────────
                  const Text('Tell us more (optional)',
                      style: TextStyle(color: _white, fontSize: 15, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: TextField(
                      controller: _commentCtrl,
                      maxLines: 5,
                      maxLength: 500,
                      style: const TextStyle(color: _white, fontSize: 14, height: 1.5),
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts, suggestions, or report an issue...',
                        hintStyle: TextStyle(color: _muted.withOpacity(0.55), fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        counterStyle: const TextStyle(color: _muted, fontSize: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Submit ───────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: _white,
                        disabledBackgroundColor: _orange.withOpacity(0.4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : const Text('Submit Feedback',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _successView() => ScaleTransition(
        scale: _successAnim,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cyan.withOpacity(0.12),
                    border: Border.all(color: _cyan.withOpacity(0.4)),
                    boxShadow: [BoxShadow(color: _cyan.withOpacity(0.20), blurRadius: 40)],
                  ),
                  child: const Icon(Icons.check_rounded, color: _cyan, size: 52),
                ),
                const SizedBox(height: 28),
                const Text('Thank you! 🎉',
                    style: TextStyle(
                        color: _white, fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                const Text(
                  'Your feedback has been submitted.\nWe truly appreciate your input — it helps us build a better SCOPS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: _muted, fontSize: 14, height: 1.6),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _card,
                      foregroundColor: _white,
                      elevation: 0,
                      side: BorderSide(color: Colors.white.withOpacity(0.10)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Back to Profile',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}