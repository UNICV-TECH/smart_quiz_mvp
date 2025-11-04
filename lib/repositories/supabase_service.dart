import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Pega o usuário logado (dados do Auth)
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    // Como os dados estão na tabela interna auth.users, acessamos direto:
    return UserModel(
      id: user.id,
      name: user.userMetadata?['full_name'] ?? 'Usuário',
      email: user.email ?? '',
    );
  }

  // Atualiza o nome do usuário diretamente no metadata do Supabase Auth
  Future<bool> updateUserName(String newName) async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    final response = await _client.auth.updateUser(
      UserAttributes(
        data: {'full_name': newName},
      ),
    );

    return response.user != null;
  }
}
