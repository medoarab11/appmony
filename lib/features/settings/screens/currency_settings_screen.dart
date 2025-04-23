import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/currency/currency_model.dart';
import '../../../services/analytics/analytics_service.dart';
import '../providers/settings_provider.dart';

class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({Key? key}) : super(key: key);

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  late CurrencyModel _selectedCurrency;
  final TextEditingController _searchController = TextEditingController();
  List<CurrencyModel> _filteredCurrencies = [];
  
  @override
  void initState() {
    super.initState();
    
    // Log screen view
    final analyticsService = Provider.of<AnalyticsService>(context, listen: false);
    analyticsService.logScreenView(
      screenName: 'currency_settings',
      screenClass: 'CurrencySettingsScreen',
    );
    
    // Get current currency
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    _selectedCurrency = settingsProvider.currency;
    
    // Initialize filtered currencies
    _filteredCurrencies = CurrencyModel.allCurrencies;
    
    // Add listener to search controller
    _searchController.addListener(_filterCurrencies);
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _filterCurrencies() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencies = CurrencyModel.allCurrencies;
      } else {
        _filteredCurrencies = CurrencyModel.allCurrencies
            .where((currency) =>
                currency.code.toLowerCase().contains(query) ||
                currency.name.toLowerCase().contains(query) ||
                currency.symbol.toLowerCase().contains(query))
            .toList();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search currency',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 16.0,
                ),
              ),
            ),
          ),
          
          // Currency list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCurrencies.length,
              itemBuilder: (context, index) {
                final currency = _filteredCurrencies[index];
                final isSelected = currency.code == _selectedCurrency.code;
                
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      currency.symbol,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(currency.name),
                  subtitle: Text(currency.code),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedCurrency = currency;
                    });
                    
                    settingsProvider.setCurrency(currency);
                    
                    // Show confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Currency changed to ${currency.code}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}