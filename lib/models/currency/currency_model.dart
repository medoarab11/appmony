class CurrencyModel {
  final String code;
  final String name;
  final String symbol;
  final int decimalDigits;
  final String decimalSeparator;
  final String thousandSeparator;
  final bool symbolOnLeft;
  final bool spaceBetweenAmountAndSymbol;

  const CurrencyModel({
    required this.code,
    required this.name,
    required this.symbol,
    this.decimalDigits = 2,
    this.decimalSeparator = '.',
    this.thousandSeparator = ',',
    this.symbolOnLeft = true,
    this.spaceBetweenAmountAndSymbol = false,
  });

  String format(double amount, {bool showSymbol = true}) {
    // Format the number with the correct decimal places
    String formattedAmount = amount.toStringAsFixed(decimalDigits);
    
    // Split into whole and decimal parts
    List<String> parts = formattedAmount.split('.');
    String wholePart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Add thousand separators to the whole part
    final RegExp reg = RegExp(r'\d{1,3}(?=(\d{3})+(?!\d))');
    wholePart = wholePart.replaceAllMapped(
      reg,
      (Match match) => '${match.group(0)}$thousandSeparator',
    );
    
    // Combine whole and decimal parts with the decimal separator
    String result = decimalPart.isEmpty
        ? wholePart
        : '$wholePart$decimalSeparator$decimalPart';
    
    // Add the currency symbol if requested
    if (showSymbol) {
      if (symbolOnLeft) {
        result = spaceBetweenAmountAndSymbol ? '$symbol $result' : '$symbol$result';
      } else {
        result = spaceBetweenAmountAndSymbol ? '$result $symbol' : '$result$symbol';
      }
    }
    
    return result;
  }

  // Common currencies
  static const CurrencyModel usd = CurrencyModel(
    code: 'USD',
    name: 'US Dollar',
    symbol: '\$',
    decimalDigits: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
    symbolOnLeft: true,
    spaceBetweenAmountAndSymbol: false,
  );

  static const CurrencyModel eur = CurrencyModel(
    code: 'EUR',
    name: 'Euro',
    symbol: '€',
    decimalDigits: 2,
    decimalSeparator: ',',
    thousandSeparator: '.',
    symbolOnLeft: false,
    spaceBetweenAmountAndSymbol: true,
  );

  static const CurrencyModel gbp = CurrencyModel(
    code: 'GBP',
    name: 'British Pound',
    symbol: '£',
    decimalDigits: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
    symbolOnLeft: true,
    spaceBetweenAmountAndSymbol: false,
  );

  static const CurrencyModel jpy = CurrencyModel(
    code: 'JPY',
    name: 'Japanese Yen',
    symbol: '¥',
    decimalDigits: 0,
    decimalSeparator: '.',
    thousandSeparator: ',',
    symbolOnLeft: true,
    spaceBetweenAmountAndSymbol: false,
  );

  static const CurrencyModel inr = CurrencyModel(
    code: 'INR',
    name: 'Indian Rupee',
    symbol: '₹',
    decimalDigits: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
    symbolOnLeft: true,
    spaceBetweenAmountAndSymbol: false,
  );

  static const CurrencyModel cny = CurrencyModel(
    code: 'CNY',
    name: 'Chinese Yuan',
    symbol: '¥',
    decimalDigits: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
    symbolOnLeft: true,
    spaceBetweenAmountAndSymbol: false,
  );

  static const CurrencyModel sar = CurrencyModel(
    code: 'SAR',
    name: 'Saudi Riyal',
    symbol: 'ر.س',
    decimalDigits: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
    symbolOnLeft: true,
    spaceBetweenAmountAndSymbol: true,
  );

  static const CurrencyModel aed = CurrencyModel(
    code: 'AED',
    name: 'UAE Dirham',
    symbol: 'د.إ',
    decimalDigits: 2,
    decimalSeparator: '.',
    thousandSeparator: ',',
    symbolOnLeft: true,
    spaceBetweenAmountAndSymbol: true,
  );

  static const CurrencyModel rub = CurrencyModel(
    code: 'RUB',
    name: 'Russian Ruble',
    symbol: '₽',
    decimalDigits: 2,
    decimalSeparator: ',',
    thousandSeparator: ' ',
    symbolOnLeft: false,
    spaceBetweenAmountAndSymbol: true,
  );

  static const CurrencyModel brl = CurrencyModel(
    code: 'BRL',
    name: 'Brazilian Real',
    symbol: 'R\$',
    decimalDigits: 2,
    decimalSeparator: ',',
    thousandSeparator: '.',
    symbolOnLeft: true,
    spaceBetweenAmountAndSymbol: true,
  );

  // List of all supported currencies
  static const List<CurrencyModel> allCurrencies = [
    usd, eur, gbp, jpy, inr, cny, sar, aed, rub, brl,
    // Add more currencies as needed
  ];

  // Find a currency by code
  static CurrencyModel? findByCode(String code) {
    try {
      return allCurrencies.firstWhere(
        (currency) => currency.code == code,
      );
    } catch (e) {
      return null;
    }
  }
}