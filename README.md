# flutter_phajay

PhaJay Flutter SDK

The PhaJay Flutter SDK lets you create smooth and secure payment experiences inside native Android and iOS apps built with Flutter. It provides powerful, fully customizable UI screens and components that work out-of-the-box to collect and process users’ payment details through PhaJay’s multi-bank and QR payment network. Additionally, it supports advanced features like real-time transaction updates and multi-platform compatibility, including web, macOS, Linux, and Windows.

---

<img src="https://phapay-bucket.s3.ap-southeast-1.amazonaws.com/static/flutter-sdk.png" alt="Flutter-sdk-1" />

## ✨ Features

- Open a payment link inside your app
- Easy to use with a single widget
- Real-time transaction updates
- Multi-platform support (Android, iOS, Web, macOS, Linux, Windows)
- Secure and reliable payment processing
- Fully customizable UI components
- Built-in Noto Sans Lao font support for optimal Lao language rendering
- Consistent theming system across all payment interfaces

---

## 📦 Installation

Add this to your **pubspec.yaml**:

```yaml
dependencies:
  flutter_phajay: ^0.0.16
```

**Note**: `google_fonts` is automatically included as a dependency of `flutter_phajay` for Noto Sans Lao font support, so you don't need to add it manually.

Run the following command to fetch the package:

```bash
flutter pub get
```

---

## 🔧 Platform Configuration

### Android Configuration

#### 1. Internet Permission (Required)

Add the following permission to your `android/app/src/main/AndroidManifest.xml` file (usually already present in most Flutter projects):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

#### 2. Deep Link Configuration (Required for Payment Callbacks)

Add the following intent filter inside the `<activity>` tag in your `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop"
    android:theme="@style/LaunchTheme">
    
    <!-- Existing intent filter for MAIN/LAUNCHER -->
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Add this intent filter for PhaJay payment callbacks -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="phajay" 
              android:host="payment" />
    </intent-filter>
</activity>
```

#### 3. Bank App Integration (Optional)

If your app needs to open specific banking apps, add queries permissions in your `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Add this section before <application> -->
    <queries>
        <!-- For opening JDB banking app -->
        <package android:name="com.jdb.mobile.jdb" />
        <!-- For opening BCEL One app -->
        <package android:name="com.bcel.one" />
        <!-- Add other banking apps as needed -->
    </queries>
    
    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

### iOS Configuration

#### 1. Deep Link Configuration (Required for Payment Callbacks)

Add the following to your `ios/Runner/Info.plist` file:

```xml
<dict>
    <!-- Existing configurations -->
    
    <!-- Add URL scheme for PhaJay payment callbacks -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>phajay.payment.callback</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>phajay</string>
            </array>
        </dict>
    </array>
    
    <!-- Allow opening banking apps (Required for JDB and BCEL integration) -->
    <key>LSApplicationQueriesSchemes</key>
    <array>
        <string>jdbbank</string>
        <string>onepay</string>
    </array>
</dict>
```

#### 2. Network Security (iOS 9.0+)

If you're connecting to HTTP endpoints (not recommended for production), add the following to your `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Only add this for development/staging environments -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
```

**Note**: For production apps, always use HTTPS endpoints and remove the NSAppTransportSecurity configuration.

```

---

## 🔒 Security Considerations

### Production Deployment
1. **HTTPS Only**: Always use HTTPS endpoints in production
2. **API Key Security**: Store your PhaJay secret key securely
3. **Deep Link Validation**: Validate all incoming deep link parameters
4. **Certificate Pinning**: Consider implementing certificate pinning for additional security

### Secret Key Management
```dart
// ❌ Don't hardcode in source code
PaymentLinkScreen(
  publicKey: "your-secret-key-here",
);

// ✅ Use environment variables or secure storage
PaymentLinkScreen(
  publicKey: const String.fromEnvironment('PHAJAY_SECRET_KEY'),
);
```

---

## 🚀 Usage

### Step 1: Import the Library

In your Dart file, import the `flutter_phajay` library:

```dart
import 'package:flutter_phajay/flutter_phajay.dart';
```

### Step 2: (Optional) Apply Noto Sans Lao Theme

For optimal Lao language rendering, apply the built-in PhajayTheme to your MaterialApp:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_phajay/flutter_phajay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: PhajayTheme.lightTheme, // Apply Noto Sans Lao theme
      home: const MyHomePage(),
    );
  }
}
```

### Step 3: Add the `PaymentLinkScreen` Widget

To integrate the `PaymentLinkScreen` widget, use the following code snippet:

```dart
PaymentLinkScreen(
  amount: 100, // Replace with the desired amount
  description: "Test Payment", // Replace with your payment description
  publicKey: r"{YOUR_SECRET_KEY}", // Replace with your secret key
  onPaymentSuccess: () {
    // Handle payment success
    print('Payment successful!');
  },
  onPaymentError: (String error) {
    // Handle payment error
    print('Payment failed: $error');
  },
);
```

---

## ⚙️ Configuration

### Setting Base URL

You can customize the payment gateway base URL for different environments:

```dart
import 'package:flutter_phajay/flutter_phajay.dart';

void main() {
  // Option 1: Use default configuration (Production)
  // PhajayConfig.baseUrl will be 'https://payment-gateway.phajay.co'
  
  // Option 2: Set custom base URL for staging/development
  PhajayConfig.setBaseUrl('https://staging-payment-gateway.phajay.co');
  
  // Option 3: Environment-specific configuration
  if (isProduction()) {
    PhajayConfig.setBaseUrl('https://payment-gateway.phajay.co');
  } else if (isStaging()) {
    PhajayConfig.setBaseUrl('https://staging-payment-gateway.phajay.co');
  } else {
    PhajayConfig.setBaseUrl('http://localhost:3000');
  }
  
  runApp(MyApp());
}

// Available configuration methods:
// PhajayConfig.baseUrl               // Get current base URL
// PhajayConfig.setBaseUrl(url)       // Set custom base URL
// PhajayConfig.resetToDefault()      // Reset to default production URL

// Available API endpoints:
// PhajayConfig.createPaymentLink     // Payment link creation
// PhajayConfig.creditCardPayment     // Credit card payment
// PhajayConfig.wechatAlipayPayment   // WeChat/Alipay payment
// PhajayConfig.getTransaction        // Transaction status
// PhajayConfig.getPaymentMethods     // Payment methods
// PhajayConfig.uploadsPath           // Assets/uploads path
```

### Theme Customization

Flutter Phajay provides a built-in theme system with Noto Sans Lao font for optimal Lao language support:

#### Using Pre-built Theme

```dart
import 'package:flutter/material.dart';
import 'package:flutter_phajay/flutter_phajay.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: PhajayTheme.lightTheme, // Applies Noto Sans Lao font globally
      home: MyHomePage(),
    );
  }
}
```

#### Using Individual Text Styles

```dart
import 'package:flutter_phajay/flutter_phajay.dart';

// Available text styles with Noto Sans Lao:
Text('Main Title', style: PhajayTheme.heading1);
Text('Section Header', style: PhajayTheme.heading2);
Text('Subsection', style: PhajayTheme.heading3);
Text('Body content', style: PhajayTheme.bodyText);
Text('Small text', style: PhajayTheme.bodyTextSmall);
Text('Caption', style: PhajayTheme.caption);

// Customizable styles:
Text('Custom', style: PhajayTheme.bodyText.copyWith(
  color: Colors.blue,
  fontWeight: FontWeight.bold,
));

// Direct Noto Sans Lao usage:
Text('Custom Style', style: PhajayTheme.notoSansLao(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: Colors.green,
));
```

#### Theme Features

- **Noto Sans Lao Font**: Optimized for Lao language rendering
- **Consistent Typography**: Unified font family across all payment interfaces
- **Responsive Design**: Proper font sizes for different screen densities
- **Accessibility**: Improved readability for Lao text content
- **Customizable**: All styles can be extended with `.copyWith()`

---

### Example

Here is a complete example of how to use the `PaymentLinkScreen` widget with proper theming in your Flutter app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_phajay/flutter_phajay.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Phajay Example',
      theme: PhajayTheme.lightTheme, // Apply Noto Sans Lao theme
      home: const PaymentExampleScreen(),
    );
  }
}

class PaymentExampleScreen extends StatelessWidget {
  const PaymentExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Example', style: PhajayTheme.heading2),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ຍິນດີຕ້ອນຮັບ', // Welcome in Lao
              style: PhajayTheme.heading1,
            ),
            const SizedBox(height: 20),
            PaymentLinkScreen(
              amount: 100000, // 100,000 LAK
              description: "ການທົດສອບການຈ່າຍເງິນ", // Test Payment in Lao
              publicKey: r"{YOUR_SECRET_KEY}",
              onPaymentSuccess: () {
                print('Payment successful!');
                // Handle payment success
              },
              onPaymentError: (String error) {
                print('Payment failed: $error');
                // Handle payment error
              },
            ),
          ],
        ),
      ),
    );
  }
}
```
      body: Center(
        child: PaymentLinkScreen(
          amount: 100,
          description: "Test Payment",
          publicKey: r"{YOUR_SECRET_KEY}",
        ),
      ),
    );
  }
}
```

---

## 📖 Documentation

- For official details, please visit the [PhaJay Official Website](https://www.phajay.co/lo).
- For further development documentation, refer to the [PhaJay Payment Documentation](https://payment-doc.lailaolab.com/v1).

---

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Deep Link Not Working
- **Android**: Ensure the intent filter is correctly added to your MainActivity
- **iOS**: Verify CFBundleURLSchemes is properly configured in Info.plist
- Test deep links using: `adb shell am start -W -a android.intent.action.VIEW -d "phajay://payment?status=success" com.yourapp.package`

#### 2. Banking Apps Not Opening
- **Android**: Add required package queries in AndroidManifest.xml
- **iOS**: Include LSApplicationQueriesSchemes in Info.plist
- Ensure target banking apps are installed on the device

#### 3. Payment Callbacks Not Received
- Verify your app can handle the `phajay://` URL scheme
- Check that app_links plugin is properly configured
- Ensure your app is in foreground when payment completes

#### 4. Font Rendering Issues
- Apply PhajayTheme.lightTheme to your MaterialApp
- Verify google_fonts dependency is added
- Check internet connectivity for font downloads

### Testing Deep Links

#### Android Testing
```bash
# Test payment success callback
adb shell am start -W -a android.intent.action.VIEW -d "phajay://payment?status=success&amount=100" com.yourapp.package

# Test payment failure callback  
adb shell am start -W -a android.intent.action.VIEW -d "phajay://payment?status=failed&error=timeout" com.yourapp.package
```

#### iOS Testing
Use Simulator's Device > Device > Safari, then enter: `phajay://payment?status=success&amount=100`

---

## 📋 Requirements

### Minimum Requirements
- **Flutter**: 1.17.0 or higher
- **Dart SDK**: 3.9.0 or higher  
- **Android**: API level 21 (Android 5.0) or higher
- **iOS**: iOS 12.0 or higher

### Dependencies
The following dependencies are automatically included with `flutter_phajay`:
- `http: ^1.5.0` - For HTTP requests to payment APIs
- `qr_flutter: ^4.1.0` - For QR code generation
- `socket_io_client: ^3.1.2` - For real-time payment status updates
- `url_launcher: ^6.3.0` - For launching banking apps
- `app_links: ^6.3.2` - For deep link handling
- `flutter_inappwebview: ^6.0.0` - For credit card payment webviews
- `google_fonts: ^6.1.0` - For Noto Sans Lao font rendering
- `lottie: ^3.3.2` - For loading animations
- `intl: ^0.20.2` - For number formatting

**You don't need to add these manually** - they will be installed automatically when you add `flutter_phajay` to your pubspec.yaml.

### Permissions Summary

#### Android Required:
- `android.permission.INTERNET` - For payment API calls
- Deep link intent filter - For payment callbacks
- Package queries (optional) - For opening banking apps

#### iOS Required:  
- CFBundleURLSchemes - For payment callbacks
- LSApplicationQueriesSchemes - For opening banking apps
- Network access - For payment API calls

---

## 🛠️ Notes

- Replace `{YOUR_SECRET_KEY}` with your actual secret key. To retrieve your secret key, please refer to the [PhaJay Registration Documentation](https://payment-doc.lailaolab.com/v1/registration).
- Ensure that your app has the necessary permissions and configurations to connect to the payment gateway.
- For optimal Lao language support, apply `PhajayTheme.lightTheme` to your MaterialApp.
- The SDK automatically downloads and uses Noto Sans Lao font for proper Lao text rendering.
- All text styles in PhajayTheme can be customized using `.copyWith()` method.
- Refer to the official documentation for more advanced usage and customization options.

## 🎨 Best Practices

### Font Usage
```dart
// ✅ Recommended: Use PhajayTheme for consistent Lao font styling
Text('ຍິນດີຕ້ອນຮັບ', style: PhajayTheme.heading1);

// ✅ Good: Apply theme globally (Noto Sans Lao automatically applied)
MaterialApp(
  theme: PhajayTheme.lightTheme,  // google_fonts automatically included
  home: MyHomePage(),
);

// ❌ Avoid: Manual font family specification
Text('ຍິນດີຕ້ອນຮັບ', style: TextStyle(fontFamily: 'NotoSansLao'));

// ❌ Avoid: Adding google_fonts dependency manually
// dependencies:
//   google_fonts: ^6.1.0  // Already included with flutter_phajay
```

### Configuration
```dart
// ✅ Best: Configure environment early in main()
void main() {
  if (kDebugMode) {
    PhajayConfig.setBaseUrl('http://localhost:3000');
  } else {
    PhajayConfig.setBaseUrl('https://payment-gateway.phajay.co');
  }
  runApp(MyApp());
}
```

---

## 📞 Support

If you encounter any issues or have questions, feel free to reach out to the maintainers of this library.

---

### iOS (Info.plist) — Allow Opening Bcel One and JDB Yes via Deep Link

Add the following configuration to your iOS `ios/Runner/Info.plist` file inside the top-level `<dict>`:

```xml
<!-- Required: URL scheme for PhaJay payment callbacks -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>phajay.payment.callback</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>phajay</string>
        </array>
    </dict>
</array>

<!-- Required: Allow opening banking apps via URL schemes -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>jdbbank</string>
    <string>onepay</string>
    <!-- Add additional banking app schemes as needed -->
</array>
```

This configuration enables your app to:
1. Receive payment callbacks via the `phajay://` URL scheme
2. Check if banking apps (BCEL One, JDB Yes) are installed
3. Open banking apps for payment processing

**Additional Banking Apps:**
If you need to support additional banking apps, add their URL schemes to the `LSApplicationQueriesSchemes` array. Common schemes include:
- `ldbbank://` - Lao Development Bank
- `indochinabank://` - Indochina Bank
- Add others as provided by the respective banks
