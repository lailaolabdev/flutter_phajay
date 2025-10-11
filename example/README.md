# example

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# How to Use flutter_phajay Library

## Introduction
The `flutter_phajay` library provides a seamless way to integrate payment functionalities into your Flutter application. This guide will walk you through the steps to use the library and integrate the `PaymentLinkScreen` widget into your project.

---

## Installation

1. Add the `flutter_phajay` package to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_phajay:
    path: ../pack/flutter_phajay
```

2. Run the following command to fetch the package:

```bash
flutter pub get
```

---

## Usage

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

## Notes

- Replace `{YOUR_SECRET_KEY}` with your actual secret key.
- Ensure that your app has the necessary permissions and configurations to connect to the payment gateway.
- Refer to the official documentation for more advanced usage and customization options.

### iOS (Info.plist) — allow opening Bcel One and JDB Yes via deep link

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

---

## Support

If you encounter any issues or have questions, feel free to reach out to the maintainers of this library.
