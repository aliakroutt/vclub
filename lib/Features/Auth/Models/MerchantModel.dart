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

class CompanyModel {
  final String id;
  final String name;
  final String? tradeName;
  final String? siret;
  final String? uid;
  final String? slug;
  final String? qrUrl;
  final String? industry;
  final String? contactEmail;
  final String? contactPhone;
  final AddressModel? address;
  final String? status;
  final String? subscriptionStatus;
  final String? stripePlan;
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
    this.contactEmail,
    this.contactPhone,
    this.address,
    this.status,
    this.subscriptionStatus,
    this.stripePlan,
    this.logo,
    this.facebook,
    this.instagram,
    this.linkedin,
    this.twitter,
    this.youtube,
    this.tiktok,
    this.googleReviewLink,
  });

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
      contactEmail: json['contactEmail']?.toString(),
      contactPhone: json['contactPhone']?.toString(),
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      status: json['status']?.toString(),
      subscriptionStatus: json['subscriptionStatus']?.toString(),
      stripePlan: json['stripePlan']?.toString(),
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
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'address': address?.toJson(),
      'status': status,
      'subscriptionStatus': subscriptionStatus,
      'stripePlan': stripePlan,
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
      'company': company?.toJson(),
    };
  }
}