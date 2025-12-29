import 'package:flutter/material.dart';
import 'package:store_buy/providers/language_provider.dart';
import 'package:store_buy/providers/offline_provider.dart';
import 'package:store_buy/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Écran des paramètres pour les clients
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final offlineProvider = Provider.of<OfflineProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    String selectedLanguage = 'fr';
   
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: const Color(0xFF3B82F6),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language section

          Card(
             child: ExpansionTile(
              leading: const Icon(Icons.language),
              title: const Text('Langue'),
              subtitle: Text(languageProvider.locale.languageCode == 'fr' ? 'Français' : 'English'),

                  children: [
                    RadioListTile<Locale>(
                      title: const Text('Français'),
                      value: const Locale('fr'),
                      groupValue: languageProvider.locale,
                      onChanged: (Locale? value){
                        if(value != null){
                          languageProvider.setLanguage(value);
                        }
                      },
                    ),
                    RadioListTile<Locale>(
                      title: const Text('English'),
                      value: const Locale('en'),
                      groupValue: languageProvider.locale,
                      onChanged: (Locale? value){
                        if(value != null){
                          languageProvider.setLanguage(value);
                        }
                      },
                    ),
                  ],
                )

            ),

          const SizedBox(height: 10),
          // Offline mode section
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_off),
              title: const Text('Mode hors connexion'),
              subtitle: Text(offlineProvider.isOffline ? 'Hors ligne' : 'En ligne'),
              trailing: Switch(
                value: !offlineProvider.isOnline,
                onChanged: (value) {
                  // Toggle offline mode
                  if (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mode hors connexion activé'),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Sync section
          if (offlineProvider.isOffline)
            Card(
              child: ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Synchroniser les données'),
                subtitle: const Text('Synchroniser les données locales avec le serveur'),
                trailing: offlineProvider.isLoading
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.chevron_right),
                onTap: offlineProvider.isLoading
                    ? null
                    : () {
                        offlineProvider.syncData();
                      },
              ),
            ),
          const SizedBox(height: 10),
          // Account section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profil'),
                  subtitle: Text(authProvider.currentUser?.name ?? 'Utilisateur'),
                  trailing: const Icon(Icons.chevron_right),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Déconnexion'),
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


