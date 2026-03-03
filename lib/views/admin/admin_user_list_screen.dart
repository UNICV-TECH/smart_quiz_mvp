import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/admin_user.dart';
import '../../viewmodels/admin/admin_user_management_view_model.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  final _searchController = TextEditingController();

  static const _goldColor = Color(0xFFB8860B);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminUserManagementViewModel>();

    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Row(
              children: [
                const Text(
                  'Gerenciar Usuários',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _goldColor,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: viewModel.refresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Atualizar',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou e-mail...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.setSearchQuery(null);
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                viewModel.setSearchQuery(value);
              },
            ),
          ),

          const SizedBox(height: 12),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip(
                  label: 'Todos',
                  isSelected: viewModel.roleFilter == null,
                  onSelected: (_) => viewModel.setRoleFilter(null),
                ),
                _buildFilterChip(
                  label: 'Alunos',
                  isSelected: viewModel.roleFilter == 'student',
                  onSelected: (_) => viewModel.setRoleFilter('student'),
                ),
                _buildFilterChip(
                  label: 'Professores',
                  isSelected: viewModel.roleFilter == 'teacher',
                  onSelected: (_) => viewModel.setRoleFilter('teacher'),
                ),
                _buildFilterChip(
                  label: 'Admins',
                  isSelected: viewModel.roleFilter == 'admin',
                  onSelected: (_) => viewModel.setRoleFilter('admin'),
                ),
                const SizedBox(width: 16),
                _buildFilterChip(
                  label: 'Ativos',
                  isSelected: viewModel.activeFilter == true,
                  onSelected: (_) => viewModel.setActiveFilter(
                    viewModel.activeFilter == true ? null : true,
                  ),
                ),
                _buildFilterChip(
                  label: 'Inativos',
                  isSelected: viewModel.activeFilter == false,
                  onSelected: (_) => viewModel.setActiveFilter(
                    viewModel.activeFilter == false ? null : false,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Messages
          if (viewModel.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: viewModel.clearMessages,
                    ),
                  ],
                ),
              ),
            ),

          if (viewModel.successMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viewModel.successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: viewModel.clearMessages,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),

          // User list
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.users.isEmpty
                    ? const Center(
                        child: Text(
                          'Nenhum usuário encontrado',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : _buildUserTable(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: const Color(0xFFE8EAF6),
      checkmarkColor: _goldColor,
      labelStyle: TextStyle(
        color: isSelected ? _goldColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildUserTable(
    BuildContext context,
    AdminUserManagementViewModel viewModel,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(const Color(0xFFF5F5F5)),
          columns: const [
            DataColumn(label: Text('Nome', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('E-mail', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Papel', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Provas', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Média', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Ações', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: viewModel.users.map((user) {
            return DataRow(
              cells: [
                DataCell(Text(user.name.isEmpty ? '(sem nome)' : user.name)),
                DataCell(Text(user.email)),
                DataCell(_buildRoleDropdown(context, viewModel, user)),
                DataCell(_buildStatusBadge(user.isActive)),
                DataCell(Text(user.examCount.toString())),
                DataCell(Text('${user.avgScore.toStringAsFixed(1)}%')),
                DataCell(_buildActions(context, viewModel, user)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildRoleDropdown(
    BuildContext context,
    AdminUserManagementViewModel viewModel,
    AdminUserEntry user,
  ) {
    return DropdownButton<String>(
      value: user.role,
      underline: const SizedBox(),
      isDense: true,
      items: const [
        DropdownMenuItem(value: 'student', child: Text('Aluno')),
        DropdownMenuItem(value: 'teacher', child: Text('Professor')),
        DropdownMenuItem(value: 'admin', child: Text('Admin')),
      ],
      onChanged: (newRole) {
        if (newRole != null && newRole != user.role) {
          _confirmAction(
            context,
            title: 'Alterar papel',
            message:
                'Alterar o papel de "${user.name}" de ${_roleLabel(user.role)} para ${_roleLabel(newRole)}?',
            onConfirm: () => viewModel.updateUserRole(user.id, newRole),
          );
        }
      },
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Ativo' : 'Inativo',
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.red[700],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActions(
    BuildContext context,
    AdminUserManagementViewModel viewModel,
    AdminUserEntry user,
  ) {
    return IconButton(
      icon: Icon(
        user.isActive ? Icons.block : Icons.check_circle_outline,
        color: user.isActive ? Colors.red : Colors.green,
        size: 20,
      ),
      tooltip: user.isActive ? 'Desativar' : 'Ativar',
      onPressed: () {
        _confirmAction(
          context,
          title: user.isActive ? 'Desativar usuário' : 'Ativar usuário',
          message: user.isActive
              ? 'Deseja desativar a conta de "${user.name}"?'
              : 'Deseja reativar a conta de "${user.name}"?',
          onConfirm: () =>
              viewModel.toggleUserActive(user.id, !user.isActive),
        );
      },
    );
  }

  void _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'student':
        return 'Aluno';
      case 'teacher':
        return 'Professor';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}
