import 'package:flutter/material.dart';
import '../theme/app_color.dart';

class UserDataCard extends StatefulWidget {
  final String userName;
  final String userEmail;
  final Future<bool> Function(String newName)? onNameUpdate;
  final void Function(String message, {bool isError})? onShowFeedback;

  const UserDataCard({
    super.key,
    required this.userName,
    required this.userEmail,
    this.onNameUpdate,
    this.onShowFeedback,
  });

  @override
  State<UserDataCard> createState() => _UserDataCardState();
}

class _UserDataCardState extends State<UserDataCard> {
  late String _currentName;
  bool _isEditing = false;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentName = widget.userName;
    _nameController.text = _currentName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
      _nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _nameController.text.length,
      );
    });
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
      _nameController.text = _currentName;
    });
    _nameFocusNode.unfocus();
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();

    if (newName.isEmpty) {
      widget.onShowFeedback?.call(
        'Nome não pode estar vazio',
        isError: true,
      );
      return;
    }

    if (newName == _currentName) {
      _cancelEditing();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.onNameUpdate?.call(newName) ?? true;

      if (success) {
        setState(() {
          _currentName = newName;
          _isEditing = false;
        });

        widget.onShowFeedback?.call(
          'Nome atualizado com sucesso!',
          isError: false,
        );
      } else {
        _nameController.text = _currentName;
        widget.onShowFeedback?.call(
          'Erro ao atualizar nome. Tente novamente.',
          isError: true,
        );
      }
    } catch (e) {
      _nameController.text = _currentName;
      widget.onShowFeedback?.call(
        'Erro ao atualizar nome. Tente novamente.',
        isError: true,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      _nameFocusNode.unfocus();
    }
  }

  void _handleKeyPress(KeyEvent event) {
    if (event.logicalKey.keyLabel == 'Enter') {
      _saveName();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar/Ícone de perfil
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: AppColors.white,
            ),
          ),

          const SizedBox(width: 16),

          // Nome, email e botão editar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome com ícone de editar
                _buildNameSection(),
                const SizedBox(height: 8),

                // Email
                Text(
                  widget.userEmail,
                  style: TextStyle(
                    color: AppColors.secondaryDark,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameSection() {
    if (_isEditing) {
      return Row(
        children: [
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: _handleKeyPress,
              child: TextField(
                controller: _nameController,
                focusNode: _nameFocusNode,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                enabled: !_isLoading,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                  ),
                )
              : InkWell(
                  onTap: _saveName,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
          const SizedBox(width: 4),
          InkWell(
            onTap: _cancelEditing,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.secondaryDark,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 18,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Text(
              _currentName,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          InkWell(
            onTap: _startEditing,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit,
                size: 18,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      );
    }
  }
}

