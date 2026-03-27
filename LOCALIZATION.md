# Flutter Phajay Localization

Flutter Phajay library รองรับ 2 ภาษา: **ลาว (Lao) 🇱🇦** และ **อังกฤษ (English) 🇺🇸**

## การเริ่มต้นใช้งาน

### 1. Import library
```dart
import 'package:flutter_phajay/flutter_phajay.dart';
```

### 2. ใช้งาน Payment Screen พร้อม Language Selector
```dart
PaymentLinkScreen(
  amount: 50000,
  description: "Test Payment",
  publicKey: "your_public_key",
  onPaymentSuccess: () => print("Success"),
  onPaymentError: (error) => print("Error: $error"),
)
```

**หน้า Payment จะมี Language Dropdown อัตโนมัติ** ที่มุมซ้ายบนของหน้าจอ พร้อมธงประเทศและชื่อภาษา:
- 🇺🇸 EN (English)
- 🇱🇦 ລາວ (Lao)

### 3. ตั้งค่าภาษาเริ่มต้น (ถ้าต้องการ)
```dart
// ตั้งค่าภาษาเป็นลาวก่อนแสดงหน้า Payment
PhajayLocalizations.setLanguage(PhajayLanguage.lao);

// ตั้งค่าภาษาเป็นอังกฤษ (ค่าเริ่มต้น)
PhajayLocalizations.setLanguage(PhajayLanguage.english);
```

### 4. การเปลี่ยนภาษาโดยโปรแกรม (ไม่แนะนำ)
```dart
// ผู้ใช้สามารถเปลี่ยนภาษาผ่าน dropdown ในหน้า Payment ได้แล้ว
// แต่หากต้องการเปลี่ยนโดยโปรแกรม สามารถทำได้ดังนี้:
PhajayLocalizations.setLanguage(PhajayLanguage.lao);
```

## ข้อความที่รองรับ

### ภาษาอังกฤษ (English)
- **Select For Payment** - เลือกวิธีการชำระเงิน
- **Total Amount** - ยอดรวม
- **Banks Payment** - การชำระเงินผ่านธนาคาร
- **Credit Cards** - บัตรเครดิต
- **QR Payments** - การชำระเงินด้วย QR
- **Wallets** - กระเป๋าเงิน
- **Processing Credit Card Payment...** - กำลังดำเนินการชำระเงินด้วยบัตรเครดิต...
- **Payment Successful!** - การชำระเงินสำเร็จ!
- **Minimum amount for credit card payment is 5,000 LAK** - จำนวนเงินขั้นต่ำสำหรับการชำระด้วยบัตรเครดิตคือ 5,000 กีบ

### ภาษาลาว (Lao)
- **ເລືອກວິທີການຈ່າຍເງິນ** - Select For Payment
- **ຍອດລວມ** - Total Amount  
- **ການຈ່າຍເງິນຜ່ານທະນາຄານ** - Banks Payment
- **ບັດເຄຣດິດ** - Credit Cards
- **ການຈ່າຍເງິນດ້ວຍ QR** - QR Payments
- **ກະເປົ໋າເງິນ** - Wallets
- **ກຳລັງດຳເນີນການຈ່າຍເງິນດ້ວຍບັດເຄຣດິດ...** - Processing Credit Card Payment...
- **ການຊຳລະສຳເລັດແລ້ວ!** - Payment Successful!
- **ຈຳນວນເງິນຂັ້ນຕ່ຳສຳຫຼັບການຈ່າຍດ້ວຍບັດເຄຣດິດແມ່ນ 5,000 ກີບ** - Minimum amount for credit card payment is 5,000 LAK

## ภาษาเริ่มต้น
- ภาษาเริ่มต้นคือ **อังกฤษ (English)**
- ไม่จำเป็นต้องตั้งค่าอะไรเพิ่มเติมหากต้องการใช้ภาษาอังกฤษ

## หมายเหตุ
- **การเปลี่ยนภาษาในหน้า Payment:** ผู้ใช้สามารถเปลี่ยนภาษาได้โดยตรงผ่าน dropdown ที่มุมซ้ายบนของหน้า Payment Screen
- **การเปลี่ยนภาษาจะส่งผลทันที:** UI จะอัปเดตทันทีเมื่อเลือกภาษาใหม่
- **ไม่จำเป็นต้องสร้างปุ่มเปลี่ยนภาษาเอง:** หน้า PaymentLinkScreen มี language dropdown built-in แล้ว
- **Responsive Design:** Dropdown จะปรับตำแหน่งให้เหมาะสมกับขนาดหน้าจอ

## ตัวอย่างการใช้งานแบบง่าย
```dart
import 'package:flutter/material.dart';
import 'package:flutter_phajay/flutter_phajay.dart';

class MyPaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PaymentLinkScreen(
      amount: 25000,
      description: "Order #12345",
      publicKey: "your_public_key_here",
      onPaymentSuccess: () {
        // Handle successful payment
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment successful!')),
        );
      },
      onPaymentError: (error) {
        // Handle payment error
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $error')),
        );
      },
    );
  }
}
```

**ผลลัพธ์:** หน้า Payment จะแสดงพร้อม dropdown เปลี่ยนภาษาที่มุมซ้ายบน ผู้ใช้สามารถเปลี่ยนระหว่าง 🇺🇸 EN และ 🇱🇦 ລາວ ได้ทันที
