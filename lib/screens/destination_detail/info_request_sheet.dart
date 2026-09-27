import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/destination_model.dart';
import '../../providers/app_settings_provider.dart';
import '../../services/analytics_service.dart';
import '../../services/destination_info_request_service.dart';

/// Lets the traveller email the operator a question about [destination].
Future<void> requestDestinationInfo(
BuildContext context,
Destination destination,
) async {
  final formResult = await _showInfoRequestSheet(context);
  if (formResult == null || !context.mounted) {
    return;
  }

  final localizations = AppLocalizations.of(context);
  final requestData = DestinationInfoRequestData(
    questionType: formResult.questionType,
    preferredContact: formResult.preferredContact,
  );
  final subject = DestinationInfoRequestService.buildSubject(
    localizations,
    destination,
  );
  final body = DestinationInfoRequestService.buildBody(
    localizations,
    destination,
    requestData,
  );

  final mailUri = Uri(
    scheme: 'mailto',
    path: context.read<AppSettingsProvider>().settings.supportEmail,
    queryParameters: <String, String>{
      'subject': subject,
      'body': body,
    },
  );

  final launched = await launchUrl(mailUri);

  if (!context.mounted) {
    return;
  }

  if (launched) {
    context.read<AnalyticsService>().trackEvent(
      'destination_info_requested',
      properties: DestinationInfoRequestService.analyticsPayload(
        destination,
        requestData,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.infoEmailOpened),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(localizations.emailAppUnavailable),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<_InfoRequestFormResult?> _showInfoRequestSheet(BuildContext context) {
  final localizations = AppLocalizations.of(context);
  final questionTypes =
      DestinationInfoRequestService.localizedQuestionTypes(localizations);
  String selectedQuestionType = questionTypes.first;
  final contactController = TextEditingController();

  return showModalBottomSheet<_InfoRequestFormResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.requestDestinationInfo,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedQuestionType,
                  decoration: InputDecoration(
                    labelText: localizations.questionType,
                    border: const OutlineInputBorder(),
                  ),
                  items: questionTypes
                      .map(
                        (questionType) => DropdownMenuItem<String>(
                          value: questionType,
                          child: Text(questionType),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setModalState(() {
                      selectedQuestionType = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contactController,
                  decoration: InputDecoration(
                    labelText: localizations.preferredContact,
                    hintText: localizations.emailOrPhoneNumber,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final preferredContact = contactController.text.trim();
                      if (preferredContact.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(localizations.pleaseEnterPreferredContact),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      Navigator.of(sheetContext).pop(
                        _InfoRequestFormResult(
                          questionType: selectedQuestionType,
                          preferredContact: preferredContact,
                        ),
                      );
                    },
                    child: Text(localizations.continueAction),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _InfoRequestFormResult {
  final String questionType;
  final String preferredContact;

  const _InfoRequestFormResult({
    required this.questionType,
    required this.preferredContact,
  });
}