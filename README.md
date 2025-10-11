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

---

## 📦 Installation

Add this to your **pubspec.yaml**:

```yaml
dependencies:
  flutter_phajay: ^X.X.X
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

### Step 2: Add the `PaymentLinkScreen` Widget

To integrate the `PaymentLinkScreen` widget, use the following code snippet:

```dart
PaymentLinkScreen(
  amount: 100, // Replace with the desired amount
  description: "Test Payment", // Replace with your payment description
  publicKey: r"{YOUR_SECRET_KEY}", // Replace with your secret key
);
```

### Example

Here is a complete example of how to use the `PaymentLinkScreen` widget in your Flutter app:

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
        title: const Text('Payment Example'),
      ),
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
- Refer to the official documentation for more advanced usage and customization options.

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
