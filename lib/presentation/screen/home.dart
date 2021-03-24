import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ur_tes/presentation/screen/product_list.dart';
import 'package:ur_tes/provider/cart_provider.dart';
import 'package:ur_tes/values/colors.dart';

class Home extends StatefulWidget {
  static const routeName = "/home";
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  DateTime currentBackPressTime;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: MyColors.softGray,
          title: Text("UR Tes"),
          actions: [
            Consumer<CartProvider>(
              builder: (context, provider, child) {
                return provider.cartCounter();
              },
            )
          ],
        ),
        key: _scaffoldKey,
        backgroundColor: MyColors.black[100],
        body: Builder(
          builder: (context) {
            return WillPopScope(
              onWillPop: () => onWillPop(context),
              child: ProductList(),
            );
          },
        ));
  }

  Future<bool> onWillPop(BuildContext context) {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
          behavior: SnackBarBehavior.floating,
          content:
              new Text("Tekan tombol kembali 1x lagi untuk keluar aplikasi")));
      return Future.value(false);
    }
    return Future.value(true);
  }
}
