import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  late SharedPreferences _prefs;
  int _interstitialAdCounter = 0;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await MobileAds.instance.initialize();
  }
  
  // Check if user is premium
  bool get isPremium => _prefs.getBool(AppConstants.prefIsPremium) ?? false;
  
  // Banner Ad
  String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.bannerAdUnitId;
    } else if (Platform.isIOS) {
      return AppConstants.bannerAdUnitId; // Replace with iOS-specific ID in production
    } else {
      return AppConstants.bannerAdUnitId;
    }
  }
  
  // Create a banner ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
        onAdOpened: (ad) {
          print('Banner ad opened: ${ad.adUnitId}');
        },
        onAdClosed: (ad) {
          print('Banner ad closed: ${ad.adUnitId}');
        },
      ),
    );
  }
  
  // Interstitial Ad
  String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.interstitialAdUnitId;
    } else if (Platform.isIOS) {
      return AppConstants.interstitialAdUnitId; // Replace with iOS-specific ID in production
    } else {
      return AppConstants.interstitialAdUnitId;
    }
  }
  
  // Load interstitial ad
  Future<void> loadInterstitialAd() async {
    if (isPremium) return;
    
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Interstitial ad failed to load: ${error.message}');
        },
      ),
    );
  }
  
  // Show interstitial ad
  Future<void> showInterstitialAd() async {
    if (isPremium) return;
    
    _interstitialAdCounter++;
    
    if (_interstitialAdCounter >= AppConstants.interstitialAdFrequency) {
      if (_interstitialAd != null) {
        await _interstitialAd!.show();
        _interstitialAdCounter = 0;
      } else {
        loadInterstitialAd();
      }
    }
  }
  
  // Rewarded Ad
  String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.rewardedAdUnitId;
    } else if (Platform.isIOS) {
      return AppConstants.rewardedAdUnitId; // Replace with iOS-specific ID in production
    } else {
      return AppConstants.rewardedAdUnitId;
    }
  }
  
  // Load rewarded ad
  Future<void> loadRewardedAd() async {
    if (isPremium) return;
    
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          print('Rewarded ad failed to load: ${error.message}');
        },
      ),
    );
  }
  
  // Show rewarded ad
  Future<bool> showRewardedAd() async {
    if (isPremium) return true;
    
    if (_rewardedAd != null) {
      bool rewardEarned = false;
      
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
        },
      );
      
      return rewardEarned;
    } else {
      loadRewardedAd();
      return false;
    }
  }
  
  // Dispose ads
  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}