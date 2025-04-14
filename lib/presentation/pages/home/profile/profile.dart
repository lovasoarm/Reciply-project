import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reciply/core/constants/app_colors.dart';
import 'package:reciply/core/constants/app_text_styles.dart';
import '../../../../core/services/firebase/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _appVersion = 'Chargement...';
  String _appBuildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
      _appBuildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<Services>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: AppTextStyle.headline),
        centerTitle: true,
      ),
      body:
          currentUser == null
              ? const Center(child: Text('Utilisateur non connecté'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withAlpha(40),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<DocumentSnapshot>(
                      future:
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text(
                            currentUser.email ?? 'Email non disponible',
                            style: AppTextStyle.headline,
                          );
                        }
                        final userData =
                            snapshot.data?.data() as Map<String, dynamic>?;
                        final username = userData?['username'] ?? 'Utilisateur';

                        return Column(
                          children: [
                            Text(
                              username,
                              style: AppTextStyle.headline.copyWith(
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentUser.email ?? 'Email non disponible',
                              style: AppTextStyle.body.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    _buildProfileOption(
                      context,
                      icon: Icons.edit,
                      title: 'Modifier le profil',
                      onTap: () => _showEditProfileDialog(context, authService),
                    ),
                   
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Déconnexion'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () => _confirmLogout(context, authService),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                'Version $_appVersion (build $_appBuildNumber)',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Version copiée')),
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            'Version $_appVersion',
                            style: AppTextStyle.body.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          if (_appBuildNumber.isNotEmpty)
                            Text(
                              'Build $_appBuildNumber',
                              style: AppTextStyle.caption.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyle.body),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    Services authService,
  ) async {
    final currentUser = authService.currentUser;
    if (currentUser == null) return;

    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
    final userData = userDoc.data() ?? {};
    final usernameController = TextEditingController(
      text: userData['username'] ?? '',
    );

    await showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Modifier le profil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (usernameController.text.isNotEmpty) {
                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .update({'username': usernameController.text});
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil mis à jour')),
                      );
                      setState(() {}); // Rafraîchir l'interface
                    } catch (e) {
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur: ${e.toString()}')),
                      );
                    }
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    Services authService,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await authService.signOut();
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }
}
