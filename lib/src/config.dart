/// Configuration class for PhajayPayment
class PhajayConfig {
  /// Default base URL for payment gateway
  static const String _defaultBaseUrl = 'https://payment-gateway.phajay.co';
  
  /// Current base URL (can be overridden)
  static String _baseUrl = _defaultBaseUrl;
  
  /// Get the current base URL
  static String get baseUrl => _baseUrl;
  
  /// Set custom base URL (useful for development/testing)
  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  
  /// Reset to default base URL
  static void resetToDefault() {
    _baseUrl = _defaultBaseUrl;
  }
  
  /// API endpoints
  static String get createPaymentLink => '$_baseUrl/v1/api/link/payment-link';
  static String get getTransaction => '$_baseUrl/v1/api/link/get-transaction';
  static String get getPaymentMethods => '$_baseUrl/v1/api/setting/payment-link/methods';
  static String get creditCardPayment => '$_baseUrl/v1/api/jdb2c2p/payment/credit-card/with-ui';
  static String get wechatAlipayPayment => '$_baseUrl/v1/api/wechat-alipay/payment-link/wechat-alipay';
  static String get qrPaymentGenerate => '$_baseUrl/v1/api/qr-payment/qr';
  static String get uploadsPath => '$_baseUrl/uploads';
  
  /// Bank-specific QR endpoints
  static String get generateJdbQr => '$_baseUrl/v1/api/link/generate-jdb-qr';
  static String get generateBcelQr => '$_baseUrl/v1/api/link/generate-bcel-qr';
  static String get generateIbQr => '$_baseUrl/v1/api/link/generate-ib-qr';
  static String get generateLdbQr => '$_baseUrl/v1/api/link/generate-ldb-qr';
  static String get generateStbQr => '$_baseUrl/v1/api/link/generate-stb-qr';
}
