import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/travel_models.dart';
import '../../repositories/travel_repository.dart';
import '../../services/graphql_service.dart';
import 'section_title.dart';

/// Verified travellers' reviews, and a form for travellers who booked.
class ReviewsSection extends StatefulWidget {
  final String destinationId;

  const ReviewsSection({super.key, required this.destinationId});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  late Future<List<Review>> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = _load();
  }

  Future<List<Review>> _load() =>
      context.read<TravelRepository>().fetchReviews(widget.destinationId);

  Future<void> _writeReview() async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ReviewForm(destinationId: widget.destinationId),
    );
    if (submitted == true && mounted) setState(() => _reviews = _load());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FutureBuilder<List<Review>>(
      future: _reviews,
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? const <Review>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: DetailSectionTitle(t.reviews)),
                TextButton.icon(
                  onPressed: _writeReview,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: Text(t.translate('writeReview')),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (snapshot.connectionState == ConnectionState.waiting)
              const LinearProgressIndicator()
            else if (reviews.isEmpty)
              Text(t.translate('noReviewsYet'),
                  style: TextStyle(color: Theme.of(context).hintColor))
            else
              ...reviews.map((review) => _ReviewTile(review: review)),
          ],
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final date = review.createdAt == null
        ? ''
        : DateFormat.yMMMM(locale).format(review.createdAt!);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                StarRating(rating: review.rating),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${review.authorName} · $date',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(review.comment),
            ],
          ],
        ),
      ),
    );
  }
}

class StarRating extends StatelessWidget {
  final int rating;
  final double size;
  final ValueChanged<int>? onChanged;

  const StarRating({super.key, required this.rating, this.size = 18, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final star = Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber.shade700,
          size: size,
        );
        if (onChanged == null) return star;
        return IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: () => onChanged!(index + 1),
          icon: star,
          tooltip: '${index + 1}/5',
        );
      }),
    );
  }
}

class _ReviewForm extends StatefulWidget {
  final String destinationId;

  const _ReviewForm({required this.destinationId});

  @override
  State<_ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<_ReviewForm> {
  int _rating = 5;
  final _comment = TextEditingController();
  bool _sending = false;
  String _error = '';

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final t = AppLocalizations.of(context);
    setState(() {
      _sending = true;
      _error = '';
    });
    try {
      await context
          .read<TravelRepository>()
          .submitReview(widget.destinationId, _rating, _comment.text.trim());
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e is GraphQlRequestException && e.serverMessage != null
            ? (e.serverMessage!.contains('Only travellers')
                ? t.translate('reviewOnlyAfterBooking')
                : e.serverMessage!)
            : t.translate('reviewFailed');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.translate('writeReview'),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          StarRating(
            rating: _rating,
            size: 32,
            onChanged: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _comment,
            maxLines: 4,
            maxLength: 2000,
            decoration: InputDecoration(
              hintText: t.translate('reviewCommentHint'),
              border: const OutlineInputBorder(),
            ),
          ),
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _sending ? null : _submit,
              child: _sending
                  ? const SizedBox(
                      height: 20, width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(t.translate('publishReview')),
            ),
          ),
        ],
      ),
    );
  }
}
