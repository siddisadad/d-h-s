import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../domain/entities/contact.dart';
import '../providers/crm_provider.dart';
import '../../../../core/services/sharing_service.dart';

class PaymentRemindersScreen extends ConsumerWidget {
  const PaymentRemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(crmNotifierProvider(ContactType.customer));
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('PAYMENT REMINDERS'),
      ),
      body: customersAsync.when(
        data: (customers) {
          final overdueCustomers = customers.where((c) => c.balance > 0).toList();

          if (overdueCustomers.isEmpty) {
            return const Center(child: Text('No customers with overdue balances.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(tokens.space16),
            itemCount: overdueCustomers.length,
            itemBuilder: (context, index) {
              final customer = overdueCustomers[index];
              return _CustomerReminderCard(customer: customer);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _CustomerReminderCard extends ConsumerWidget {
  final Contact customer;
  const _CustomerReminderCard({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return CustomCard(
      margin: EdgeInsets.only(bottom: tokens.space12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: context.colorScheme.primaryContainer,
                child: Text(customer.initials, style: TextStyle(color: context.colorScheme.onPrimaryContainer)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(customer.name, style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text(customer.contact, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(currency.format(customer.balance),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.error,
                    ),
                  ),
                  Text('Balance', style: context.textTheme.labelSmall),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Last Reminder:', style: context.textTheme.labelSmall),
                  Text(
                    customer.lastReminderSent != null
                        ? dateFormat.format(customer.lastReminderSent!)
                        : 'Never sent',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: customer.lastReminderSent == null ? context.onSurfaceVariantColor : context.successColor,
                    ),
                  ),
                ],
              ),
              CustomButton(
                text: 'Send Reminder',
                size: CustomButtonSize.small,
                variant: CustomButtonVariant.primary,
                icon: Icons.notifications_active_outlined,
                onPressed: () async {
                  final message = 'Namaste ${customer.name},\n\nThis is a friendly reminder from *Deshmukh Hardware & Steel* regarding your outstanding balance of *${currency.format(customer.balance)}*.\n\nKindly arrange for the payment at your earliest convenience. You can pay via UPI or Bank Transfer.\n\nThank you for your business!';

                  await ref.read(sharingServiceProvider.notifier).sendWhatsAppMessage(
                    phone: customer.contact,
                    message: message,
                  );

                  final success = await ref.read(crmNotifierProvider(ContactType.customer).notifier).sendPaymentReminder(customer);

                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Status updated for ${customer.name}')),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
