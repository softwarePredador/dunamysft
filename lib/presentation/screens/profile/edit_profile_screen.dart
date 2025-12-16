import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _roomController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;

      if (user != null) {
        // Carregar dados do Firestore
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (doc.exists) {
          _userData = doc.data();
          _nameController.text = _userData?['display_name'] ?? user.displayName ?? '';
          _phoneController.text = _userData?['phone_number'] ?? user.phoneNumber ?? '';
          _roomController.text = _userData?['room'] ?? '';
        } else {
          // Usar dados do Firebase Auth
          _nameController.text = user.displayName ?? '';
          _phoneController.text = user.phoneNumber ?? '';
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar dados do usuário: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;

      if (user != null) {
        // Atualizar no Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'display_name': _nameController.text.trim(),
          'phone_number': _phoneController.text.trim(),
          'room': _roomController.text.trim(),
        }, SetOptions(merge: true));

        // Atualizar displayName no Firebase Auth
        if (_nameController.text.trim() != user.displayName) {
          await user.updateDisplayName(_nameController.text.trim());
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: AppTheme.success,
            ),
          );
          context.pop();
        }
      }
    } catch (e) {
      debugPrint('Erro ao salvar perfil: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_circle_left_sharp, color: AppTheme.amarelo, size: 35.0),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          'Editar Perfil',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryText,
          ),
        ),
        centerTitle: true,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: Text(
                'Salvar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.amarelo,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Foto de perfil
                    Center(
                      child: Stack(
                        children: [
                          if (user?.photoURL != null)
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: NetworkImage(user!.photoURL!),
                            )
                          else
                            const CircleAvatar(
                              radius: 60,
                              backgroundColor: AppTheme.primary,
                              child: Icon(Icons.person, size: 60, color: Colors.white),
                            ),
                          // Botão de editar foto (futuro)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.amarelo,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.email ?? '',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nome
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nome completo',
                      hint: 'Digite seu nome',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, digite seu nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Telefone
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Telefone',
                      hint: '(00) 00000-0000',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Quarto
                    _buildTextField(
                      controller: _roomController,
                      label: 'Número do Quarto',
                      hint: 'Ex: 101',
                      icon: Icons.hotel_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),

                    // Botão Salvar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.amarelo,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Salvar Alterações',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Opção de deletar conta
                    TextButton.icon(
                      onPressed: () => _showDeleteAccountDialog(context),
                      icon: const Icon(Icons.delete_outline, color: AppTheme.error),
                      label: Text(
                        'Excluir minha conta',
                        style: GoogleFonts.inter(
                          color: AppTheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppTheme.primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.secondaryText),
            filled: true,
            fillColor: AppTheme.secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.bordaCinza),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.bordaCinza),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.amarelo, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Esta ação não pode ser desfeita e todos os seus dados serão perdidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount();
            },
            child: const Text('Excluir', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();
      final user = authService.currentUser;

      if (user != null) {
        // Deletar documento do Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

        // Deletar conta do Firebase Auth
        await user.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Conta excluída com sucesso'),
              backgroundColor: AppTheme.success,
            ),
          );
          context.go('/login');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor, faça login novamente para excluir sua conta'),
              backgroundColor: AppTheme.error,
            ),
          );
          // Fazer logout e pedir para logar novamente
          await context.read<AuthService>().signOut();
          context.go('/login');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir conta: ${e.message}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao excluir conta: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir conta: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }

    setState(() => _isLoading = false);
  }
}
