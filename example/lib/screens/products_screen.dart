import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:adapty_flutter/models/adapty_error.dart';
import 'package:adapty_flutter/models/adapty_product.dart';
import 'package:adapty_flutter_example/Helpers/value_to_string.dart';
import 'package:adapty_flutter_example/screens/discounts_screen.dart';
import 'package:adapty_flutter_example/widgets/details_container.dart';
import 'package:adapty_flutter_example/widgets/error_dialog.dart';
import 'package:flutter/material.dart';

class ProductsScreen extends StatefulWidget {
  final List<AdaptyProduct> products;
  ProductsScreen(this.products);

  static showProductsPage(BuildContext context, List<AdaptyProduct> products) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ProductsScreen(products),
    );
  }

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemBuilder: (ctx, index) {
                final product = widget.products[index];
                final details = {
                  'Vendor Product Id': valueToString(product.vendorProductId),
                  'Introductory Offer Eligibility': valueToString(product.introductoryOfferEligibility),
                  'Promotional Offer Eligibility': valueToString(product.promotionalOfferEligibility),
                  'Promotional Offer Id': valueToString(product.promotionalOfferId),
                  'Variation Id': valueToString(product.variationId),
                  'Localized Description': valueToString(product.localizedDescription),
                  'Localized Title': valueToString(product.localizedTitle),
                  'Price': valueToString(product.price),
                  'Currency Code': valueToString(product.currencyCode),
                  'Currency Symbol': valueToString(product.currencySymbol),
                  'Region Code': valueToString(product.regionCode),
                  'Subscription Period': adaptyPeriodToString(product.subscriptionPeriod),
                  'Free Trial Period': adaptyPeriodToString(product.freeTrialPeriod),
                  'Subscription Group Identifier': valueToString(product.subscriptionGroupIdentifier),
                  'Localized Price': valueToString(product.localizedPrice),
                  'Localized Subscription Period': valueToString(product.localizedSubscriptionPeriod),
                  'Paywall A/B Test Name': valueToString(product.paywallABTestName),
                  'Paywall Name': valueToString(product.paywallName),
                };
                final detailPages = {
                  if (product.introductoryDiscount != null)
                    'Introductory Discount': () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => DiscountsScreen([product.introductoryDiscount]))),
                  'Discounts': () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => DiscountsScreen(product.discounts))),
                };
                final purchaseButton = FlatButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () async {
                    setState(() {
                      loading = true;
                    });
                    try {
                      await Adapty.makePurchase(product);
                      // res.
                    } on AdaptyError catch (adaptyError) {
                      if (adaptyError.adaptyCode != AdaptyErrorCode.paymentCancelled) {
                        AdaptyErrorDialog.showAdaptyErrorDialog(context, adaptyError);
                      }
                    } catch (e) {
                      print('#MakePurchase# ${e.toString()}');
                    }
                    setState(() {
                      loading = false;
                    });
                  },
                  child: Text('Make Purchase'),
                );
                return DetailsContainer(
                  details: details,
                  bottomWidget: purchaseButton,
                  detailPages: detailPages,
                );
              },
              itemCount: widget.products.length,
            ),
    );
  }
}
