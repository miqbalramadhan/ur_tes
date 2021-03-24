import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ur_tes/model/cart_map.dart';
import 'package:ur_tes/presentation/component/style.dart';
import 'package:ur_tes/provider/cart_provider.dart';
import 'package:ur_tes/util/functions.dart';
import 'package:ur_tes/values/colors.dart';

class ProductOrder extends StatefulWidget {
  final item;
  ProductOrder(this.item);
  @override
  _ProductOrderState createState() => _ProductOrderState();
}

class _ProductOrderState extends State<ProductOrder> {
  bool _validationChecked = false;
  String _validationMessage = "";
  String _totalPrice = "0", _colorPrice = "0", _sizePrice = "0", _variantColorID = "0", _variantSizeID = "0", _isColorRequire = "0", _isSizeRequire = "0";
  int _totalPriceFix;
  setTotalPrice(){
    _totalPriceFix = int.parse(widget.item.price) + int.parse(_colorPrice) + int.parse(_sizePrice);
    _totalPrice = formatCurrency(_totalPriceFix,
    );
    setState(()=> _totalPrice);
  }
  @override
  void initState() {
    super.initState();
    _totalPrice = formatCurrency(
      int.parse(widget.item.price),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.softGray,
      appBar: AppBar(
        backgroundColor: MyColors.softGray,
        leading: IconButton(
          splashRadius: 20,
          icon: Icon(Icons.arrow_back, color: MyColors.indigo),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        titleSpacing: 0,
        title: Text("Custom Pesanan"),
        elevation: 1,
      ),
      body: Column(
      children: [
          Expanded(
            child: _body(),
          ),
          _bottom(),
        ],
      )
    );
  }
  Widget _body(){
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.name,style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 20),),
                SizedBox(height: 10,),
                Text(
                  formatCurrency(
                    int.parse(widget.item.price),
                  ),
                  style:
                  Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
          _variantGroup(),
          SizedBox(height: 20,),
        ],
      ),
    );
  }
  Widget _bottom(){
    return Container(
      padding: EdgeInsets.all(10),
      child: _btnAdd(),
    );
  }
  Widget _variantGroup(){
    if(widget.item.variantGroups.length == 0){
      return Container();
    }
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.item.variantGroups.length,
        itemBuilder: (BuildContext context, int index) {
          if(widget.item.variantGroups[index].id == "1"){
            _isColorRequire = widget.item.variantGroups[index].isRequired;
          } else if(widget.item.variantGroups[index].id == "2") {
            _isSizeRequire = widget.item.variantGroups[index].isRequired;
          }
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(widget.item.variantGroups[index].name, style: Theme.of(context).textTheme.bodyText1,),
                ),
                _variantItem(widget.item.variantGroups[index])
              ],
            ),
          );
        }
    );
  }
  Widget _variantItem(_item){
    if(_item.variants.length == 0){
      return Container();
    }
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: _item.variants.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              if(_item.id == "1"){
                _variantColorID = _item.variants[index].id;
                _colorPrice = _item.variants[index].price;
              } else {
                _variantSizeID = _item.variants[index].id;
                _sizePrice = _item.variants[index].price;
              }
              setTotalPrice();
            },
            child: Ink(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              decoration: boxCard,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_item.variants[index].name, style: Theme.of(context).textTheme.bodyText1,),
                  Row(
                    children: [
                      Text("+ ${formatCurrency(
                        int.parse(_item.variants[index].price),
                      )}", style: Theme.of(context).textTheme.bodyText1,),
                      _checkedVariant(type:_item.id,id:_item.variants[index].id,price:_item.variants[index].price),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
  Widget _checkedVariant({type,id,price}){
    bool _checked = false;
    if(type == "1" && id == _variantColorID){
      _checked = true;
    }
    if(type == "2" && id == _variantSizeID){
      _checked = true;
    }
    return Container(
      height: 50,
      width: 50,
      child: _checked == true ? Icon(Icons.check_box,color: MyColors.indigo,) : Icon(Icons.check_box_outline_blank_sharp),
    );
  }
  validationChecked(){
    _validationChecked = false;
    if(_isColorRequire == "1" && _variantColorID == "0"){
      _validationChecked = true;
      _validationMessage = "Varian warna tidak boleh kosong";
    } else if(_isSizeRequire == "1" && _variantSizeID == "0"){
      _validationChecked = true;
      _validationMessage = "Varian size tidak boleh kosong";
    }
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
        validationChecked();
        if(_validationChecked){
          ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
              behavior: SnackBarBehavior.floating,
              content:
              new Text(_validationMessage)));
        } else {
          Provider.of<CartProvider>(context, listen: false).addCart(CartMap(
            id: widget.item.id,
            name: widget.item.name,
            image: widget.item.images[0],
            totalPrice: _totalPriceFix.toString(),
          ));
          Navigator.pop(context);
        }
      },
      child: Text(
        "Tambah Pesanan - $_totalPrice",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}