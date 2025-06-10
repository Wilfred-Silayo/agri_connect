import 'package:agri_connect/features/account/presentation/providers/account_provider.dart';
import 'package:agri_connect/features/account/presentation/providers/account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AccountPage extends ConsumerStatefulWidget {
  final String userId;

  const AccountPage({super.key, required this.userId});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final depositController = TextEditingController();
  final withdrawController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(accountProvider.notifier).loadAccount(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account Balance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            state is AccountLoading
                ? const Center(child: CircularProgressIndicator())
                : state is AccountError
                ? Center(child: Text(state.message))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Balance: TZS ${(state is AccountLoaded) ? state.account.balance.toStringAsFixed(2) : '0.00'}',
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 30),
                    TextField(
                      controller: depositController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Deposit Amount',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(depositController.text);
                        if (amount != null) {
                          ref
                              .read(accountProvider.notifier)
                              .deposit(widget.userId, amount);
                        }
                      },
                      child: const Text('Deposit'),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: withdrawController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Withdraw Amount',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(withdrawController.text);
                        if (amount != null) {
                          ref
                              .read(accountProvider.notifier)
                              .withdraw(widget.userId, amount);
                        }
                      },
                      child: const Text('Withdraw'),
                    ),
                  ],
                ),
      ),
    );
  }
}
