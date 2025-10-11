import 'package:flutter/material.dart';
import '../theme/app_color.dart';

@Preview(name: 'Card Perfil do Usuário')
Widget userProfileCardPreview() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: UserProfileCard(
        userName: "João Silva",
        userEmail: "joao.silva@gmail.com",
        onNameUpdate: (newName) async {
          await Future.delayed(const Duration(seconds: 1));
          return true;
        },
        onShowFeedback: (message, {isError = false}) {
          debugPrint('Feedback: $message (Error: $isError)');
        },
      ),
    ),
  );
}

class Preview {
  const Preview({required String name});
}

class UserProfileCard extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? profileImageUrl;
  final Future<bool> Function(String newName)? onNameUpdate;
  final void Function(String message, {bool isError})? onShowFeedback;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color backgroundColor;
  final double borderRadius;

  const UserProfileCard({
    super.key,
    required this.userName,
    required this.userEmail,
    this.profileImageUrl,
    this.onNameUpdate,
    this.onShowFeedback,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.backgroundColor = AppColors.white,
    this.borderRadius = 12.0,
  });

  @override
  State<UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
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
      margin: widget.margin,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildUserAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserNameField(),
                const SizedBox(height: 4),
                _buildUserEmail(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.green,
          width: 2,
        ),
        color: AppColors.green.withValues(alpha: 0.1),
      ),
      child: widget.profileImageUrl != null
          ? ClipOval(
              child: Image.network(
                widget.profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 30,
      color: AppColors.green,
    );
  }

  Widget _buildUserNameField() {
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.green, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                enabled: !_isLoading,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _isLoading ? null : _saveName,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                        ),
                      )
                    : const Icon(
                        Icons.check,
                        color: AppColors.green,
                        size: 20,
                      ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                onPressed: _isLoading ? null : _cancelEditing,
                icon: const Icon(
                  Icons.close,
                  color: AppColors.webNeutral500,
                  size: 20,
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: Text(
              _currentName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: _startEditing,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.edit,
                color: AppColors.green,
                size: 16,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildUserEmail() {
    return Text(
      widget.userEmail,
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.webNeutral500,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}