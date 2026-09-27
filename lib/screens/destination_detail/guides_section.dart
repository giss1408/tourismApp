import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/travel_models.dart';
import '../../repositories/travel_repository.dart';
import '../../widgets/common/external_links.dart';
import '../../widgets/optimized_network_image.dart';
import 'section_title.dart';

const _languageFlags = {'fr': '🇫🇷', 'en': '🇬🇧', 'de': '🇩🇪', 'it': '🇮🇹', 'es': '🇪🇸'};

/// Local guides for this destination, reachable on WhatsApp. Hidden when
/// the operator has not assigned any.
class GuidesSection extends StatefulWidget {
  final String destinationId;
  final String destinationName;

  const GuidesSection({
    super.key,
    required this.destinationId,
    required this.destinationName,
  });

  @override
  State<GuidesSection> createState() => _GuidesSectionState();
}

class _GuidesSectionState extends State<GuidesSection> {
  late final Future<List<Guide>> _guides =
      context.read<TravelRepository>().fetchGuides(widget.destinationId);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FutureBuilder<List<Guide>>(
      future: _guides,
      builder: (context, snapshot) {
        final guides = snapshot.data ?? const <Guide>[];
        if (guides.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailSectionTitle(t.translate('localGuides')),
            const SizedBox(height: 4),
            Text(t.translate('localGuidesSubtitle'),
                style: TextStyle(color: Theme.of(context).hintColor)),
            const SizedBox(height: 12),
            ...guides.map((guide) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 26,
                          child: guide.photoUrl.isEmpty
                              ? Text(guide.name.isEmpty ? '?' : guide.name[0])
                              : ClipOval(
                                  child: OptimizedNetworkImage(
                                    imageUrl: guide.photoUrl,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(guide.name,
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              if (guide.languages.isNotEmpty)
                                Text(guide.languages
                                    .map((code) => _languageFlags[code] ?? code.toUpperCase())
                                    .join('  ')),
                              if (guide.bio.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(guide.bio,
                                    maxLines: 3, overflow: TextOverflow.ellipsis),
                              ],
                              const SizedBox(height: 8),
                              WhatsAppButton(
                                number: guide.whatsapp,
                                label: t.translate('contactOnWhatsApp'),
                                message: t
                                    .translate('guideWhatsAppMessage')
                                    .replaceAll('{destination}', widget.destinationName),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
