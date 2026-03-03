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
  flutter_phajay: ^X.X.X
  google_fonts: ^6.1.0  # Required for Noto Sans Lao font support
```

Run the following command to fetch the package:

```bash
flutter pub get
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
// ✅ Recommended: Use PhajayTheme for consistent styling
Text('ຍິນດີຕ້ອນຮັບ', style: PhajayTheme.heading1);

// ✅ Good: Apply theme globally
MaterialApp(
  theme: PhajayTheme.lightTheme,
  home: MyHomePage(),
);

// ❌ Avoid: Manual font family specification
Text('ຍິນດີຕ້ອນຮັບ', style: TextStyle(fontFamily: 'NotoSansLao'));
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

If your app needs to open the Bcel One mobile app or the JDB Yes app using URL schemes (deep links), add the following to your iOS `Info.plist` so iOS will allow queries to those URL schemes:

Place this inside the top-level `<dict>` of `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
  <string>jdbbank</string>
  <string>onepay</string>
</array>
```

This allows your app to check whether the target apps are installed and to open them via their URL schemes. Add any additional schemes the payment partners require.
