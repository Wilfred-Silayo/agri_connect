import 'package:agri_connect/features/account/models/account_model.dart';
import 'package:agri_connect/features/account/repository/account_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountRepositoryImpl implements AccountRemote {
  final SupabaseClient client;

  AccountRepositoryImpl(this.client);

  @override
  Future<AccountModel?> getAccount(String userId) async {
    final response =
        await client
            .from('accounts')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

    if (response == null) return null;
    return AccountModel.fromMap(response);
  }

  Stream<AccountModel?> streamAccount(String userId) {
  return client
      .from('accounts')
      .stream(primaryKey: ['id']) 
      .eq('user_id', userId)
      .limit(1)
      .map((event) {
        if (event.isEmpty) return null;
        return AccountModel.fromMap(event.first);
      });
}


  @override
  Future<AccountModel> deposit(String userId, double amount) async {
    final existing = await getAccount(userId);
    if (existing != null) {
      final updated =
          await client
              .from('accounts')
              .update({'balance': existing.balance + amount})
              .eq('user_id', userId)
              .select()
              .single();

      return AccountModel.fromMap(updated);
    } else {
      final inserted =
          await client
              .from('accounts')
              .insert({'user_id': userId, 'balance': amount})
              .select()
              .single();

      return AccountModel.fromMap(inserted);
    }
  }

  @override
  Future<AccountModel> withdraw(String userId, double amount) async {
    final existing = await getAccount(userId);
    if (existing == null || existing.balance < amount) {
      throw Exception('Insufficient balance.');
    }

    final updated =
        await client
            .from('accounts')
            .update({'balance': existing.balance - amount})
            .eq('user_id', userId)
            .select()
            .single();

    return AccountModel.fromMap(updated);
  }
}
