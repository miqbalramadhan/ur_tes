import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:ur_tes/model/cart_map.dart';
import 'package:ur_tes/presentation/component/image_url.dart';
import 'package:ur_tes/presentation/component/not_found.dart';
import 'package:ur_tes/presentation/component/shimmer_loading_component.dart';
import 'package:ur_tes/presentation/component/style.dart';
import 'package:ur_tes/presentation/screen/product_detail.dart';
import 'package:ur_tes/presentation/screen/product_order.dart';
import 'package:ur_tes/provider/cart_provider.dart';
import 'package:ur_tes/repository/product_client.dart';
import 'package:ur_tes/util/functions.dart';
import 'package:ur_tes/values/colors.dart';

class ProductList extends StatefulWidget {
  ProductList();
  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  var _productClient = new ProductClient();
  List _responseListData = [], _listData, _listFilter = [];
  bool _shimmerActive = false, _backTop = false;
  String _sortBy = "defaults";
  Future<void> getProduct() async {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _productClient.getAll(context).then((_response) {
        _listData = [];
        if (_response.status == 200)
          // for (var item in _response.products) {
          //   _listData.add(item);
          // }
          _responseListData = _response.products;
        else
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
              behavior: SnackBarBehavior.floating,
              content: new Text(_response.msg)));
      }).catchError((ex) {
        print(ex.toString());
      }).whenComplete(() {
        setState(() {
          _listData = [];
          _setFilter();
          _listDataSummary(_responseListData);
        });
      });
    });
  }

  Future<Null> refreshData() async {
    getProduct();
  }
  void _listDataSummary(_list) {
    for (var item in _list) {
      _listData.add(item);
      var containType = _listFilter.indexWhere((element) => element['name'] == item.cName);
      if (containType.isNegative)
        _listFilter.add({
          'id': item.cName.toString().toLowerCase(),
          'name': item.cName,
        });
    }
  }
  void _setFilter(){
    _listFilter = [];
    _listFilter.add({'id' : 'defaults', 'name': "Semua",});
  }
  void _setActiveFilter() {
    switch (_sortBy) {
      case 'defaults':
        refreshData();
        break;
      default:
        _listData = [];
        for (var item in _responseListData) {
          if (_sortBy == item.cName.toString().toLowerCase()) {
            _listData.add(item);
          }
        }
        setState(() => _listData);
        break;
    }
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
      body: Column(
        children: [
          _header(),
          Expanded(
            child: _body(),
          ),
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
  Widget _header() {
    if (_listFilter.length == 0) {
      return Container();
    } else {
      return Container(
          margin: EdgeInsets.fromLTRB(15, 10, 0, 10),
          width: double.infinity,
          height: 25,
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    scrollDirection: Axis.horizontal,
                    itemCount: _listFilter.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        margin: EdgeInsets.only(right:10),
                        // ignore: deprecated_member_use
                        child: FlatButton(
                            minWidth: 75,
                            color: _sortBy == _listFilter[index]['id'] ? MyColors.indigo[100] : MyColors.black[100],
                            textColor: _sortBy == _listFilter[index]['id'] ? MyColors.indigo : MyColors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onPressed: (){
                              if(_sortBy == _listFilter[index]['id']){
                                _sortBy = "defaults";
                              } else {
                                _sortBy = _listFilter[index]['id'];
                              }
                              _setActiveFilter();
                            },
                            child: Text(_listFilter[index]['name'])
                        ),
                      );
                    }
                ),
              ),
            ],
          )
      );
    }
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
          String _urlImage = _listData[index].images[0] != null
              ? _listData[index].images[0]
              : "https://www.thermaxglobal.com/wp-content/uploads/2020/05/image-not-found.jpg";
          return Column(
            children: [
              Container(
                margin: EdgeInsets.only(left: 15, right: 15, bottom: 10),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.0),
                          topRight: Radius.circular(10.0),
                        ),
                      ),
                      builder: (BuildContext _) {
                        return ProductDetail(_listData[index]);
                      },
                      isScrollControlled: true,
                    );
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
                                    _listData[index].description,
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    formatCurrency(
                                      int.parse(_listData[index].price),
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
                                _btnAdd(_listData[index])
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
  Widget _btnAdd(item) {
    // ignore: deprecated_member_use
    return FlatButton(
      minWidth: 65,
      height: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(5),
      textColor: Colors.white,
      color: MyColors.indigo,
      onPressed: () {
        if(item.variantGroups.length == 0){
          Provider.of<CartProvider>(context, listen: false).addCart(CartMap(
           id: item.id,
           name: item.name,
           image: item.images[0],
           totalPrice: item.price,
          ));
          setState(() => null);
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
              behavior: SnackBarBehavior.floating,
              content:
              new Text("Berhasil menambahkan ke keranjang")));
        } else {
          Get.to(ProductOrder(item));
        }
      },
      child: Text(
        "Tambah",
        style: TextStyle(fontWeight: FontWeight.bold,fontSize: 11),
      ),
    );
  }
}
