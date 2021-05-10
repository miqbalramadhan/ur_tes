import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutterrajaderekcustomer/models/place.dart';
import 'package:flutterrajaderekcustomer/services/backend_service.dart';
import 'package:flutterrajaderekcustomer/services/navigation_service.dart';
import 'package:flutterrajaderekcustomer/ui/form_kendaran_screen.dart';
import 'package:flutterrajaderekcustomer/ui/transaction_derek_screen.dart';
import 'package:flutterrajaderekcustomer/ui/transaction_derek_screen.dart';
import 'package:flutterrajaderekcustomer/ui/transaction_payment_screen.dart';
import 'package:flutterrajaderekcustomer/utilities/styles.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutterrajaderekcustomer/constant/route_names.dart' as routes;

import '../locator.dart';
String DeviceID, FirebaseToken, CompanyID, UserID, Name, TarifID, currentAddressText,currentAddressMainText, currentAddressSecondText,currentAddressLocation, tujuanAddressText,tujuanAddressMainText,tujuanAddressSecondText,tujuanAddressLocation,tujuanCityName;
String PaymentSelectedValue = "Tunai",PaymentSelectedText = "Tunai", ConditionSelectedValue = "mogok", ConditionSelectedText = "Mogok",heading;
String VehicleSelectedValue = "KendaraanForm", VehicleSelectedText = "Form Kendaraan";
String VendorImage,VendorName,VendorPhone,VehicleName,VehicleNo,BrandName,TypeName,Color,HargaTarif, PaymentType,PaymentTypeName,PaymentStatusCode, Review;
String PaymentTypeAdd,PaymentTypeNameAdd,PaymentStatusCodeAdd;
bool AdditionalStatus;
var Rating;
double RatingReview = 5;
int currentPage = 0;
int SumHargaTarif = 0;
var listData, pr, TransactionMethod,TransactionProccessNum = 0,DataTujuan, DataJemput, DataTransaction = {},
    UserLocation, DataTarif, ListVehicle, VehicleIDSelected = "0", ListTarif;
var thisContext,callbackTransaction;
var parent;
final NavigationService navigationService = locator<NavigationService>();
final _formKeyVehicle = GlobalKey < FormState > ();
final vehicleNameController = TextEditingController();
final vehicleNoController = TextEditingController();
final brandController = TextEditingController();
final typeController = TextEditingController();
final colorController = TextEditingController();
var validationPost = false, validationPostError,ImageSTNKUrl, ImageIDUrl;
//File image;
var imageSTNK;
var imageID;
String TypeID,BrandID;
Icon PaymentSelectedIcon = Icon(Icons.attach_money);
Icon ConditionSelectedIcon = Icon(Icons.directions_car);
Icon VehicleSelectedIcon = Icon(Icons.subject);
LatLng currentPosition;
List<Place> placesList;
List<LatLng> polylineCoordinates = [];
List<int> tarifValues = [];
Set<Marker> Markers = {};
Set<Polyline> Polylines = {};
PolylinePoints polylinePoints = PolylinePoints();
CameraPosition FirstLocationCamera = CameraPosition(
  target: LatLng(-6.917463899999999, 107.6191228),
  zoom: 11,
);

CleanValue(){
  PaymentSelectedValue = "Tunai";
  PaymentSelectedText = "Tunai";
  ConditionSelectedValue = "mogok";
  ConditionSelectedText = "Mogok";
  VehicleSelectedValue = "KendaraanForm";
  VehicleSelectedText = "Form Kendaraan";
}

List < Widget > buildPageIndicator(ListData) {
  List < Widget > list = [];
  for (int i = 0; i < ListData.length; i++) {
    list.add(i == currentPage ? indicator(true) : indicator(false));
  }
  return list;
}
Widget indicator(bool isActive) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 150),
    margin: EdgeInsets.symmetric(horizontal: 8.0),
    height: 10,
    width: isActive ? 10 : 10,
    decoration: BoxDecoration(
      color: isActive ? PrimaryColor : Colors.grey,
      borderRadius: BorderRadius.all(Radius.circular(50)),
    ),
  );
}
Widget IconTF(color,size){
  return Container(
    width: size.toDouble(),
    height: size.toDouble(),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: Border.all(color: Colors.white, width: 3),
    ),
    child: Center(
      child: Icon(
        Icons.location_on,
        color: Colors.white,
        size: size.toDouble() - size.toDouble() / 2.5,
      ),
    ),
  );
}

Widget buildTFJemput(searchJemputController,focusNodeJemput){
  if(TransactionMethod == "emergency" && TransactionProccessNum == 0){
    return InkWell(
      onTap: (){
        TransactionProccessNum = 1;
        parent.callback();
        Future.delayed(const Duration(milliseconds: 500), (){
          FocusScope.of(thisContext).requestFocus(parent.focusNodeJemput);
          parent.focusNodeJemput.requestFocus();
        });
      },
      child: TextField(
        enabled: false,
        keyboardType: TextInputType.text,
        style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: IconTF(PrimaryColor,28),
          hintText: 'Lokasi anda sekarang',
        ),
      ),
    );
  } else if(TransactionMethod == "emergency" || TransactionProccessNum == 1 || TransactionProccessNum == 3){
    return TextField(
      controller: searchJemputController,
      focusNode: focusNodeJemput,
      keyboardType: TextInputType.text,
      style: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        icon: IconTF(PrimaryColor,28),
        hintText: 'Lokasi anda sekarang',
      ),
    );
  } else {
    return VisibleText();
  }
}
Widget buildTFTujuan(searchTujuanController,focusNodeTujuan){
  print(TransactionMethod);
  if(TransactionMethod == "derek" || TransactionMethod == "paket"){
    if(TransactionProccessNum == 0){
      return InkWell(
        onTap: (){
          TransactionProccessNum = 1;
          parent.callback();
          Future.delayed(const Duration(milliseconds: 500), (){
            FocusScope.of(thisContext).requestFocus(parent.focusNodeTujuan);
            parent.focusNodeTujuan.requestFocus();
          });
        },
        child: TextField(
          enabled: false,
          keyboardType: TextInputType.text,
          style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 14
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            icon: IconTF(Colors.green,28),
            hintText: 'Cari lokasi tujuan',
          ),
        ),
      );
    } else {
      return TextField(
        controller: searchTujuanController,
        focusNode: focusNodeTujuan,
        keyboardType: TextInputType.text,
        style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: IconTF(Colors.green,28),
          hintText: 'Cari lokasi tujuan',
        ),
      );
    }
  } else {
    return VisibleText();
  }
}
Widget buildTFCatatan(catatanController){
  return Container(
    padding: EdgeInsets.only(left: 8),
    decoration: BoxDecoration(
      color:  Colors.grey.withOpacity(0.3),
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      maxLength: 100,
      controller: catatanController,
      keyboardType: TextInputType.text,
      style: TextStyle(
          fontFamily: 'OpenSans',
          fontSize: 14
      ),
      decoration: InputDecoration(
        counterStyle: TextStyle(height: double.minPositive,),
        counterText: "",
        border: InputBorder.none,
        icon: Icon(Icons.assignment),
        hintText: 'Masukan Catatn Tambahan',
      ),
    ),
  );
}
Widget buildOPVehicleCondition(){
  return Container(
    height: 40,
    margin: EdgeInsets.only(bottom: 12),
    child: ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Row(
        children: [
          ConditionSelectedIcon,
          SizedBox(width: 15,),
          Text(ConditionSelectedText,style: TextStyle(fontWeight: FontWeight.bold),)
        ],
      ),
      trailing: Icon(Icons.more_vert),
      onTap: (){
        showModalCondition();
      },
    ),
  );
}
Widget buildOPVehicleSelect(){
  if(TransactionMethod == 'derek' || TransactionMethod == 'emergency'){
    return Container(
      height: 40,
      margin: EdgeInsets.only(bottom: 16,left: 12,right: 6),
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Row(
          children: [
            VehicleSelectedIcon,
            SizedBox(width: 15,),
            Text(VehicleSelectedText,style: TextStyle(fontWeight: FontWeight.bold),)
          ],
        ),
        trailing: Icon(Icons.more_vert),
        onTap: (){
          showModalVehicle();
        },
      ),
    );
  } else {
    return VisibleText();
  }
}
Widget buildTFVehicleCondition(vehicleConditionRemarkController){
  if(ConditionSelectedValue == "lain-lain"){
    return Container(
      padding: EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color:  Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        maxLength: 100,
        controller: vehicleConditionRemarkController,
        keyboardType: TextInputType.text,
        style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14
        ),
        decoration: InputDecoration(
          counterStyle: TextStyle(height: double.minPositive,),
          counterText: "",
          border: InputBorder.none,
          icon: Icon(Icons.assignment),
          hintText: 'Masukan kondisi kendaraan',
        ),
      ),
    );
  } else {
    return VisibleText();
  }
}
Widget DivVehicle(items) {
  return Card(
    shape: VehicleIDSelected == items["VehicleID"]
        ? new RoundedRectangleBorder(
        side: new BorderSide(color: PrimaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(4.0))
        : new RoundedRectangleBorder(
        side: new BorderSide(color: Colors.white, width: 2.0),
        borderRadius: BorderRadius.circular(4.0)),
    margin: EdgeInsets.all(16),
    child: ListTile(
      contentPadding: EdgeInsets.all(8),
      onLongPress: () {
        Navigator.push(thisContext,
            new MaterialPageRoute(builder: (context) => FormKendaraanScreen("edit", items))
        );
      },
      onTap: (){
        VehicleIDSelected = items["VehicleID"];
        print(VehicleIDSelected);
        print(ListVehicle);
        parent.callback();
      },
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: < Widget > [
          Text("${items['Name']} ", style: TextStyle(color: PrimaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
          Text("${items['VehicleNo']}",style: TextStyle(fontWeight: FontWeight.bold),),
          Text("${items['BrandName']} ${items['TypeName']}"),
          Text("${items['Color']}"),
        ],
      ),
    ),
  );
}
Widget buildTFProductType(productTypeController){
  if(TransactionMethod == "paket"){
    return Container(
      margin: EdgeInsets.only(top:16),
      padding: EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color:  Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        maxLength: 100,
        controller: productTypeController,
        keyboardType: TextInputType.text,
        style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14
        ),
        decoration: InputDecoration(
          counterStyle: TextStyle(height: double.minPositive,),
          counterText: "",
          border: InputBorder.none,
          icon: Icon(Icons.assignment),
          hintText: 'Masukan jenis barang',
        ),
      ),
    );
  } else {
    return VisibleText();
  }
}
GetLatLngFromAddress(Address) async {
  try {
    List<Placemark> placemark = await Geolocator().placemarkFromAddress(Address);
    Placemark place   = placemark[0];
    double latitude   = place.position.latitude;
    double longitude  = place.position.longitude;
    return {
      'latitude' : latitude,
      'longitude' : longitude
    };
  } catch (e) {
    print(e);
  }
}

setHeightMainContainer(context,TransactionProccessNum,TransactionMethod,DataTarif){
  print('set height : $TransactionProccessNum');
  var height;
  if(TransactionProccessNum == 0){
    height = MediaQuery.of(context).size.height / 4;
  } else if(TransactionProccessNum == 1 || TransactionProccessNum == 3){
    height = MediaQuery.of(context).size.height / 1;
  } else if(TransactionProccessNum == 2 || TransactionProccessNum == 4){
    height = MediaQuery.of(context).size.height / 2.6;
  } else if(TransactionProccessNum == 5 || TransactionProccessNum == 6 && TransactionMethod == "emergency"){
    height = MediaQuery.of(context).size.height /1;
  } else if(TransactionProccessNum == 6){
    if(DataTarif == null){
      height = MediaQuery.of(context).size.height / 2.6;
    } else if(TransactionMethod == "paket"){
      height = MediaQuery.of(context).size.height / 2.5;
    }  else {
      height = MediaQuery.of(context).size.height / 2;
    }
  } else if(TransactionProccessNum == 7 && TransactionMethod == "emergency"){
      height = MediaQuery.of(context).size.height / 2;
  } else {
    height = MediaQuery.of(context).size.height / 4;
  }
  return height;
}
setHeightMap(context,TransactionProccessNum,TransactionMethod){
  var height;
  if(TransactionProccessNum == 3){
    height = MediaQuery.of(context).size.height / 2;
  } else if(TransactionProccessNum == 4){
    height = MediaQuery.of(context).size.height / 1.6;
  } else if(TransactionProccessNum == 5){
    height = MediaQuery.of(context).size.height / 2.9;
  } else if(TransactionProccessNum == 6){
    if(DataTarif == null){
      height = MediaQuery.of(context).size.height / 1.6;
    } else if(TransactionMethod == "paket"){
      height = MediaQuery.of(context).size.height / 1.63;
    } else {
      height = (MediaQuery.of(context).size.height / 2)  + 10;
    }
  }  else {
    height = MediaQuery.of(context).size.height / 1.32;
  }
  return height;
}

Widget ModalSetImage(method, title) {
  showDialog(
    context: thisContext,
    builder: (context) => new AlertDialog(
      title: new Text(title),
      content: Wrap(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text("Pilih Dari Galeri"),
            onTap: () {
              getImageGallery(method);
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.all(0),
            title: Text("Ambil Gambar"),
            onTap: () {
              getImageCamera(method);
            },
          )
        ],
      ),
    ),
  );
}
Future < void > getImageGallery(method) async {
  print(method);
  var image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 480,
      maxHeight: 480);
  imageChoosed(method,image);
}
Future < void > getImageCamera(method) async {
  var image = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 480,
      maxHeight: 480);
  imageChoosed(method,image);
}
imageChoosed(method,image){
  if(image != null){
    if (method == "ImageSTNK") {
      imageSTNK = image;
      imageSTNKDiv();
    } else if (method == "ImageID") {
      imageID = image;
      imageIDDiv();
    }
  }
  Navigator.of(thisContext, rootNavigator: true).pop('dialog');
  parent.callback();
}
imageSTNKDiv() {
  var ImageSet;
  if (imageSTNK != null) {
    ImageSet = imageSTNK;
    return FileImage(imageSTNK);
  } else {
    ImageSet = ImageSTNKUrl;
    return ImageSet == null ? imageAdd : CachedNetworkImageProvider(ImageSTNKUrl);
  }
}
imageIDDiv() {
  var ImageSet;
  if (imageID != null) {
    ImageSet = imageID;
    return FileImage(imageID);
  } else {
    ImageSet = ImageIDUrl;
    return ImageSet == null ? imageAdd : CachedNetworkImageProvider(ImageIDUrl);
  }
}
Widget btnAddImage(Method, Title) {
  return Container(
    margin: EdgeInsets.all(10),
    child: Column(
      children: [
        FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side: BorderSide(color: Colors.grey)),
            onPressed: () {
              ModalSetImage(Method, "Pilih ${Title}");
            },
            padding: EdgeInsets.all(5),
            child: Image(
              image: Method == "ImageSTNK" ? imageSTNKDiv() : imageIDDiv(),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            )
        ),
        SizedBox(height: 10, ),
        Text(Title,style: TextStyle(fontSize: 10),)
      ],
    ),
  );
}
Widget formVehicle(context,formKeyVehicle) {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: < Widget > [
        Form(
            key: formKeyVehicle,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    btnAddImage("ImageSTNK", "Foto STNK / Mobil"),
                    btnAddImage("ImageID", "Foto SIM / KTP"),
                  ],
                ),
                SizedBox(height:10),
//                ListRowVehicle("Nama", 'name'),
                ListRowVehicle("Nomor Polisi", 'vehicleno'),
                ListRowVehicle("Merk", 'brand'),
                ListRowVehicle("Tipe", 'type'),
                ListRowVehicle("Warna", 'color'),
              ],
            )
        )
      ],
    ),
    decoration: BoxDecoration(
      color: Theme.of(context).canvasColor,
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
      ),
    ),
  );
}
Widget ListRowVehicle(title, typeText) {
  title = title ?? "-";
  var controllerText;
  var textInputFormat;
  var textInputType;
  if (typeText == "name") {
    controllerText = vehicleNameController;
    textInputFormat = 'text';
  } else if (typeText == "vehicleno") {
    controllerText = vehicleNoController;
    textInputFormat = 'text';
  } else if (typeText == "brand") {
    controllerText = brandController;
    textInputFormat = 'text';
  } else if (typeText == "type") {
    controllerText = typeController;
    textInputFormat = 'text';
  } else if (typeText == "color") {
    controllerText = colorController;
    textInputFormat = 'text';
  }
  if (textInputFormat == "email") {
    textInputType = TextInputType.emailAddress;
  } else if (textInputFormat == "number") {
    textInputType = TextInputType.number;
  } else if (textInputFormat == "textarea") {
    textInputType = TextInputType.multiline;
  } else {
    textInputType = TextInputType.text;
  }
  return Card(
    elevation: 0.5,
    margin: EdgeInsets.only(bottom: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
    ),
    child: Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.only(top: 10, bottom: 5, right: 15, left: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 0),
            child: Text(title, style: formLabel),
          ),
          ListRowVehicleItem(title, typeText, textInputType, controllerText, textInputFormat),
        ],
      ),
    ),
  );
}
Widget ListRowVehicleItem(title, typeText, textInputType, controllerText, textInputFormat) {
  if (typeText == "brand" || typeText == "type") {
    return TypeAheadField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controllerText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Masukan ${title}',
        ),
      ),
      suggestionsCallback: (pattern) async {
        return await AutocompleteBrand.getSuggestions(typeText, pattern, BrandID);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion['Name']),
        );
      },
      onSuggestionSelected: (suggestion) {
        if (typeText == "brand") {
          BrandID = suggestion["ID"];
        } else {
          TypeID = suggestion["ID"];
        }
        controllerText.text = suggestion["Name"];
      },
    );
  } else {
    return TextFormField(
        enabled: typeText == "brand" || typeText == "type" ? false : true,
        keyboardType: textInputType,
//        inputFormatters: < TextInputFormatter > [
//          //WhitelistingTextInputFormatter.digitsOnly
//        ],
        maxLines: textInputFormat == "textarea" ? 3 : 1,
        maxLength: textInputFormat == "textarea" ? 150 : 30,
        controller: controllerText,
        validator: (value) {
          if (validationPost){
            if (validationPostError != null) {
              print(validationPostError);
              int index = 0;
              var item_name;
              for (var item in validationPostError["error_string"]) {
                item_name = validationPostError["inputerror"][index];
                if (item_name.toLowerCase() == typeText) {
                  return capitalize(item);
                }
                index += 1;
              }
            }
          }
          if (typeText == "color") {

          } else {
            if (value.isEmpty) {
              return capitalize('${title} tidak boleh kosong');
            }
          }
          return null;
        },
        decoration: InputDecoration(
            counter: SizedBox.shrink(),
            border: InputBorder.none,
            contentPadding: EdgeInsets.only(top: 14),
            hintText: 'Masukan ${title}',
            suffixIcon: Padding(
                padding: EdgeInsets.only(top: 0),
                child: typeText == "brand" || typeText == "type" ?
                IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () {

                  },
                ) : Text("")
            )
        )
    );
  }
}
Widget VehicleBox(VehicleName,VehicleNo,BrandName,TypeName,Color){
    return Card(
      margin: EdgeInsets.all(16),
      child: ListTile(
        contentPadding: EdgeInsets.all(8),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: < Widget > [
//            Text("${VehicleName}", style: TextStyle(color: PrimaryColor, fontWeight: FontWeight.bold, fontSize: 15)),
            Text("${VehicleNo}",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.black),),
            Text("${BrandName} ${TypeName}"),
            Text("${Color}"),
          ],
        ),
      ),
    );
}
showModalPayment(){
  showModalBottomSheet(
      context: thisContext,
      builder: (context) {
        return Container(
          height: double.infinity,
//            color: Color(0xFF737373),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: IconSlideUp,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                  margin: EdgeInsets.only(top:10,bottom: 10),
                  child: Text("Pilih metode pembayaran",style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5,right: 5),
                  padding: EdgeInsets.all(5),
                  decoration: PaymentSelectedValue == "Tunai" ? BoxSelected(Colors.green) : BoxUnSelected(),
                  child: ListTile(
                    title: Text("Tunai",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                    subtitle: Text("Siapkan uang pas agar tidak repot menunggu kembalian"),
                    leading: Icon(Icons.attach_money,color: Colors.green,),
                    onTap: (){
                        PaymentSelectedValue = "Tunai";
                        PaymentSelectedText  = "Tunai";
                        PaymentSelectedIcon  = Icon(Icons.attach_money);
                        Navigator.pop(context);
                        parent.callback();
                    },
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: 5,right: 5),
                    padding: EdgeInsets.all(5),
                    decoration: PaymentSelectedValue == "Lainnya" ? BoxSelected(Colors.blueAccent) : BoxUnSelected(),
                    child:ListTile(
                      title: Text("Pembayaran Online",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      subtitle:Text("Transfer ATM, Mobile Banking dan lain-lain"),
                      leading: Icon(Icons.payment,color: Colors.blueAccent,),
                      onTap: (){
                          PaymentSelectedValue  = "Lainnya";
                          PaymentSelectedText   = "Pembayaran Online";
                          PaymentSelectedIcon   = Icon(Icons.payment);
                          Navigator.pop(context);
                          parent.callback();
                      },
                    )
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
          ),
        );
      });
}
showModalCondition(){
  showModalBottomSheet(
      context: thisContext,
      builder: (context) {
        return Container(
          height: double.infinity,
//            color: Color(0xFF737373),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: IconSlideUp,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                  margin: EdgeInsets.only(top:10,bottom: 10),
                  child: Text("Pilih Kondisi Kendaraan",style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5,right: 5),
                  padding: EdgeInsets.all(5),
                  decoration: ConditionSelectedValue == "mogok" ? BoxSelected(Colors.red) : BoxUnSelected(),
                  child: ListTile(
                    title: Text("Mogok",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                    leading: Icon(Icons.directions_car,color: Colors.red,),
                    onTap: (){
                        ConditionSelectedValue = "mogok";
                        ConditionSelectedText  = "Mogok";
                        ConditionSelectedIcon  = Icon(Icons.directions_car,);
                        Navigator.pop(context);
                        parent.callback();
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5,right: 5),
                  padding: EdgeInsets.all(5),
                  decoration: ConditionSelectedValue == "kecelakaan" ? BoxSelected(Colors.green) : BoxUnSelected(),
                  child: ListTile(
                    title: Text("Kecelakaan",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                    leading: Icon(Icons.local_hospital,color:Colors.green),
                    onTap: (){
                        ConditionSelectedValue = "kecelakaan";
                        ConditionSelectedText  = "Kecelakaan";
                        ConditionSelectedIcon  = Icon(Icons.local_hospital);
                        Navigator.pop(context);
                        parent.callback();
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5,right: 5),
                  padding: EdgeInsets.all(5),
                  decoration: ConditionSelectedValue == "lain-lain" ? BoxSelected(Colors.blue) : BoxUnSelected(),
                  child: ListTile(
                    title: Text("Lain-lain",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                    leading: Icon(Icons.format_list_bulleted,color:Colors.blue),
                    onTap: (){
                        ConditionSelectedValue = "lain-lain";
                        ConditionSelectedText  = "Lain-lain";
                        ConditionSelectedIcon  = Icon(Icons.format_list_bulleted);
                        Navigator.pop(context);
                        parent.callback();
                    },
                  ),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
          ),
        );
      });
}
showModalVehicle(){
  showModalBottomSheet(
      context: thisContext,
      builder: (context) {
        return Container(
          height: double.infinity,
//            color: Color(0xFF737373),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: IconSlideUp,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
                  margin: EdgeInsets.only(top:10,bottom: 10),
                  child: Text("Pilih Metode Kendaraan",style: TextStyle(fontSize:18,fontWeight: FontWeight.bold),),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5,right: 5),
                  padding: EdgeInsets.all(5),
                  decoration: VehicleSelectedValue == "KendaraanForm" ? BoxSelected(Colors.green) : BoxUnSelected(),
                  child: ListTile(
                    title: Text("Form Kendaraan",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                    subtitle: Text("Form kendaraan, masukan kendaraan baru yang tidak terdaftar di akun anda"),
                    leading: Icon(Icons.subject,color: Colors.green,),
                    onTap: (){
                      VehicleSelectedValue = "KendaraanForm";
                      VehicleSelectedText  = "Form Kendaraan";
                      VehicleSelectedIcon  = Icon(Icons.subject);
                      Navigator.pop(context);
                      parent.callback();
                    },
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(left: 5,right: 5),
                    padding: EdgeInsets.all(5),
                    decoration: VehicleSelectedValue == "KendaraanPribadi" ? BoxSelected(Colors.blueAccent) : BoxUnSelected(),
                    child:ListTile(
                      title: Text("Kendaraan Pribadi",style: TextStyle(fontSize:15,fontWeight: FontWeight.bold),),
                      subtitle:Text("Pilih kendaraan pribadi yang sudah anda daftarkan"),
                      leading: Icon(Icons.directions_car,color: Colors.blueAccent,),
                      onTap: (){
                        VehicleSelectedValue = "KendaraanPribadi";
                        VehicleSelectedText  = "Kendaraan Pribadi";
                        VehicleSelectedIcon  = Icon(Icons.directions_car);
                        Navigator.pop(context);
                        parent.callback();
                      },
                    )
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10),
                topRight: const Radius.circular(10),
              ),
            ),
          ),
        );
      });
}

Widget btnSetJemputLocation() {
  if(TransactionProccessNum == 2 || TransactionProccessNum == 4 || TransactionProccessNum == 5 || TransactionProccessNum == 6 && TransactionMethod == "emergency"){
    return Container(
      margin: EdgeInsets.only(left: 10, right: 10, bottom: 8),
      width: double.infinity,
      child: RaisedButton(
        elevation: 2.0,
        onPressed: () {
          parent.setJemputLocationClick();
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: ColorRed,
        child: Text(
          TransactionProccessNum >= 5 ? 'Selanjutnya' : 'Set Lokasi Jemput',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  } else {
    return VisibleText();
  }
}
Widget btnPesan() {
  if(TransactionProccessNum >= 6){
    if(DataTarif != null){
      if(TransactionMethod == "emergency") {
        // untuk ini di set di transaction emergency
      } else {
        HargaTarif = "Rp.${DataTarif['Price']}";
      }
    }
    return Container(
      margin: EdgeInsets.only(top:8),
      width: double.infinity,
      child: RaisedButton(
        elevation: 2.0,
        onPressed: () {
          parent.setJemputLocationClick();
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: ColorRed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pesan',
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
            Text(
              HargaTarif ?? "",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 1.5,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            )
          ],
        ),
      ),
    );
  } else {
    return VisibleText();
  }
}
Widget btnReview() {
    return Container(
      width: double.infinity,
      child: RaisedButton(
        elevation: 2.0,
        onPressed: () {
          parent.reviewPost();
        },
        padding: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: ColorRed,
        child: Text(
          'Tulis Review Anda',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
}
Widget btnUbahHeaderContent(){
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Container(
          margin: EdgeInsets.only(left: 15),
          child: SizedBox(
            height: 25,
            width: 40,
            child: OutlineButton(
              onPressed: (){
                placesList = [];
                TransactionProccessNum = 1;
                parent.ClearMap();
                parent.callback();
                Future.delayed(const Duration(milliseconds: 500), (){
                  FocusScope.of(thisContext).requestFocus(parent.focusNodeJemput);
                  parent.focusNodeJemput.requestFocus();
                });
              },
              padding: EdgeInsets.all(1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              borderSide: BorderSide(color: PrimaryColor,),
              color: Colors.white,
              child: Text(
                'Ubah',
                style: TextStyle(
                  color: PrimaryColor,
                  fontSize: 10,
                ),
              ),
            ),
          )
      )
    ],
  );
}
Widget btnTambahKendaraan(){
  return Container(
    width: double.infinity,
    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
    child: RaisedButton(
      elevation: 2.0,
      onPressed: () {
        Navigator.push(thisContext,
            new MaterialPageRoute(builder: (context) => FormKendaraanScreen("new",null))
        );
      },
      padding: EdgeInsets.all(15.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.green,
      child: Text(
        'Tambah Kendaraan',
        style: TextStyle(
          color: Colors.white,
          letterSpacing: 1.5,
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
          fontFamily: 'OpenSans',
        ),
      ),
    ),
  );
}
Widget buttonBackContainer(){
  if(TransactionProccessNum == 1 || TransactionProccessNum == 3){
    return IconButton(
      icon: Icon(Icons.close),
      color: Colors.black,
      onPressed: () {
        FocusScope.of(thisContext).requestFocus(FocusNode());
        Future.delayed(const Duration(milliseconds: 300), () {
            TransactionProccessNum = 0;
            parent.ClearAllData("All");
            parent.callback();
        });

      },
    );
  } else if(TransactionProccessNum == 5 || TransactionProccessNum == 6){
    return IconButton(
      icon: Icon(Icons.close),
      color: Colors.black,
      onPressed: () {
        FocusScope.of(thisContext).requestFocus(FocusNode());
        Future.delayed(const Duration(milliseconds: 300), () {
          TransactionProccessNum = TransactionProccessNum - 1;
          parent.callback();
        });
      },
    );
  } else {
    return VisibleText();
  }
}

transactionOrderStatus(Status){
  var boxColor;
  var txtStatus;
  if(Status == "finish"){
    boxColor = Colors.green;
    txtStatus = "Sudah selesai";
  } else if(Status == "proccess"){
    boxColor = Colors.red;
    txtStatus = "Sedang mencari supir";
  } else if(Status == "payment_wait"){
    boxColor = Colors.deepPurple;
    txtStatus = "Menunggu proses pembayaran";
  } else if(Status == "driver_otw"){
    boxColor = Colors.blue;
    txtStatus = "Supir dalam perjalanan";
  } else {
    boxColor = Colors.red;
    txtStatus = "belum mulai";
  }
  return {
    'color' : boxColor,
    'text'  : txtStatus,
  };
}
Widget contentHeader(StatusOrder,WorkType,Tanggal,Code){
  var item_status = transactionOrderStatus(StatusOrder);
  var boxColor = item_status['color'];
  var txtStatus = item_status['text'];
  return Container(
    padding: EdgeInsets.only(left: 16,right: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(capitalize(WorkType),style: TextStyle(fontWeight: FontWeight.bold),),
              Text(txtStatus, style: TextStyle(fontSize: 11,color: boxColor)),
            ],
          ),
        ),
        Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(Tanggal,style: TextStyle(fontSize: 11),),
              SizedBox(height: 6),
              Text("No. Pesanan : ${Code}",style: TextStyle(fontSize: 11),)
            ],
          ),
        )
      ],
    ),
  );
}
Widget addressText(title,text){
  return  Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,style: TextStyle(fontSize: 11.0),),
      AutoSizeText(text ?? "",maxLines: 3,style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}
Widget rowItemTeleponChat(PhoneNumber){
  return Container(
    width: MediaQuery.of(thisContext).size.width,
    decoration: borderBottom,
    child: Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              iconTeleponChat("phone","Telepon",Icons.phone,PhoneNumber),
              iconTeleponChat("chat","Chat",Icons.message,PhoneNumber),
            ],
          ),
        ),
      ],
    ),
  );
}
Widget iconTeleponChat(method,title,icon,value){
  var color = method == "phone" ? Colors.blue : Colors.green;
  return Container(
    padding: EdgeInsets.all(0),
    width: MediaQuery.of(thisContext).size.width / 2,
    child: ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,color: color),
          SizedBox(width: 10,),
          Text(title,style:TextStyle(fontWeight: FontWeight.bold,color: color)),
        ],
      ),
      onTap: (){
        if(method == "phone"){
          CallPhone(value);
        } else {
          ChatWA(value);
        }
      },
    ),
  );
}

CallPhone(PhoneNumber) async {
  var url = "tel:${PhoneNumber}";
  if(PhoneNumber != ""){
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      SnackBar(
        content: Text("No. Telepon supir tidak ada"),
        duration: Duration(seconds: 1),
      );
    }
  } else {
    popUpshow("error",thisContext,"Maaf, nomor telepon supir tidak tersedia");
  }
}
ChatWA(PhoneNumber) async {
  var url = "https://api.whatsapp.com/send?phone=${PhoneNumber}";
  if(PhoneNumber != ""){
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      SnackBar(
        content: Text("No. Telepon supir tidak ada"),
        duration: Duration(seconds: 1),
      );
    }
  } else {
    popUpshow("error",thisContext,"Maaf, nomor telepon supir tidak tersedia");
  }
}
Widget imageSupir(image){
  if(image == null || image == ""){
    return IconCircle(Icons.person_outline,Colors.blueAccent,60);
  } else {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              fit: BoxFit.cover,
              image: image == null ? profileBlank : CachedNetworkImageProvider(image)
          )
      ),
    );
  }
}
Widget rowItemPriceHeader(){
  return Container(
    margin: EdgeInsets.only(top:10),
    padding: EdgeInsets.only(top:10),
    decoration: borderTop,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rowTitle("Detail Pembayaran"),
        Container(
          height: 30,
          padding: EdgeInsets.only(left:16,right:16),
          // padding: EdgeInsets.all(16),
          // decoration: borderBottom,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width:  MediaQuery.of(thisContext).size.width / 2,
                child: AutoSizeText("Methode Pembayaran",maxLines: 1,style: TextStyle(fontSize:11,color:Colors.black)),
              ),
              AutoSizeText("${PaymentTypeName}",maxLines: 1,style: TextStyle(fontSize:11,color:Colors.black))
            ],
          ),
        ),
      ],
    ),
  );
}
Widget rowItemPriceHeaderAdditional(){
  return Container(
    padding: EdgeInsets.only(top:16),
    // decoration: WorkType == "emergency" ? borderTopBottom : borderBottom,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        rowTitle("Detail Biaya Tambahan"),
        Container(
          height: 30,
          padding: EdgeInsets.only(left:16,right:16),
          // padding: EdgeInsets.all(16),
          // decoration: borderBottom,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width:  MediaQuery.of(thisContext).size.width / 2,
                child: AutoSizeText("Methode Pembayaran",maxLines: 1,style: TextStyle(fontSize:11,color:Colors.black)),
              ),
              AutoSizeText("${PaymentTypeNameAdd}",maxLines: 1,style: TextStyle(fontSize:11,color:Colors.black))
            ],
          ),
        ),
      ],
    ),
  );
}
Widget rowItemPaymentGT(Data){
  if(PaymentStatusCode == "200" || PaymentType == "Tunai"){
    return VisibleText();
  } else {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      child: OutlineButton(
        onPressed: (){
          navigationService.navigateTo(routes.TransactionPaymentScreenRoute,arguments: Data);
        },
        padding: EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        borderSide: BorderSide(color: PrimaryColor,),
        color: Colors.white,
        child: Text(
          PaymentStatusCode == "0"  ? 'Pilih Methode Pembayaran Online' : "Lihat Instruksi Pembayaran",
          style: TextStyle(
            color: PrimaryColor,
            letterSpacing: 1.5,
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }
}
Widget rowItemListTarif(ListData){
  int total = ListData != null || ListData != "" ? ListData.length : 0;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        height: (30 * total).toDouble(),
        child: ListView.builder(
            physics : NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(0),
            itemCount: total,
            itemBuilder: (BuildContext context, int index){
              var val = ListData[index];
              String Name = val['Name'];
              String TotalPrice = val['TotalPrice'];
              return Container(
                height: 30,
                padding: EdgeInsets.only(left:16,right:16),
                // padding: EdgeInsets.all(16),
                // decoration: borderBottom,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width:  MediaQuery.of(thisContext).size.width / (3/2),
                      child: AutoSizeText("${Name}",maxLines: 1,style: TextStyle(fontSize:11,color:Colors.black)),
                    ),
                    AutoSizeText("Rp.${TotalPrice}",maxLines: 1,style: TextStyle(fontSize:11,color:Colors.black))
                  ],
                ),
              );
            }
        ),
      )
    ],
  );
}
Widget rowItemPrice(item){
  String EstimationPrice  = item["EstimationPrice"] ?? "";
  String GrandTotalPrice  = item["GrandTotalPrice"] ?? "";
  String Remark           = item["Remark"] ?? "";
  String RemarkDriver     = item["RemarkDriver"] ?? "";
  String RemarkAdditional = item["RemarkAdditional"] ?? "";

  return Container(
    padding: WorkType == "emergency" ? EdgeInsets.only(top:10,bottom:10) : EdgeInsets.only(top:5,bottom:10),
    decoration: WorkType == "emergency" ? borderTopBottom : borderBottom,
    child: Column(
      children: [
        (EstimationPrice != "Rp.0" || EstimationPrice != "Rp.0") ?
        Container(
          // margin: EdgeInsets.only(bottom:10),
          // decoration: borderTopBottom,
          padding: EdgeInsets.only(left: 16,right: 16,bottom:16,top:0),
          child:  Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: MediaQuery.of(thisContext).size.width / (3/2),
                  child: AutoSizeText("$RemarkAdditional",maxLines: 3,style: TextStyle(fontSize:12,color:Colors.black)),
              ),
              Text(EstimationPrice ?? "Rp.0",style: TextStyle(fontSize:12,color:Colors.black)),
            ],
          ),
        ) : VisibleText(),
        Container(
          padding: EdgeInsets.only(left: 16,right: 16),
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Biaya",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold)),
              Text(GrandTotalPrice ?? "Rp.0",style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        (Remark != '') ? SizedBox(height: 10,) : VisibleText(),
        rowItem("Catatan",Remark,true),
        (RemarkDriver != '') ? SizedBox(height: 10,) : VisibleText(),
        rowItemBold("Catatan Supir",RemarkDriver,true),
      ],
    ),
  );
}
Widget rowTitle(text){
  return Container(
    padding: EdgeInsets.only(left: 16),
    margin: EdgeInsets.only(bottom: 5),
    child: Text(text,textAlign: TextAlign.start,style: TextStyle(fontWeight: FontWeight.bold),),
  );
}
Widget rowItem(title,text,hidden){
  if(text == null && hidden == true || text == "" && hidden == true){
    return VisibleText();
  } else {
    text = text ?? "${title} tidak ada";
    return Container(
      padding: EdgeInsets.only(left: 16,right: 16),
      margin: EdgeInsets.only(bottom: 4),
      width: MediaQuery.of(thisContext).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            child: Text(capitalize(title),style: TextStyle(fontSize: 11.0),),
          ),
          Container(
            width: MediaQuery.of(thisContext).size.width,
            child: AutoSizeText(capitalize(text) ?? "",maxLines: 3,style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}
Widget rowItemBold(title,text,hidden){
  if(text == null && hidden == true || text == "" && hidden == true){
    return VisibleText();
  } else {
    text = text ?? "${title} tidak ada";
    return Container(
      padding: EdgeInsets.only(left: 16,right: 16),
      margin: EdgeInsets.only(bottom: 4),
      width: MediaQuery.of(thisContext).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            child: Text(capitalize(title),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
          ),
          Container(
            width: MediaQuery.of(thisContext).size.width,
            child: AutoSizeText(capitalize(text) ?? "",maxLines: 3,style: TextStyle(fontSize: 12,),),
          )
        ],
      ),
    );
  }
}
Widget headerContentDetail(workType,fromAddress,toAddress){
  if(workType == "emergency"){
    return Container(
      height: 35,
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(15, 40, 15, 0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 3,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 15,
            margin: EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on,color: PrimaryColor,size: 20,),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(thisContext).size.width - 125,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(fromAddress ?? "",maxLines: 3,style: TextStyle(fontSize: 10.0)),
              ],
            ),
          ),
//          btnUbahHeaderContent()
        ],
      ),
    );
  } else {
    return Container(
      height: 70,
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(15, 40, 15, 0),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 3,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            margin: EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconTF(PrimaryColor,25),
                SizedBox(
                  height: 10,
                ),
                IconTF(Colors.green,25),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(thisContext).size.width - 80,//140,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(fromAddress ?? "",maxLines: 3,style: TextStyle(fontSize: 10.0)),
                Divider(),
                AutoSizeText(toAddress ?? "",maxLines: 3,style: TextStyle(fontSize: 10.0))
              ],
            ),
          ),
//          btnUbahHeaderContent(),
        ],
      ),
    );
  }
}
Widget IconMarker(method,color,markerKey){
  String TitleMarker = method == 'origin' ? currentAddressText : tujuanAddressText;
  return RepaintBoundary(
    key: markerKey,
    child: Container(
      width: 200,
      height: 130,
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 10),
                      blurRadius: 10,
                      spreadRadius: 1,
                      color: Colors.grey.withOpacity(0.3)
                  )
                ]
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AutoSizeText(TitleMarker ?? "",maxLines: 3,style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 5),
                      blurRadius: 5,
                      spreadRadius: 1,
                      color: Colors.grey.withOpacity(0.5)
                  )
                ]
            ),
            child: Center(
              child: Icon(
                Icons.location_on,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
Widget itemRatingBar(reviewController){
  return Container(
    margin: EdgeInsets.only(top:8),
    width: MediaQuery.of(thisContext).size.width,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: EdgeInsets.only(top:8,bottom:8),
          child: Text("Rating untuk driver ?",style:TextStyle(fontSize: 20,fontWeight:FontWeight.bold))
        ),
        (Rating < 1 && Review != "" || Rating < 1 && Review != null) ?
        RatingBar(
          initialRating: Rating == "" || Rating < 1 ? 5 : Rating,
          itemCount: 5,
          itemSize: 50,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return Icon(
                  Icons.sentiment_very_dissatisfied,
                  color: Colors.red,
                );
              case 1:
                return Icon(
                  Icons.sentiment_dissatisfied,
                  color: Colors.redAccent,
                );
              case 2:
                return Icon(
                  Icons.sentiment_neutral,
                  color: Colors.amber,);
              case 3:
                return Icon(
                  Icons.sentiment_satisfied,
                  color: Colors.lightGreen,);
              case 4:
                return Icon(
                  Icons.sentiment_very_satisfied,
                  color: Colors.green,);
            }
          },
          onRatingUpdate: (rating) {
            RatingReview = rating;
          },
        ) : itemRating(Rating,50.0),
        (Rating < 1 && Review != "" || Rating < 1 && Review != null) ?
        Column(
          children: [
            Container(
              padding: EdgeInsets.only(left:16,right:16,top:16),
              child: TextField(
                controller: reviewController,
                maxLength: 250,
                decoration: InputDecoration(
                  hintText: 'Review untuk orderan anda',
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,//Normal textInputField will be displayed
                maxLines: 3,// when user presses enter it will adapt to it
              ),
            ),
            Container(
              padding: EdgeInsets.only(left:16,right:16),
              child: btnReview(),
            ),
          ],
        )
        :
        Container(
          padding: EdgeInsets.only(left:16,right:16,top:8,bottom:8),
          child: AutoSizeText(Review ?? "anda tidak menulis review",maxLines: 3),
        ),
        Divider(),
      ],
    ),
  );
}
