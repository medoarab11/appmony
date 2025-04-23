class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flagAsset;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagAsset,
  });
  
  // Common languages
  static List<LanguageModel> get supportedLanguages => [
    const LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagAsset: 'assets/flags/us.png',
    ),
    const LanguageModel(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Espanol',
      flagAsset: 'assets/flags/es.png',
    ),
    const LanguageModel(
      code: 'fr',
      name: 'French',
      nativeName: 'Francais',
      flagAsset: 'assets/flags/fr.png',
    ),
    const LanguageModel(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      flagAsset: 'assets/flags/de.png',
    ),
    const LanguageModel(
      code: 'it',
      name: 'Italian',
      nativeName: 'Italiano',
      flagAsset: 'assets/flags/it.png',
    ),
    const LanguageModel(
      code: 'pt',
      name: 'Portuguese',
      nativeName: 'Portugues',
      flagAsset: 'assets/flags/pt.png',
    ),
    const LanguageModel(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Russkiy',
      flagAsset: 'assets/flags/ru.png',
    ),
    const LanguageModel(
      code: 'zh',
      name: 'Chinese',
      nativeName: 'Zhongwen',
      flagAsset: 'assets/flags/cn.png',
    ),
    const LanguageModel(
      code: 'ja',
      name: 'Japanese',
      nativeName: 'Nihongo',
      flagAsset: 'assets/flags/jp.png',
    ),
    const LanguageModel(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'Arabiya',
      flagAsset: 'assets/flags/sa.png',
    ),
    const LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'Hindi',
      flagAsset: 'assets/flags/in.png',
    ),
    const LanguageModel(
      code: 'tr',
      name: 'Turkish',
      nativeName: 'Turkce',
      flagAsset: 'assets/flags/tr.png',
    ),
  ];
  
  // Find language by code
  static LanguageModel? findByCode(String code) {
    try {
      return supportedLanguages.firstWhere((lang) => lang.code == code);
    } catch (e) {
      return null;
    }
  }
}
