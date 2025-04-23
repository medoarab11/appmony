import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/language/language_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../../../services/localization/localization_service.dart';
import '../providers/settings_provider.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  late LanguageModel _selectedLanguage;
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'language_settings',
      screenClass: 'LanguageSettingsScreen',
    );
    
    // Get current language
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _selectedLanguage = settingsProvider.language;
  }
  
  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final languages = localizationService.supportedLanguages;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language'),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final language = languages[index];
          final isSelected = language.code == _selectedLanguage.code;
          
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(language.flagAsset),
            ),
            title: Text(language.name),
            subtitle: Text(language.nativeName),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () {
              setState(() {
                _selectedLanguage = language;
              });
              
              settingsProvider.setLanguage(language);
              
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Language changed to ${language.name}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }
}