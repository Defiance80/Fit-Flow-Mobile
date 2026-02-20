import 'package:elms/common/models/blueprints.dart';

class AppSettingModel extends Model {
  final String? systemColor;
  final String? currencyCode;
  final String? currencySymbol;
  final String? taxType;
  final List<PaymentSettingModel>? activePaymentSettings;
  final String? playstoreUrl;
  final String? appstoreUrl;
  final String? androidVersion;
  final String? iosVersion;
  final String? appVersion;
  final String? maintainceMode;
  final String? forceUpdate;
  final String? websiteURL;

  AppSettingModel({
    this.systemColor,
    this.currencyCode,
    this.currencySymbol,
    this.taxType,
    this.activePaymentSettings,
    this.playstoreUrl,
    this.appstoreUrl,
    this.androidVersion,
    this.iosVersion,
    this.appVersion,
    this.maintainceMode,
    this.forceUpdate,
    this.websiteURL,
  });

  AppSettingModel.fromJson(Map<String, dynamic> json)
    : systemColor = json['system_color'],
      currencyCode = json['currency_code'],
      currencySymbol = json['currency_symbol'],
      taxType = json['tax_type'],
      activePaymentSettings = json['active_payment_settings'] != null
          ? (json['active_payment_settings'] as List)
                .map((e) => PaymentSettingModel.fromJson(e))
                .toList()
          : null,
      playstoreUrl = json['playstore_url'],
      appstoreUrl = json['appstore_url'],
      androidVersion = json['android_version'],
      iosVersion = json['ios_version'],
      appVersion = json['app_version'],
      maintainceMode = json['maintaince_mode'],
      websiteURL = json['website_url'],
      forceUpdate = json['force_update'];

  @override
  Map<String, dynamic> toJson() {
    return {
      'system_color': systemColor,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'tax_type': taxType,
      'active_payment_settings': activePaymentSettings
          ?.map((e) => e.toJson())
          .toList(),
      'playstore_url': playstoreUrl,
      'appstore_url': appstoreUrl,
      'android_version': androidVersion,
      'ios_version': iosVersion,
      'app_version': appVersion,
      'maintaince_mode': maintainceMode,
      'force_update': forceUpdate,
    };
  }
}

class PaymentSettingModel {
  final String? paymentGateway;
  final String? razorpayApiKey;

  PaymentSettingModel({this.paymentGateway, this.razorpayApiKey});

  factory PaymentSettingModel.fromJson(Map<String, dynamic> json) {
    return PaymentSettingModel(
      paymentGateway: json['payment_gateway'],
      razorpayApiKey: json['razorpay_api_key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_gateway': paymentGateway,
      'razorpay_api_key': razorpayApiKey,
    };
  }
}
