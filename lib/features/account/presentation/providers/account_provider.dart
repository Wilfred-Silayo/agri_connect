import 'package:agri_connect/core/shared/providers/supabase_client_provider.dart';
import 'package:agri_connect/features/account/datasources/account_remote.dart';
import 'package:agri_connect/features/account/models/account_model.dart';
import 'package:agri_connect/features/account/presentation/providers/account_state.dart';
import 'package:agri_connect/features/account/repository/account_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>((
  ref,
) {
  final client = ref.watch(supabaseClientProvider);
  return AccountNotifier(AccountRepositoryImpl(client));
});

final userAccountProvider = FutureProvider.family<AccountModel, String>((
  ref,
  userId,
) {
  return ref.read(accountProvider.notifier).getAccountById(userId);
});

class AccountNotifier extends StateNotifier<AccountState> {
  final AccountRemote remote;

  AccountNotifier(this.remote) : super(AccountInitial());

  Future<AccountModel> getAccountById(String userId) async {
    final account = await remote.getAccount(userId);
    if (account != null) return account;
    return AccountModel(
      id: '',
      userId: userId,
      balance: 0.00,
      createdAt: DateTime.now(),
    );
  }

  Future<void> deposit(String userId, double amount) async {
    try {
      state = AccountLoading();
      final account = await remote.deposit(userId, amount);
      state = AccountLoaded(account);
    } catch (e) {
      state = AccountError(e.toString());
      rethrow;
    }
  }

  Future<void> withdraw(String userId, double amount) async {
    try {
      state = AccountLoading();
      final account = await remote.withdraw(userId, amount);
      state = AccountLoaded(account);
    } catch (e) {
      state = AccountError(e.toString());
      rethrow;
    }
  }
}
