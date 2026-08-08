class AddressModel {
  final String? street;
  final String? houseNumber;
  final String? postalCode;
  final String? city;
  final String? country;

  AddressModel({
    this.street,
    this.houseNumber,
    this.postalCode,
    this.city,
    this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street']?.toString(),
      houseNumber: json['houseNumber']?.toString(),
      postalCode: json['postalCode']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'houseNumber': houseNumber,
      'postalCode': postalCode,
      'city': city,
      'country': country,
    };
  }
}

class EntitlementsModel {
  final int? maxClients;
  final int? maxLoyaltyPrograms;
  final int? maxAgents;
  final bool loyaltyProgram;
  final bool qrCode;
  final bool googleReviews;
  final bool basicAnalytics;
  final bool nfc;
  final bool wheelOfFortune;
  final bool marketing;
  final bool pushNotifications;
  final bool campaigns;
  final bool multiEstablishment;
  final bool advancedCrm;
  final bool whiteLabel;
  final bool automations;
  final bool apiAccess;
  final bool advancedEmployees;

  EntitlementsModel({
    this.maxClients,
    this.maxLoyaltyPrograms,
    this.maxAgents,
    this.loyaltyProgram = false,
    this.qrCode = false,
    this.googleReviews = false,
    this.basicAnalytics = false,
    this.nfc = false,
    this.wheelOfFortune = false,
    this.marketing = false,
    this.pushNotifications = false,
    this.campaigns = false,
    this.multiEstablishment = false,
    this.advancedCrm = false,
    this.whiteLabel = false,
    this.automations = false,
    this.apiAccess = false,
    this.advancedEmployees = false,
  });

  /// `null` in the API means "unlimited" for these three fields.
  bool get hasUnlimitedClients => maxClients == null;
  bool get hasUnlimitedPrograms => maxLoyaltyPrograms == null;
  bool get hasUnlimitedAgents => maxAgents == null;

  factory EntitlementsModel.fromJson(Map<String, dynamic> json) {
    return EntitlementsModel(
      maxClients: (json['maxClients'] as num?)?.toInt(),
      maxLoyaltyPrograms: (json['maxLoyaltyPrograms'] as num?)?.toInt(),
      maxAgents: (json['maxAgents'] as num?)?.toInt(),
      loyaltyProgram: json['loyaltyProgram'] as bool? ?? false,
      qrCode: json['qrCode'] as bool? ?? false,
      googleReviews: json['googleReviews'] as bool? ?? false,
      basicAnalytics: json['basicAnalytics'] as bool? ?? false,
      nfc: json['nfc'] as bool? ?? false,
      wheelOfFortune: json['wheelOfFortune'] as bool? ?? false,
      marketing: json['marketing'] as bool? ?? false,
      pushNotifications: json['pushNotifications'] as bool? ?? false,
      campaigns: json['campaigns'] as bool? ?? false,
      multiEstablishment: json['multiEstablishment'] as bool? ?? false,
      advancedCrm: json['advancedCrm'] as bool? ?? false,
      whiteLabel: json['whiteLabel'] as bool? ?? false,
      automations: json['automations'] as bool? ?? false,
      apiAccess: json['apiAccess'] as bool? ?? false,
      advancedEmployees: json['advancedEmployees'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxClients': maxClients,
      'maxLoyaltyPrograms': maxLoyaltyPrograms,
      'maxAgents': maxAgents,
      'loyaltyProgram': loyaltyProgram,
      'qrCode': qrCode,
      'googleReviews': googleReviews,
      'basicAnalytics': basicAnalytics,
      'nfc': nfc,
      'wheelOfFortune': wheelOfFortune,
      'marketing': marketing,
      'pushNotifications': pushNotifications,
      'campaigns': campaigns,
      'multiEstablishment': multiEstablishment,
      'advancedCrm': advancedCrm,
      'whiteLabel': whiteLabel,
      'automations': automations,
      'apiAccess': apiAccess,
      'advancedEmployees': advancedEmployees,
    };
  }
}

class CompanyModel {
  final String id;
  final String name;
  final String? tradeName;
  final String? siret;
  final String? uid;
  final String? slug;
  final String? qrUrl;
  final String? industry;
  final String? countryCode;
  final String? currencyCode;
  final String? timezone;
  final String? contactEmail;
  final String? contactPhone;
  final AddressModel? address;
  final String? status;
  final String? subscriptionStatus;
  final String? stripePlan;
  final bool smsAddon;
  final DateTime? subscriptionEndsAt;
  final bool cancelAtPeriodEnd;
  final bool hasSubscription;
  final bool manualSubscription;
  final DateTime? manualActivatedAt;
  final bool hasBillingAccount;
  final String? logo;
  final String? facebook;
  final String? instagram;
  final String? linkedin;
  final String? twitter;
  final String? youtube;
  final String? tiktok;
  final String? googleReviewLink;

  CompanyModel({
    required this.id,
    required this.name,
    this.tradeName,
    this.siret,
    this.uid,
    this.slug,
    this.qrUrl,
    this.industry,
    this.countryCode,
    this.currencyCode,
    this.timezone,
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.status,
    this.subscriptionStatus,
    this.stripePlan,
    this.smsAddon = false,
    this.subscriptionEndsAt,
    this.cancelAtPeriodEnd = false,
    this.hasSubscription = false,
    this.manualSubscription = false,
    this.manualActivatedAt,
    this.hasBillingAccount = false,
    this.logo,
    this.facebook,
    this.instagram,
    this.linkedin,
    this.twitter,
    this.youtube,
    this.tiktok,
    this.googleReviewLink,
  });

  bool get isPremiumPlan => (stripePlan ?? '').toUpperCase() == 'PREMIUM';
  bool get isSubscriptionActive => (subscriptionStatus ?? '').toLowerCase() == 'active';

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tradeName: json['tradeName']?.toString(),
      siret: json['siret']?.toString(),
      uid: json['uid']?.toString(),
      slug: json['slug']?.toString(),
      qrUrl: json['qrUrl']?.toString(),
      industry: json['industry']?.toString(),
      countryCode: json['countryCode']?.toString(),
      currencyCode: json['currencyCode']?.toString(),
      timezone: json['timezone']?.toString(),
      contactEmail: json['contactEmail']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      status: json['status']?.toString(),
      subscriptionStatus: json['subscriptionStatus']?.toString(),
      stripePlan: json['stripePlan']?.toString(),
      smsAddon: json['smsAddon'] as bool? ?? false,
      subscriptionEndsAt: json['subscriptionEndsAt'] != null
          ? DateTime.tryParse(json['subscriptionEndsAt'].toString())
          : null,
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool? ?? false,
      hasSubscription: json['hasSubscription'] as bool? ?? false,
      manualSubscription: json['manualSubscription'] as bool? ?? false,
      manualActivatedAt: json['manualActivatedAt'] != null
          ? DateTime.tryParse(json['manualActivatedAt'].toString())
          : null,
      hasBillingAccount: json['hasBillingAccount'] as bool? ?? false,
      logo: json['logo']?.toString(),
      facebook: json['facebook']?.toString(),
      instagram: json['instagram']?.toString(),
      linkedin: json['linkedin']?.toString(),
      twitter: json['twitter']?.toString(),
      youtube: json['youtube']?.toString(),
      tiktok: json['tiktok']?.toString(),
      googleReviewLink: json['googleReviewLink']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tradeName': tradeName,
      'siret': siret,
      'uid': uid,
      'slug': slug,
      'qrUrl': qrUrl,
      'industry': industry,
      'countryCode': countryCode,
      'currencyCode': currencyCode,
      'timezone': timezone,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'address': address?.toJson(),
      'status': status,
      'subscriptionStatus': subscriptionStatus,
      'stripePlan': stripePlan,
      'smsAddon': smsAddon,
      'subscriptionEndsAt': subscriptionEndsAt?.toIso8601String(),
      'cancelAtPeriodEnd': cancelAtPeriodEnd,
      'hasSubscription': hasSubscription,
      'manualSubscription': manualSubscription,
      'manualActivatedAt': manualActivatedAt?.toIso8601String(),
      'hasBillingAccount': hasBillingAccount,
      'logo': logo,
      'facebook': facebook,
      'instagram': instagram,
      'linkedin': linkedin,
      'twitter': twitter,
      'youtube': youtube,
      'tiktok': tiktok,
      'googleReviewLink': googleReviewLink,
    };
  }
}

class MerchantProfileModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? language;
  final String role;
  final bool isActive;
  final bool hasPaid;
  final bool billingLocked;
  final EntitlementsModel? entitlements;
  final CompanyModel? company;

  MerchantProfileModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.language,
    required this.role,
    this.isActive = true,
    this.hasPaid = false,
    this.billingLocked = false,
    this.entitlements,
    this.company,
  });

  factory MerchantProfileModel.fromJson(Map<String, dynamic> json) {
    return MerchantProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      phone: json['phone']?.toString(),
      language: json['language']?.toString(),
      role: json['role']?.toString() ?? 'ADMIN',
      isActive: json['isActive'] as bool? ?? true,
      hasPaid: json['hasPaid'] as bool? ?? false,
      billingLocked: json['billingLocked'] as bool? ?? false,
      entitlements: json['entitlements'] != null
          ? EntitlementsModel.fromJson(json['entitlements'] as Map<String, dynamic>)
          : null,
      company: json['company'] != null
          ? CompanyModel.fromJson(json['company'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'language': language,
      'role': role,
      'isActive': isActive,
      'hasPaid': hasPaid,
      'billingLocked': billingLocked,
      'entitlements': entitlements?.toJson(),
      'company': company?.toJson(),
    };
  }
}