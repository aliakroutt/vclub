import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CurrencyExchangeService {
  CurrencyExchangeService._();

  // open.er-api.com — free, no API key required, broader currency
  // coverage than Frankfurter (includes MAD, TND, DZD).
  static const String _baseUrl = 'https://open.er-api.com/v6/latest/EUR';

  static Map<String, double>? _cachedRates;
  static DateTime? _cachedAt;
  static const Duration _cacheDuration = Duration(hours: 6);

  static Future<Map<String, double>> getRates({
    List<String> symbols = const ['USD', 'TND', 'MAD', 'DZD'],
  }) async {
    final now = DateTime.now();

    if (_cachedRates != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheDuration) {
      return _cachedRates!;
    }

    try {
      final uri = Uri.parse(_baseUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return _cachedRates ?? {};
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['result'] != 'success') {
        return _cachedRates ?? {};
      }

      final allRates = (data['rates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );

      // Only keep the symbols we actually need, plus EUR itself.
      final filtered = <String, double>{'EUR': 1.0};
      for (final symbol in symbols) {
        if (allRates.containsKey(symbol)) {
          filtered[symbol] = allRates[symbol]!;
        } else {
          debugPrint('⚠️ CurrencyExchangeService: no rate found for $symbol');
        }
      }

      _cachedRates = filtered;
      _cachedAt = now;
      return filtered;
    } catch (e) {
      debugPrint('⚠️ CurrencyExchangeService: fetch failed: $e');
      return _cachedRates ?? {};
    }
  }

  static Future<double?> convertFromEur(double amountInEur, String targetCurrency) async {
    if (targetCurrency.toUpperCase() == 'EUR') return amountInEur;

    final rates = await getRates();
    final rate = rates[targetCurrency.toUpperCase()];
    if (rate == null) return null;

    return amountInEur * rate;
  }
}