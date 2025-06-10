import 'package:agri_connect/features/account/models/account_model.dart';

abstract class AccountRemote {
  Future<AccountModel?> getAccount(String userId);
  Future<AccountModel> deposit(String userId, double amount);
  Future<AccountModel> withdraw(String userId, double amount);
}
