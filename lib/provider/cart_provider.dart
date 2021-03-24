import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:ur_tes/presentation/screen/product_cart.dart';

class CartProvider extends ChangeNotifier {
  List _listCart = [];
  int _counterCart = 0;
  addCart(item) {
    _listCart.add(item);
    _counterCart = _listCart.length;
    notifyListeners();
  }

  cartData() {
    return _listCart;
  }

  Widget cartCounter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Stack(
            children: <Widget>[
              IconButton(
                  splashRadius: 25,
                  icon: Icon(
                    Icons.shopping_cart,
                    color: Colors.indigo,
                  ),
                  onPressed: () {
                    Get.to(ProductCart());
                  }),
              _counterCart > 0
                  ? new Positioned(
                      right: 11,
                      top: 11,
                      child: new Container(
                        padding: EdgeInsets.all(2),
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$_counterCart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : new Container()
            ],
          ),
        ],
      ),
    );
  }
}
