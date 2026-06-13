// lib/screens/profile/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name, _email, _phone;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name = TextEditingController(text: user?.name ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Edit Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: Text(
              _isSaving ? 'Saving...' : 'Save',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Avatar
            Center(
              child: Stack(children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      auth.user?.profileImageUrl ?? 'https://i.pravatar.cc/200?img=11',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.primary,
                        child: const Icon(Icons.person, size: 46, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 15, color: Colors.black87),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(children: [
                _FieldCard(children: [
                  _Field(
                    ctrl: _name,
                    label: 'Full Name',
                    icon: Icons.person_rounded,
                    validator: (v) => v!.isEmpty ? 'Name required' : null,
                  ),
                  const Divider(height: 1),
                  _Field(
                    ctrl: _phone,
                    label: 'Phone',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.length < 10 ? 'Valid phone required' : null,
                  ),
                  const Divider(height: 1),
                  _Field(
                    ctrl: _email,
                    label: 'Email',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => !v!.contains('@') ? 'Valid email required' : null,
                  ),
                ]),
                const SizedBox(height: 16),

                // Points & wallet (read-only)
                _FieldCard(children: [
                  _InfoTile(
                    icon: '💰',
                    label: 'Wallet Balance',
                    value: '₹${auth.user?.walletBalance.toStringAsFixed(0) ?? '0'}',
                    onTap: () => context.push('/wallet'),
                  ),
                  const Divider(height: 1),
                  _InfoTile(
                    icon: '🌟',
                    label: 'Reward Points',
                    value: '${auth.user?.points ?? 0} pts',
                    onTap: () => context.push('/points'),
                  ),
                ]),
                const SizedBox(height: 16),

                // Default address
                _FieldCard(children: [
                  _InfoTile(
                    icon: '📍',
                    label: 'Default Address',
                    value: auth.user?.defaultAddress ?? 'Not set',
                    onTap: () => context.push('/addresses'),
                    isMultiLine: true,
                  ),
                ]),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.black),
                          )
                        : const Text('Save Changes',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _FieldCard extends StatelessWidget {
  final List<Widget> children;
  const _FieldCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
          ],
        ),
        child: Column(children: children),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}

class _InfoTile extends StatelessWidget {
  final String icon, label, value;
  final VoidCallback onTap;
  final bool isMultiLine;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: onTap,
        leading: Text(icon, style: const TextStyle(fontSize: 22)),
        title: Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
        subtitle: Text(
          value,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary),
          maxLines: isMultiLine ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppColors.textHint),
      );
}