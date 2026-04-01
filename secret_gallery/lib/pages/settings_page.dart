import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:secret_gallery/services/auth_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          const _SectionHeader('보안'),
          ListTile(
            leading: const Icon(Icons.lock_reset, color: Colors.white70),
            title: const Text('앱 비밀번호 변경', style: TextStyle(color: Colors.white)),
            subtitle: const Text('현재 비밀번호를 확인 후 새 번호로 변경합니다.',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white38),
            onTap: () => _showChangePasswordDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    final auth = AuthService();
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String errorMsg = '';
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[850],
          title: const Text('비밀번호 변경', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PasswordField(
                controller: currentCtrl,
                label: '현재 비밀번호',
              ),
              const SizedBox(height: 12),
              _PasswordField(
                controller: newCtrl,
                label: '새 비밀번호',
              ),
              const SizedBox(height: 12),
              _PasswordField(
                controller: confirmCtrl,
                label: '새 비밀번호 확인',
              ),
              if (errorMsg.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(errorMsg,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final current = currentCtrl.text.trim();
                final newPw = newCtrl.text.trim();
                final confirm = confirmCtrl.text.trim();
                final ok = await auth.checkAppPassword(current);
                if (!ok) {
                  setDialogState(() => errorMsg = '현재 비밀번호가 틀렸습니다.');
                  return;
                }
                if (newPw.isEmpty) {
                  setDialogState(() => errorMsg = '새 비밀번호를 입력하세요.');
                  return;
                }
                if (newPw != confirm) {
                  setDialogState(() => errorMsg = '새 비밀번호가 일치하지 않습니다.');
                  return;
                }
                await auth.setAppPassword(newPw);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('비밀번호가 변경되었습니다.')),
                  );
                }
              },
              child: const Text('변경'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.blue[300],
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  const _PasswordField({required this.controller, required this.label});
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}


class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[900],
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.white38),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
    );
  }
}