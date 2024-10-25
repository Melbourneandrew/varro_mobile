import 'package:flutter/material.dart';
import 'package:scream_mobile/modals/modal-states.dart';
import '../store.dart';

const String defaultApplePayConfigString = '''{
  "provider": "apple_pay",
  "data": {
    "merchantIdentifier": "merchant.com.sams.fish",
    "displayName": "Sam's Fish",
    "merchantCapabilities": ["3DS", "debit", "credit"],
    "supportedNetworks": ["amex", "visa", "discover", "masterCard"],
    "countryCode": "US",
    "currencyCode": "USD",
    "requiredBillingContactFields": ["emailAddress", "name", "phoneNumber", "postalAddress"],
    "requiredShippingContactFields": [],
    "shippingMethods": [
      {
        "amount": "0.00",
        "detail": "Available within an hour",
        "identifier": "in_store_pickup",
        "label": "In-Store Pickup"
      },
      {
        "amount": "4.99",
        "detail": "5-8 Business Days",
        "identifier": "flat_rate_shipping_id_2",
        "label": "UPS Ground"
      },
      {
        "amount": "29.99",
        "detail": "1-3 Business Days",
        "identifier": "flat_rate_shipping_id_1",
        "label": "FedEx Priority Mail"
      }
    ]
  }
}''';

class PayModal extends StatelessWidget {


  final Function(ModalState ms) setModalState;

  PayModal({required this.setModalState});

  void completePurchase() {
    print("Completing purchase. adding 100 credits");
    Store.addCredits(100);
    closeModal();
  }

  void closeModal() {
    print("Closing modal");
    setModalState(ModalState.inactive);
  }

  void onApplePayResult(paymentResult) {
    debugPrint(paymentResult.toString());
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController apiKeyController = TextEditingController();

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white60,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          const BoxShadow(
            color: Colors.white,
            offset: Offset(-4, -4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Purchase more conversation credits',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),

          ElevatedButton(onPressed: completePurchase, child: Text("Dev purchase"))
        ],
      ),
    );
  }
}
