import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:ur_tes/presentation/screen/product_order.dart';
import 'package:ur_tes/util/functions.dart';
import 'package:ur_tes/values/colors.dart';

class ProductDetail extends StatefulWidget {
  final item;
  ProductDetail(this.item);
  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _current = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Wrap(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 5,
                  width: 25,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.all(Radius.circular(24.0)),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              _slideshow(),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.item.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                widget.item.description,
                style: Theme.of(context).textTheme.bodyText2,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                formatCurrency(
                  int.parse(widget.item.price),
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(fontSize: 20),
              ),
              SizedBox(
                height: 20,
              ),
              _btnAdd()
            ],
          )
        ],
      ),
    );
  }

  _slideshow() {
    final List<String> imgList = widget.item.images;
    return Column(children: [
      CarouselSlider(
        items: imgList
            .map((item) => Container(
                  child: Center(
                      child:
                          Image.network(item, fit: BoxFit.cover, width: 1000)),
                ))
            .toList(),
        options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            }),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: imgList.map((url) {
          int index = imgList.indexOf(url);
          return Container(
            width: 8.0,
            height: 8.0,
            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _current == index
                  ? Color.fromRGBO(0, 0, 0, 0.9)
                  : Color.fromRGBO(0, 0, 0, 0.4),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _btnAdd() {
    // ignore: deprecated_member_use
    return FlatButton(
      minWidth: MediaQuery.of(context).size.width,
      height: 40,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.all(5),
      textColor: Colors.white,
      color: MyColors.indigo,
      onPressed: () {
        if (widget.item.variantGroups.length == 0) {
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
              behavior: SnackBarBehavior.floating,
              content: new Text("Tidak ada variant")));
        } else {
          Get.to(ProductOrder(widget.item));
        }
      },
      child: Text(
        "Tambah Pesanan",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
