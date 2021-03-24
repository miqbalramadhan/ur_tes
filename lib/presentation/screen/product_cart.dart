import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:ur_tes/presentation/component/image_url.dart';
import 'package:ur_tes/presentation/component/not_found.dart';
import 'package:ur_tes/presentation/component/shimmer_loading_component.dart';
import 'package:ur_tes/presentation/component/style.dart';
import 'package:ur_tes/provider/cart_provider.dart';
import 'package:ur_tes/util/functions.dart';
import 'package:ur_tes/values/colors.dart';

class ProductCart extends StatefulWidget {
  ProductCart();
  @override
  _ProductCartState createState() => _ProductCartState();
}

class _ProductCartState extends State<ProductCart> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  List _listData;
  bool _shimmerActive = false, _backTop = false;
  Future<void> getProduct() async {
    _listData = Provider.of<CartProvider>(context, listen: false).cartData();
  }
  Future<Null> refreshData() async {
    getProduct();
  }
  @override
  void initState() {
    super.initState();
    refreshData();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_backTop == false && _listData.length > 5) {
          setState(() {
            _backTop = true;
          });
        }
      } else {
        if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (_backTop == true) {
            setState(() {
              _backTop = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: MyColors.softGray,
        title: Text("Keranjang"),
      ),
      body: Column(
        children: [
          Expanded(
            child: _body(),
          ),
          _btnCheckout(),
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _backTop ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: FloatingActionButton(
            backgroundColor: Colors.indigo,
            child: Icon(
              Icons.keyboard_arrow_up,
              color: Colors.white,
            ),
            onPressed: () {
              _scrollController
                  .animateTo(
                0.0,
                curve: Curves.easeOut,
                duration: const Duration(milliseconds: 500),
              )
                  .whenComplete(() {
                setState(() {
                  _backTop = false;
                });
              });
            }),
      ),
    );
  }
  Widget _body() {
    return RefreshIndicator(
      onRefresh: refreshData,
      child: _content(_listData),
    );
  }

  Widget _content(_listData) {
    if (_listData == null) {
      return listProductShimmer(total: 10);
    } else if (_listData.length == 0) {
      return NotFound(
        title: "Opps...",
        description: "Product Not Found",
        imageLocal: "assets/image/illustration/order_not_found.png",
        height: 450,
        scroll: true,
      );
    } else {
      return ListView.builder(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        controller: _scrollController,
        itemCount: _listData.length,
        itemBuilder: (BuildContext context, int index) {
          String _urlImage = _listData[index].image != null
              ? _listData[index].image
              : "https://www.thermaxglobal.com/wp-content/uploads/2020/05/image-not-found.jpg";
          return Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                child: InkWell(
                  onTap: () {
                  },
                  child: Ink(
                    padding: EdgeInsets.all(10),
                    decoration: boxCard,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _listData[index].name,
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    formatCurrency(
                                      int.parse(_listData[index].totalPrice),
                                    ),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  )
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                ImageUrl(url: _urlImage, width: 50, height: 50),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              (_shimmerActive && index == (_listData.length - 1))
                  ? listProductShimmer(total: 5, loadmore: true)
                  : Container(),
            ],
          );
        },
      );
    }
  }
  Widget _btnCheckout() {
    // ignore: deprecated_member_use
    return Container(
      padding: EdgeInsets.all(10),
      // ignore: deprecated_member_use
      child: FlatButton(
        minWidth: MediaQuery.of(context).size.width,
        height: 50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: EdgeInsets.all(5),
        textColor: Colors.white,
        color: MyColors.indigo,
        onPressed: () {

        },
        child: Text(
          "Checkout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
