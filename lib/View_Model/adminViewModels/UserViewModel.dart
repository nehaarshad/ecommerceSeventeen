import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import '../../models/UserDetailModel.dart';
import '../../repositories/UserDetailsRepositories.dart';

final UserViewModelProvider = StateNotifierProvider<UserViewModel, AsyncValue<List<UserDetailModel?>>>((
      ref,
    ) {
      return UserViewModel(ref);
    });

class UserViewModel extends StateNotifier<AsyncValue<List<UserDetailModel?>>> {
  final Ref ref;
  UserViewModel(this.ref) : super(AsyncValue.loading()) {
    getallusers();
  }

  Future<void> getallusers() async {
    try {
      List<UserDetailModel?> users = await ref.read(userProvider).getAllUsers();
      state = AsyncValue.data(users.isEmpty ? [] : users);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteusers(String id) async {
    try {
      await ref.read(userProvider).deleteUser(id);
      getallusers();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
