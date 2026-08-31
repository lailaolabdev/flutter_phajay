## 0.0.23

* **Fix:** the "Save QR" button could get stuck spinning forever if the native photo-library permission flow (via `gal`) never returned a result — most commonly because the host app is missing the required Android (`WRITE_EXTERNAL_STORAGE` on API <= 29, `requestLegacyExternalStorage`) or iOS (`NSPhotoLibraryAddUsageDescription` / `NSPhotoLibraryUsageDescription`) configuration documented in the README. Each native call in the save flow is now wrapped with a timeout, so the button always recovers and shows an error instead of hanging indefinitely.

## 0.0.22

* **Fix:** hardened every `Image.asset` logo call (`PaymentLinkScreen` header, `QRPaymentScreen` bank/PhaJay logos) against a `RenderFlex overflowed` crash that occurred whenever an asset failed to resolve (e.g. a stale asset bundle right after adding/upgrading the package). Each image now has an explicit bounding size and an `errorBuilder` fallback, so a failed image load can no longer blow out the surrounding layout.

## 0.0.21

* **Save QR to gallery:** `QRPaymentScreen` now supports saving the payment QR code to the device's photo gallery via the new "Save QR" button, powered by the `gal` package.
* **Branded export card:** the saved image is a designed card (PhaJay logo, amount, description, QR code, and bank name) rather than a bare QR code, so it stands on its own once shared or saved.
* Added required Android (`WRITE_EXTERNAL_STORAGE`) and iOS (`NSPhotoLibraryAddUsageDescription` / `NSPhotoLibraryUsageDescription`) permissions, documented in the README's Platform Configuration section.
* Bumped the example app's macOS deployment target to 11.0 for compatibility with `gal`.

## 0.0.20

* Remove debug print statements from `BankTile` and `QRPaymentScreen`.

## 0.0.19

* **Dynamic bank URL from API:** `QRPaymentScreen` now accepts an optional `bankUrl` parameter; when provided, it is used directly for QR generation instead of the hardcoded endpoint mapping.
* **Pass method URL through `BankTile`:** Added `methodUrl` field to `BankTile` and wired `method['url']` from `paymentLinkData.paymentGroups.methods` so each payment method uses its own API-configured endpoint.

## 0.0.18

* **BREAKING:** Modernized localization system with Flutter's standard AppLocalizations
  - Migrated from custom PhajayLocalizations to Flutter's built-in i18n system
  - Added comprehensive ARB files (app_en.arb, app_lo.arb) with 25+ error message translations
  - Implemented reactive language switching with ChangeNotifier pattern
  - Fixed Lao language translation functionality that was previously broken
* **Enhanced AndroidManifest.xml configuration:**
  - Added INTERNET and ACCESS_NETWORK_STATE permissions for API calls
  - Enabled cleartext traffic for HTTP support
  - Added comprehensive deep link support for all banking apps (LDB, JDB, STB, Lao QR)
  - Enhanced phajay:// scheme handling with success/error callbacks
* **Improved Error Handling:**
  - Added standardized error message translations for all API responses
  - Implemented consistent SnackBar styling across payment screens
  - Enhanced button state management based on data availability
* **WebView & Payment Integration:**
  - Full flutter_inappwebview support for credit card payments
  - Improved deep linking from banking applications
  - Enhanced payment status monitoring with timer-based checks
* **UI/UX Improvements:**
  - Consistent theme application across all payment screens
  - Better loading states and user feedback
  - Improved button disable logic when payment data unavailable

## 0.0.17

* Fixed README.md markdown formatting issues for proper GitHub rendering.
* Enhanced documentation with comprehensive platform configuration guides.
* Added detailed troubleshooting section with common issues and solutions.
* Improved dependency management documentation - clarified that google_fonts is automatically included.
* Added security considerations and best practices for production deployment.
* Enhanced iOS and Android configuration sections with complete setup instructions.

## 0.0.16

* Minor version update for continuous improvements.
* Maintained stability and performance optimizations.

## 0.0.15

* Enhanced null safety in QR payment screen to prevent runtime crashes.
* Improved service charge handling with proper type casting for API responses.
* Fixed "isNegative" null error by making formatThousand function null-safe.
* Added comprehensive Noto Sans Lao font integration for proper Lao language rendering.
* Created PhajayTheme system for consistent typography across components.
* Added loading animations for better user experience in QR generation.
* Updated documentation with font integration and theming best practices.
* Improved socket connection reliability and payment status callbacks.

## 0.0.10

* Updated license to reflect "PHAJAY".
* Added PaymentLinkScreen widget documentation.

## 0.0.9

* Improved socket connection handling.
* Enhanced error logging for better debugging.

## 0.0.8

* Added support for additional payment gateways.
* Fixed minor UI bugs in PaymentLinkScreen.

## 0.0.7

* Optimized performance for large transactions.
* Updated dependencies to latest versions.

## 0.0.6

* Introduced PaymentLinkScreen widget.
* Added example project for integration testing.

## 0.0.5

* Fixed critical bug in QR payment screen.
* Improved documentation for helper methods.

## 0.0.4

* Added QR payment screen functionality.
* Enhanced UI/UX for payment screens.

## 0.0.3

* Added helper methods for payment processing.
* Improved error handling for API calls.

## 0.0.2

* Initial implementation of core payment features.
* Basic UI for payment screens.

## 0.0.1

* TODO: Describe initial release.
