import 'package:flutter/material.dart';
import '../storage/profile_storage.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  UserProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ProfileStorage.getProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _profile = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _resetProfile() async {
    await ProfileStorage.clearProfile();
    await _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection('Name', _profile?.name ?? ''),
            const SizedBox(height: 16),
            _buildProfileSection('Interests', _profile?.interests ?? ''),
            const SizedBox(height: 16),
            _buildProfileSection('Goals', _profile?.goals ?? ''),
            const SizedBox(height: 16),
            _buildProfileSection('Events', _profile?.events ?? ''),
            const SizedBox(height: 16),
            Text(
              'Last Updated: ${_profile?.lastUpdate.toLocal() ?? 'Never'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: _resetProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                child: const Text('Reset Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          content.isEmpty ? 'Not yet generated' : content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
