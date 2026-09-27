import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/payment_methods_provider.dart';

/// Demo payment methods (debug builds only; real payments go through Stripe).
Future<void> showPaymentMethodsSheet(
  BuildContext context,
  PaymentMethodsProvider paymentMethodsProvider,
  AppLocalizations localizations,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return Consumer<PaymentMethodsProvider>(
        builder: (context, methodsProvider, _) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.paymentMethods,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (!methodsProvider.isLoaded)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (methodsProvider.methods.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(localizations.noPaymentMethodsYet),
                  )
                else
                  ...methodsProvider.methods.map(
                    (method) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            Icons.credit_card,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(method.maskedLabel),
                        subtitle: Text('${method.holderName} • ${method.expiryLabel}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (method.isDefault)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  localizations.defaultLabel,
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                tooltip: localizations.setDefault,
                                onPressed: () {
                                  methodsProvider.setDefault(method.id);
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: localizations.removeMethod,
                              onPressed: () {
                                methodsProvider.removeMethod(method.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      methodsProvider.addMockMethod();
                    },
                    icon: const Icon(Icons.add),
                    label: Text(localizations.addMockPaymentMethod),
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
