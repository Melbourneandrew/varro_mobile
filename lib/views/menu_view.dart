import 'package:flutter/material.dart';
import 'package:scream_mobile/modals/openai_model_modal.dart';
import 'package:scream_mobile/views/profile_view.dart';
import 'package:scream_mobile/modals/openai_key_modal.dart';

import 'message_history_view.dart';

class MenuView extends StatelessWidget {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Menu',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          _buildMenuItem(
            context,
            icon: Icons.key,
            title: 'OpenAI API Key',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, _, __) => Material(
                    type: MaterialType.transparency,
                    child: Center(
                      child: OpenAIKeyModal(
                        setModalState: (_) => Navigator.of(context).pop(),
                        closable: true,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.memory,
            title: 'Select Model',
            onTap: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  pageBuilder: (context, _, __) => Material(
                    type: MaterialType.transparency,
                    child: Center(
                      child: OpenAIModelModal(
                        setModalState: (_) => Navigator.of(context).pop(),
                        closable: true,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: 'Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileView()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.question_answer_sharp,
            title: 'Chat History',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessageHistoryView()),
              );
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'About',
            onTap: () {
              // TODO: Implement browser navigation to about page
            },
          ),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: 'Privacy Policy',
            onTap: () {
              // TODO: Implement browser navigation to privacy policy page
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}
