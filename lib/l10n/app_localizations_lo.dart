// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Lao (`lo`).
class AppLocalizationsLo extends AppLocalizations {
  AppLocalizationsLo([String locale = 'lo']) : super(locale);

  @override
  String get selectForPayment => 'ເລືອກວິທີການຈ່າຍເງິນ';

  @override
  String get transactionVerified =>
      'ການເຮັດ​ທຸລະ​ກຳ​ໄດ້​ຮັບ​ການ​ຢັ້ງ​ຢືນ​ຄວາມ​ຖືກ​ຕ້ອງ\n​ແລະ​ຄວາມ​ປອດ​ໄພ​ແລ້ວ';

  @override
  String get totalAmount => 'ຍອດລວມ';

  @override
  String get safetyMessage =>
      'ຄວາມປອດໄພຂອງທ່ານແມ່ນບຸລິມະສິດສູງສຸດຂອງພວກເຮົາ\nໝັ້ນໃຈໄດ້ວ່າການຈ່າຍເງິນຂອງທ່ານມີຄວາມປອດໄພ. ຂໍໃຫ້ທ່ານໝັ້ນໃຈວ່າຂໍ້ມູນຂອງທ່ານຈະຖືກປົກປ້ອງຢູ່ສະເໝີ.';

  @override
  String get generatingPaymentLink => 'ກຳລັງສ້າງລິ້ງການຊຳລະ...';

  @override
  String get processingCreditCard => 'ກຳລັງດຳເນີນການຈ່າຍເງິນດ້ວຍບັດເຄຣດິດ...';

  @override
  String get paymentLinkNotAvailable => 'ບໍ່ມີລິ້ງການຈ່າຍເງິນ';

  @override
  String get minimumAmountRequired =>
      'ຈຳນວນເງິນຂັ້ນຕ່ຳສຳຫຼັບການຈ່າຍດ້ວຍບັດເຄຣດິດແມ່ນ 5,000 ກີບ';

  @override
  String get minimumRequired => 'ຕ້ອງການຂັ້ນຕ່ຳ 5,000 ກີບ';

  @override
  String get banksPayment => 'ການຈ່າຍເງິນຜ່ານທະນາຄານ';

  @override
  String get creditCards => 'ບັດເຄຣດິດ';

  @override
  String get qrPayments => 'ການຈ່າຍເງິນດ້ວຍ QR';

  @override
  String get wallets => 'ກະເປົາເງິນ';

  @override
  String get fee => 'ຄ່າທຳນຽມ';

  @override
  String get noPaymentUrlReceived => 'ບໍ່ໄດ້ຮັບ URL ການຊຳລະຈາກເຊີບເວີ';

  @override
  String processingPayment(String bankName) {
    return 'ກຳລັງດຳເນີນການຊຳລະ $bankName...';
  }

  @override
  String get paymentSuccess => 'ການຊຳລະສຳເລັດ';

  @override
  String get paymentSuccessful => 'ການຊຳລະສຳເລັດແລ້ວ!';

  @override
  String get amount => 'ຈຳນວນເງິນ';

  @override
  String get transactionId => 'ລະຫັດທຸລະກຳ';

  @override
  String get done => 'ສຳເລັດ';

  @override
  String get waitingForPayment => 'ລໍຖ້າການຊຳລະ...';

  @override
  String get paymentCompleted => 'ການຊຳລະສຳເລັດແລ້ວ!';

  @override
  String get paymentCancelled => 'ການຊຳລະຖືກຍົກເລີກ';

  @override
  String get paymentExpired => 'ການຊຳລະໝົດອາຍຸແລ້ວ';

  @override
  String get tryAgain => 'ລອງອີກຄັ້ງ';

  @override
  String get close => 'ປິດ';

  @override
  String get description => 'ລາຍລະອຽດ';

  @override
  String get payWithBankApp => 'ຈ່າຍດ້ວຍແອັບທະນາຄານ';

  @override
  String get orScanQR => 'ຫຼື ສະແກນ QR';

  @override
  String get generatingQR => 'ກຳລັງສ້າງ QR...';

  @override
  String get qrCodeNotGenerated => 'ບໍ່ສາມາດສ້າງ QR ໄດ້';

  @override
  String get openBankApp => 'ເປີດແອັບທະນາຄານ';

  @override
  String get saveQR => 'ບັນທຶກ QR';

  @override
  String get note =>
      'ໝາຍເຫດ :\nບາງຄັ້ງການໂອນເງິນລະຫວ່າງທະນາຄານອາດຈະບໍ່ສາມາດໃຊ້ໄດ້';

  @override
  String get qrInstructions =>
      '1. \"ກົດບັນທຶກ QR ໂຄດ\" ຫຼື ຖ່າຍພາບໜ້າຈໍຂອງ QR ໂຄດ';

  @override
  String get error => 'ຜິດພາດ';

  @override
  String get orderNoIsRequired => 'ເລກທີສັ່ງຊື້ຈຳເປັນຕ້ອງເປັນສະຕຣິງ';

  @override
  String get amountIsRequired => 'ຈຳນວນເງິນຈຳເປັນ';

  @override
  String get amountMustBeValidNumber => 'ຈຳນວນເງິນຕ້ອງເປັນຕົວເລກທີ່ຖືກຕ້ອງ';

  @override
  String get descriptionIsRequired => 'ລາຍລະອຽດຈຳເປັນ';

  @override
  String get amountMustBeBetween1And999ForNonKyc =>
      'ຈຳນວນເງິນຕ້ອງຢູ່ລະຫວ່າງ 1 ແລະ 999 ສຳຫຼັບຜູ້ໃຊ້ທີ່ບໍ່ມີ KYC';

  @override
  String get amountExceedsLimitForKycUsers =>
      'ຈຳນວນເງິນເກີນຂີດຈຳກັດ 100,000,000 ສຳຫຼັບຜູ້ໃຊ້ KYC';

  @override
  String get amountMustBeGreaterThan1ForKyc =>
      'ຈຳນວນເງິນຕ້ອງຫຼາຍກວ່າ 1 ສຳຫຼັບຜູ້ໃຊ້ KYC';

  @override
  String get amountExceedsLimitForBannedUsers =>
      'ຈຳນວນເງິນເກີນຂີດຈຳກັດ, ບໍ່ສາມາດເກີນ 999 ກີບສຳຫຼັບຜູ້ໃຊ້ທີ່ຖືກຫ້າມ';

  @override
  String get affiliatePercentMustBeBetween0And90 =>
      'ເປີເຊັນ affiliate ຕ້ອງຢູ່ລະຫວ່າງ 0 ແລະ 90';

  @override
  String get amountMustBeGreaterThanAffiliateAmount =>
      'ຈຳນວນເງິນຕ້ອງຫຼາຍກວ່າຈຳນວນເງິນ affiliate';

  @override
  String get userNotFound => 'ບໍ່ພົບຜູ້ໃຊ້';

  @override
  String get rateLimitExceeded => 'ເກີນຂີດຈຳກັດ. ອະນຸຍາດສູງສຸດ 20 ທຸລະກຳຕໍ່ມື້';

  @override
  String get internalServerError => 'ຂໍ້ຜິດພາດພາຍໃນເຊີບເວີ';

  @override
  String get paymentNotFound => 'ບໍ່ພົບການຊຳລະ';

  @override
  String get descriptionMustNotContainLaoOrThaiText =>
      'ລາຍລະອຽດຕ້ອງບໍ່ມີຂໍ້ຄວາມພາສາລາວຫຼືໄທ';

  @override
  String get transactionIsExpired => 'ທຸລະກຳໝົດອາຍຸແລ້ວ';

  @override
  String get jdbErrorNotSuccess => 'ຂໍ້ຜິດພາດ JDB ບໍ່ສຳເລັດ';

  @override
  String get failedToGenerateQrData => 'ລົ້ມເຫຼວໃນການສ້າງຂໍ້ມູນ QR';

  @override
  String get descriptionMustNotContainDashCharacter =>
      'ລາຍລະອຽດຕ້ອງບໍ່ມີສັນຍາລັກ \'-\'';

  @override
  String get descriptionMustNotExceed25Characters =>
      'ລາຍລະອຽດຕ້ອງບໍ່ເກີນ 25 ຕົວອັກສອນ';

  @override
  String get creditCardPaymentNotAllowedForNonKyc =>
      'ບໍ່ອະນຸຍາດການຊຳລະດ້ວຍບັດເຄຣດິດສຳຫຼັບຜູ້ໃຊ້ທີ່ບໍ່ມີ KYC';

  @override
  String get exchangeNotFound => 'ບໍ່ພົບອັດຕາແລກປ່ຽນ';

  @override
  String get amountNotFound => 'ບໍ່ພົບຈຳນວນເງິນ';

  @override
  String get callbackSettingNotFound => 'ບໍ່ພົບການຕັ້ງຄ່າ callback';
}
