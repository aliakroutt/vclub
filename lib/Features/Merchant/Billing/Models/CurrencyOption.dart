// lib/Features/Merchant/Billing/Models/CurrencyOption.dart

/// Static list of supported currencies, each mapped to the country code
/// the backend actually expects in the update payload (the API takes
/// `countryCode`, and derives `currencyCode` server-side from it).
enum CurrencyOption {
  eur,
  tnd,
  mad,
  dzd,
  usd,
}

extension CurrencyOptionX on CurrencyOption {
  /// The country code sent to PATCH /companies/my-company.
  String get countryCode {
    switch (this) {
      case CurrencyOption.eur:
        return "FR";
      case CurrencyOption.tnd:
        return "TN";
      case CurrencyOption.mad:
        return "MA";
      case CurrencyOption.dzd:
        return "DZ";
      case CurrencyOption.usd:
        return "US";
    }
  }

  /// The currency code as returned by the API (for matching current value).
  String get currencyCode {
    switch (this) {
      case CurrencyOption.eur:
        return "EUR";
      case CurrencyOption.tnd:
        return "TND";
      case CurrencyOption.mad:
        return "MAD";
      case CurrencyOption.dzd:
        return "DZD";
      case CurrencyOption.usd:
        return "USD";
    }
  }

  String get symbol {
    switch (this) {
      case CurrencyOption.eur:
        return "€";
      case CurrencyOption.tnd:
        return "DT";
      case CurrencyOption.mad:
        return "DH";
      case CurrencyOption.dzd:
        return "DA";
      case CurrencyOption.usd:
        return "\$";
    }
  }

  String get flagEmoji {
    switch (this) {
      case CurrencyOption.eur:
        return "🇪🇺";
      case CurrencyOption.tnd:
        return "🇹🇳";
      case CurrencyOption.mad:
        return "🇲🇦";
      case CurrencyOption.dzd:
        return "🇩🇿";
      case CurrencyOption.usd:
        return "🇺🇸";
    }
  }

  /// Localized display name — translation keys, one per currency.
  String get labelKey {
    switch (this) {
      case CurrencyOption.eur:
        return "currency_eur";
      case CurrencyOption.tnd:
        return "currency_tnd";
      case CurrencyOption.mad:
        return "currency_mad";
      case CurrencyOption.dzd:
        return "currency_dzd";
      case CurrencyOption.usd:
        return "currency_usd";
    }
  }

  static CurrencyOption? fromCurrencyCode(String? code) {
    if (code == null) return null;
    try {
      return CurrencyOption.values.firstWhere(
        (c) => c.currencyCode.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }
}