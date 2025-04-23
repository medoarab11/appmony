# AppMony - Personal Finance App

AppMony is a full-featured personal finance mobile app built with Flutter that supports global audiences with multilingual and multicurrency capabilities. The app works offline, includes analytics and charts, and monetizes through ads and subscriptions.

## Features

### Core Free Features
- **Multilingual Support**: Choose from multiple languages during onboarding and change anytime in settings
- **Multicurrency Support**: Select your preferred currency from all ISO 4217 codes
- **Wallet Management**: Create and manage one wallet in the free tier
- **Transaction Tracking**: Add income/expense transactions by category, wallet, and amount
- **Budget Management**: Create up to 2 budgets in the free tier
- **Basic Reports**: View summaries (weekly, monthly, by category)
- **AdMob Integration**: Banner ads in dashboard and transaction views, interstitial ads after certain actions
- **Settings Management**: Customize app appearance, language, currency, and notifications

### Premium Features (via Subscription)
- **Unlimited Wallets and Budgets**: No restrictions on the number of wallets and budgets
- **Recurring Transactions**: Set up recurring budgets and automatic rollover
- **Advanced Reports**: Full financial reports with detailed analytics
- **Data Export**: Export to CSV/Google Sheets
- **Cloud Sync**: Backup/sync using Google account (Firebase)
- **Ad-Free Experience**: Remove all AdMob ads
- **Advanced Visualizations**: Line, bar, pie charts for deeper insights
- **Premium Themes**: Access to exclusive UI themes

## Technical Stack
- **Framework**: Flutter with Dart
- **Architecture**: MVVM (Model-View-ViewModel)
- **Database**: SQLite for offline data storage
- **State Management**: Provider
- **Authentication**: Firebase Auth
- **Cloud Storage**: Firebase Firestore
- **Monetization**: Google AdMob and Google Play Billing
- **Charts**: fl_chart for data visualization
- **Localization**: Flutter Intl package for multilingual support

## Project Structure
```
lib/
├── core/
│   ├── constants/       # App-wide constants and configuration
│   ├── navigation/      # Navigation routes and router
│   ├── theme/           # App themes, colors, and styles
│   └── utils/           # Utility functions and helpers
├── features/
│   ├── auth/            # Authentication (login, signup, onboarding)
│   ├── budgets/         # Budget management
│   ├── dashboard/       # Main dashboard and home screen
│   ├── premium/         # Premium subscription features
│   ├── reports/         # Financial reports and analytics
│   ├── settings/        # App settings (language, currency, theme)
│   └── transactions/    # Transaction management
├── l10n/                # Localization resources
├── models/              # Data models
│   ├── budget/          # Budget-related models
│   ├── category/        # Category-related models
│   ├── currency/        # Currency-related models
│   ├── language/        # Language-related models
│   ├── transaction/     # Transaction-related models
│   ├── user/            # User-related models
│   └── wallet/          # Wallet-related models
├── services/            # Service layer
│   ├── admob/           # AdMob integration
│   ├── analytics/       # Analytics tracking
│   ├── database/        # Local database operations
│   ├── localization/    # Language and localization
│   └── subscription/    # Premium subscription management
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- Firebase project (for premium features)
- AdMob account (for monetization)
- Google Play Developer account (for in-app purchases)

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase (follow instructions in Firebase console)
4. Update AdMob IDs in `app_constants.dart`
5. Configure Google Play Billing (for premium subscription)
6. Run the app with `flutter run`

### Testing
The project includes comprehensive tests for all major features:
- Unit tests for models and services
- Widget tests for UI components
- Integration tests for key user flows

Run tests with:
```bash
flutter test
```

### Building for Production
To build the app for production:

#### Android
```bash
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## License
This project is licensed under the MIT License - see the LICENSE file for details.