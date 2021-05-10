
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutterrajaderekcustomer/constant/route_names.dart' as routes;
import 'package:flutterrajaderekcustomer/constant/string.dart';
import 'package:flutterrajaderekcustomer/models/main_model.dart';
import 'package:flutterrajaderekcustomer/models/place.dart';
import 'package:flutterrajaderekcustomer/models/transaction_model.dart';
import 'package:flutterrajaderekcustomer/services/navigation_service.dart';
import 'package:flutterrajaderekcustomer/ui/form_kendaran_screen.dart';
import 'package:flutterrajaderekcustomer/utilities/styles.dart';
import 'package:flutterrajaderekcustomer/utilities/transaction_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../locator.dart';

var TransactionReceiveOrderID,CurrentAddressLocationList, TujuanAddressLocationList;
final NavigationService navigationService = locator<NavigationService>();
class TransactionDerekScreen extends StatelessWidget {
  var Method;
  TransactionDerekScreen(this.Method);
  @override
  Widget build(BuildContext context) {
    TransactionMethod = Method;
    return MapSample();
  }
}
class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {

  var Position, currentAddressLocationList,tujuanAddressLocationList;
  final formKeyVehicle = GlobalKey < FormState > ();
  final GlobalKey <ScaffoldState> _scaffoldKey = new GlobalKey < ScaffoldState > ();
  final markerOriKey = GlobalKey();
  final markerDesKey = GlobalKey();
  final PageController _pageController = PageController(initialPage: 0);
  final List<Place> _suggestedList = [
  ];
  TextEditingController searchJemputController           = new TextEditingController();
  TextEditingController searchTujuanController           = new TextEditingController();
  TextEditingController catatanController                = new TextEditingController();
  TextEditingController vehicleConditionRemarkController = new TextEditingController();
  TextEditingController productTypeController            = new TextEditingController();
  FocusNode focusNodeJemput = new FocusNode();
  FocusNode focusNodeTujuan = new FocusNode();
  Timer _throttle;
  CameraPosition CurrentLocationCamera;
  SharedPreferences pref;
  ProgressDialog pr;
  Completer<GoogleMapController> _controller = Completer();
  Future < Map > getHargaTarif() async {
    ListVehicle = await MainModel.getListVehicle();
    DataTarif = await MainModel.getCheckHargaTarif(TransactionMethod, currentAddressText,tujuanAddressText);
    SetMarkerJemput();
    setState(() {
      if(DataTarif != null){
        TarifID = DataTarif["ProductID"];
      }
      print(DataTarif);
    });
  }
  Future<void> goToCurrentLocation({String Method, var data}) async {
    print(Method);
    print(TransactionProccessNum);
    var latitude;
    var longitude;
    if(Method == 'set_location_latlng'){
      currentPosition = LatLng(data['latitude'], data['longitude']);
    } else if(Method == 'set_location'){
      var position = await GetLatLngFromAddress(data.name);
      currentPosition = LatLng(position['latitude'], position['longitude']);
      currentAddressLocation = "${position['latitude']}, ${position['longitude']}";
      currentAddressLocationList = position;
    } else {
      var position     = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      Position         = position;
      latitude         = position.latitude;
      longitude        = position.longitude;
      userLocation     = "${position.latitude}, ${position.longitude}";
      pref             = await SharedPreferences.getInstance();
      pref.setString("userLocation", userLocation ?? "0,0");
      currentPosition = LatLng(position.latitude, position.longitude);
      currentAddressLocation = "${position.latitude}, ${position.longitude}";
      currentAddressLocationList = {
        'latitude' : position.latitude,
        'longitude' : position.longitude
      };
      if(TransactionProccessNum == 2 || TransactionProccessNum == 4){
        GetAddressFromLatLng(latitude,longitude);
      }
    }
    if(TransactionProccessNum == 0 || TransactionProccessNum == 2 || TransactionProccessNum == 4 || TransactionProccessNum == 6){
      print("current location :");
      print(currentPosition);
      CameraPosition cameraPosition = CameraPosition(
          target: currentPosition,
          zoom: 17
      );
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    }
  }
  Future<String> getMyLocation() async {
    var position     = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    Position         = position;
    userLocation     = "${position.latitude},${position.longitude}";
    print(userLocation);
    CameraPosition cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 17
    );
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }
  @override
  Future<void> initState() {
    super.initState();
    CleanValue();
    GpsModel().gpsService(context);
    ClearMap();
    TransactionProccessNum = 0;
    LoadData();
    getMyLocation();
    pr = new ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false);
    pr.update(
      progress: 50.0,
      message: LoadingText,
      progressWidget: Container(
          padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
      maxProgress: 100.0,
    );
    placesList = _suggestedList;
    focusNodeJemput.addListener(_onFocusChange);
    focusNodeTujuan.addListener(_onFocusChange);
    searchJemputController.addListener(_onSearchJemputChanged);
    searchTujuanController.addListener(_onSearchTujuanChanged);
  }
  callback() {
    setState(() {
      print("ini callback");
    });
  }
  @override
  void dispose() {
    TransactionProccessNum = 0;
    if(pr != null){
      pr.hide();
    }
    searchJemputController.removeListener(_onSearchJemputChanged);
    searchJemputController.dispose();
    searchTujuanController.removeListener(_onSearchTujuanChanged);
    searchTujuanController.dispose();
    ClearMap();
    ClearAllData("All");
    super.dispose();
  }
  void _onFocusChange(){
    setState(() {
      if(TransactionProccessNum == 0){
        TransactionProccessNum = 1;
      }
      if(TransactionProccessNum == 1){
        searchTujuanController.text = "";
        searchJemputController.text = "";
      }
    });
  }
  void getLocationResults(String input, String method) async {
    if (input.isEmpty || input.length < 3) {
      setState(() {
      });
      return;
    }
    String baseURL  = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String location = userLocation;
    String type     = 'geocode';
    String languange = 'id'; //indonesia
    String request  = '$baseURL?input=$input&key=$MAP_API_KEY&language=$languange&origin=$location&types=$type';
    Response response = await Dio().get(request);
    final predictions = response.data['predictions'];
    List<Place> _displayResults = [];
    for (var i=0; i < predictions.length; i++) {
      var structured_formatting = predictions[i]['structured_formatting'];
      String name               = predictions[i]['description'];
      int distance_meters       = predictions[i]['distance_meters'] ?? 0;
      double distance_kma       = distance_meters > 0 ? double.parse((distance_meters / 1000).toStringAsFixed(1)) : 0;
      String distance_km        = distance_kma.toString();
      String main_text          = structured_formatting['main_text'];
      String second_text        = structured_formatting['secondary_text'];
      String city_name          = structured_formatting['secondary_text'];
      String province_name      = structured_formatting['secondary_text'];
      String country_name       = structured_formatting['secondary_text'];
      _displayResults.add(Place(method,name,distance_meters,distance_km,main_text,second_text,city_name,province_name,country_name));
      print(distance_km);
    }
    setState(() {
      placesList = _displayResults;
    });
  }
  LoadData() async {
    try {
      ListVehicle = await MainModel.getListVehicle();
      var data = MainModel().UpdateData();
      data.then((item){
        setState(() {
          pr.hide();
          print("ini load data");
          var ListData = item["ListData"];
        });
      });
    } on Exception catch (_) {
      pr.hide();
    }
  }
  ReLoadVehicle() async {
    try {
      pr.show();
      await MainModel.getListVehicle().then((item){
        ListVehicle = item;
        if(ListVehicle.length == 0){
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(
                content: Text('Anda tidak mempunyai data kendaraan'),
                duration: Duration(seconds: 1),
              ));
        }
        setState(() {
          pr.hide();
        });
      });
    } on Exception catch (_) {
      pr.hide();
    }
  }
  SetCenterMarker() async {
    Set<Marker> Markers_ = {};
    int no = 0;
    Markers_.clear();
    Markers.clear();
    if (Position != null) {
      Markers_.add(
        Marker(
            onTap: () {
              print('Tapped');
            },
            draggable: true,
            markerId: MarkerId('Marker'),
            position: LatLng(Position.latitude, Position.longitude),
            onDragEnd: ((value) {
              print(value.latitude);
              print(value.longitude);
            })),
      );
    }
    setState(() {
      Markers = Markers_;
    });
  }
  SetMarkerJemput(){
    if(TransactionProccessNum == 6 && DataTarif != null){
      if(TransactionMethod == "derek" || TransactionMethod == "paket"){
        ClearMap();
        SetPolylines();
        SetPolyLinesMarker();
      } else {
        Future.delayed(const Duration(milliseconds: 0), (){
          goToCurrentLocation(Method: 'set_location_latlng', data : currentAddressLocationList);
        });
        SetPolyLinesMarker();
      }
    }
  }
  SetPolylines() async {
    LatLng SOURCE_LOCATION = LatLng(currentAddressLocationList['latitude'],currentAddressLocationList["longitude"]);
    LatLng DEST_LOCATION = LatLng(tujuanAddressLocationList['latitude'],tujuanAddressLocationList["longitude"]);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      MAP_API_KEY,
      PointLatLng(SOURCE_LOCATION.latitude, SOURCE_LOCATION.longitude),
      PointLatLng(DEST_LOCATION.latitude, DEST_LOCATION.longitude),
    );
    if(result.points.isNotEmpty) {
      polylineCoordinates = [];
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
      print(result.points);
      print(polylineCoordinates.length);
    }
    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId("poly"),
        color: Colors.blueAccent,
        width: 5,
        points: polylineCoordinates,
      );
      Polylines.add(polyline);
    });
    setMapFitToTour(Polylines);
  }
  SetPolyLinesMarker() async {
    LatLng SOURCE_LOCATION = LatLng(currentAddressLocationList['latitude'],currentAddressLocationList["longitude"]);
    Uint8List markerOri = await getUint8List(markerOriKey);
    Markers.add(Marker(
        markerId: MarkerId('sourcePin'),
        position: SOURCE_LOCATION,
        icon: BitmapDescriptor.fromBytes(markerOri)
    ));
    if(TransactionMethod != "emergency"){
      LatLng DEST_LOCATION = LatLng(tujuanAddressLocationList['latitude'],tujuanAddressLocationList["longitude"]);
      Uint8List markerDes = await getUint8List(markerDesKey);
      Markers.add(Marker(
          markerId: MarkerId('destPin'),
          position: DEST_LOCATION,
          icon: BitmapDescriptor.fromBytes(markerDes)
      ));
    }
    setState(() {

    });
  }
  Future<void> setMapFitToTour(Set<Polyline> p) async {
    double minLat   = p.first.points.first.latitude;
    double minLong  = p.first.points.first.longitude;
    double maxLat   = p.first.points.first.latitude;
    double maxLong  = p.first.points.first.longitude;
    p.forEach((poly) {
      poly.points.forEach((point) {
        if(point.latitude < minLat) minLat = point.latitude;
        if(point.latitude > maxLat) maxLat = point.latitude;
        if(point.longitude < minLong) minLong = point.longitude;
        if(point.longitude > maxLong) maxLong = point.longitude;
      });
    });
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(LatLngBounds(
        southwest: LatLng(minLat, minLong),
        northeast: LatLng(maxLat,maxLong)
    ), 20));
  }
  ClearMap(){
    if(Markers.length > 0){
      Markers.clear();
    }
    if(Polylines.length > 0){
      Polylines.clear();
    }
  }
  ClearAllData(Method){
    if(Method == "VehicleForm" || Method == "All"){
      vehicleNameController.text  = '';
      vehicleNoController.text    = '';
      brandController.text        = '';
      typeController.text         = '';
      colorController.text        = '';
      imageSTNK                   = null;
      imageID                     = null;
    }
    if(Method == "All"){
      searchTujuanController.text = '';
      searchJemputController.text = '';
      catatanController.text      = '';
      currentAddressText          = '';
      currentAddressMainText      = '';
      currentAddressSecondText    = '';
      tujuanAddressText           = '';
      tujuanAddressMainText       = '';
      tujuanAddressSecondText     = '';
      placesList = [];
    }
  }
  onBackPressed(){
//    if(TransactionProccessNum == 0){
//      print("nol");
//    } else if(TransactionProccessNum == 1){
//      print("hiji");
//    }
  }
  onxClose(){
    setState(() {
      TransactionProccessNum = 0;
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }
  GetAddressFromLatLng(latitude,longitude) async {
    try {
      List<Placemark> placemark = await Geolocator().placemarkFromCoordinates(latitude,longitude);
      Placemark place = placemark[0];
      setState(() {
        currentAddressText       = "${place.name}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
        currentAddressMainText   = "${place.name}, ${place.subLocality}";
        currentAddressSecondText = "${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
        currentAddressLocation   = "${latitude}, ${longitude}";
        currentAddressLocationList = {
          'latitude' : latitude,
          'longitude' : longitude,
        };
      });
    } catch (e) {
      print(e);
    }
  }
  _onSearchJemputChanged() {
    if (_throttle?.isActive ?? false) _throttle.cancel();
    _throttle = Timer(const Duration(milliseconds: 500), () {
      getLocationResults(searchJemputController.text,'jemput');
    });
  }
  _onSearchTujuanChanged() {
    if (_throttle?.isActive ?? false) _throttle.cancel();
    _throttle = Timer(const Duration(milliseconds: 500), () {
      getLocationResults(searchTujuanController.text,'tujuan');
    });
  }
  setJemputLocationClick() {
    placesList = [];
    setState(() {
      if(TransactionProccessNum == 2){
        setState(() {
          if(tujuanAddressText == null || tujuanAddressSecondText == ""){
            TransactionProccessNum = 3;
          } else {
            TransactionProccessNum = 5;
            getHargaTarif();
          }
        });
      } else if(TransactionProccessNum == 4){
        TransactionProccessNum = 5;
        getHargaTarif();
        // ini pengecekan tarif kalau alamatnya otomatis alamat sekarang
      } else if(TransactionProccessNum == 5){
        validationPost = false;
        validationPostError = null;
        if (VehicleSelectedValue == "KendaraanForm"){
//          if(brandController.text == "" || BrandID == "" && BrandID == "0"){
//            snackbarShow('Merk kendaraan tidak boleh kosong');
//          } else if(typeController.text == "" || TypeID == "" || TypeID == ""){
//            snackbarShow('Tipe kendaraan tidak boleh kosong');
//          } else
          if(imageSTNK == null || imageSTNK == ""){
            snackbarShow('Foto STNK / mobil tidak boleh kosong');
          } else if(imageID == null || imageID == ""){
            snackbarShow('Foto SIM / KTP tidak boleh kosong');
          } else if(vehicleNoController.text == ""){
            snackbarShow('Nomor Polisi tidak boleh kosong');
          }  else if(formKeyVehicle.currentState.validate()){
            TransactionProccessNum = 6;
            getHargaTarif();
          }
        } else if(VehicleSelectedValue == "KendaraanPribadi" && ListVehicle.length == 0){
          popUpshow("denied",context,"Anda belum memilih kendaraan anda silakan pilih, jika belum tersedia silakan tambah data kendaraan Anda");
        } else {
          TransactionProccessNum = 6;
          getHargaTarif();
        }
      } else if(TransactionProccessNum == 6){
        setJemputProccess();
      } else {

      }
    });
    currentLog();
  }
  setJemputProccess() async {
    print("haha");
    if(DataTarif == null){

    } else if(VehicleSelectedValue == "KendaraanPribadi" && ListVehicle.length == 0){
      snackbarShow('Anda tidak mempunyai data kendaraan');
    } else if(VehicleSelectedValue == "KendaraanPribadi" && VehicleIDSelected == null || VehicleSelectedValue == "KendaraanPribadi" && VehicleIDSelected == ""){
      snackbarShow('Anda belum memilih kendaraan anda sendiri');
    } else if(PaymentSelectedValue == null || PaymentSelectedValue == ""){
      snackbarShow('Anda belum memilih tipe metode pembayaran');
    } else if(ConditionSelectedValue == "lain-lain" && vehicleConditionRemarkController.text == ""){
      snackbarShow('Anda belum mengisi kondisi kendaraan');
    } else if(PaymentSelectedValue == "Lainnyax"){
      popUpshow("payment",context,'Metode pembayaran online belum tersedia untuk sekarang');
    } else {
      pr.show();
      try {
        var Data = await TransactionModel.transactionOrderPost(
          TransactionReceiveOrderID : TransactionReceiveOrderID,
          WorkType : TransactionMethod,
          TarifID : TarifID,
          TarifIDAR : tarifValues.toString(),
          VehicleID: VehicleIDSelected,
          VehicleCondition : ConditionSelectedValue,
          VehicleConditionRemark : vehicleConditionRemarkController.text,
          PaymentType: PaymentSelectedValue,
          ProductType: productTypeController.text,
          Remark : catatanController.text,
          FromAddress : currentAddressText,
          FromLatLng : currentAddressLocation,
          ToAddress : tujuanAddressText,
          ToLatLng : tujuanAddressLocation,
          VehicleSelectedValue : VehicleSelectedValue,
          VehicleName : vehicleNameController.text,
          VehicleNo : vehicleNoController.text,
          BrandName : brandController.text,
          BrandID : BrandID,
          TypeName : typeController.text,
          TypeID : TypeID,
          Color : colorController.text,
          imageSTNK : imageSTNK,
          imageID : imageID,
        );
        if(Data != null){
          Future.delayed(Duration(milliseconds: 500)).then((value) {
            pr.hide().whenComplete(() {
              print(pr.isShowing());
            });
          });
          if(Data['Status'] == true){
            setState(() {
              TransactionReceiveOrderID = Data['TransactionReceiveOrderID'].toString();
              print(TransactionReceiveOrderID);
            });
            Future.delayed(const Duration(milliseconds: 100), (){
              if(PaymentSelectedValue == "Lainnya"){
                navigationService.navigateTo(routes.TransactionPaymentScreenRoute,arguments: Data);
              } else {
                navigationService.navigateTo(routes.TransactionFinishScreenRoute,arguments: Data);
              }
            });
          } else {
            if(Data["Popup"] == true){
              popUpshow("denied",context,Data['Message']);
            } else {
              popUpshow("denied",context,Data['Message']);
            }
          }
        }
      } catch (e){
        popUpshow("error",context,ERROR_MESSAGE);
        Future.delayed(Duration(milliseconds: 500)).then((value) {
          pr.hide().whenComplete(() {
            print(pr.isShowing());
          });
        });
      }
    }
  }
  snackbarShow(Message){
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text(Message),
          duration: Duration(seconds: 1),
        ));
  }
  currentLog(){
    print("Transaction Method : ${TransactionMethod}");
    print("TransctionNum : ${TransactionProccessNum}");
  }
  setLocationClick(method,data) async {
    print("data : ${data}");
    placesList = [];
    if(TransactionMethod == "emergency" && method == "jemput"){
      TransactionProccessNum = 4;
      searchJemputController.text = data.main_text;
      currentAddressText = data.name;
      currentAddressMainText = data.main_text;
      currentAddressSecondText = data.second_text;
      tujuanAddressText = data.name;
      tujuanAddressMainText = data.main_text;
      tujuanAddressSecondText = data.second_text;
    } else {
      if(method == "jemput"){
        TransactionProccessNum = 2;
        searchJemputController.text = data.main_text;
        currentAddressText = data.name;
        currentAddressMainText = data.main_text;
        currentAddressSecondText = data.second_text;
      } else {
        if(method == "tujuan" && TransactionProccessNum == 3){
          TransactionProccessNum = 5;
        } else {
          TransactionProccessNum = 4;
        }
        searchTujuanController.text = data.main_text;
        tujuanAddressText = data.name;
        tujuanAddressMainText = data.main_text;
        tujuanAddressSecondText = data.second_text;
        var position = await GetLatLngFromAddress(tujuanAddressText);
        tujuanAddressLocation = "${position['latitude']}, ${position['longitude']}";
        tujuanAddressLocationList = position;
      }
    }
    setState(() {
      getHargaTarif();
      // ini cek harga taif kalau alamat jemputnya di set manual
    });
    if(TransactionMethod == "emergency" || method == "jemput"){
      Future.delayed(const Duration(milliseconds: 0), (){
        goToCurrentLocation(Method: 'set_location', data : data);
      });
    } else if(TransactionProccessNum < 5){
      Future.delayed(const Duration(milliseconds: 0), (){
        goToCurrentLocation(Method: 'search_location',data:null);
        //goToCurrentLocation(Method: 'set_location', data : data);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    thisContext = context;
    parent = this;
    final ScrollController _scrollController = ScrollController();
    return WillPopScope(
      onWillPop : onBackPressed(),
      child: Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomPadding: false,
          resizeToAvoidBottomInset: false,
          body: new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: KeyboardAvoider(
                autoScroll: false,
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  child: StackContent(),
                ),
              )
          )
      ),
    );
  }
  Widget StackContent(){
    CameraPosition cameraPosition;
    cameraPosition = FirstLocationCamera;
    return Stack(
      children: [
        IconMarker('origin',PrimaryColor,markerOriKey),
        IconMarker('destination',Colors.green,markerDesKey),
        AnimatedContainer(
          duration: Duration(milliseconds: 0),
          height: setHeightMap(context,TransactionProccessNum,TransactionMethod),
          child: GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: cameraPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: Set.from(
              Markers,
            ),
            polylines: Polylines,
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            HeaderContent(),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            HeaderButton(),
            BodyContent(),
          ],
        )
      ],
    );
  }
  Widget BodyContent(){
    // ini pake expanded agar tidak error overflow
    if(TransactionProccessNum == 1 || TransactionProccessNum == 3 || TransactionProccessNum == 5){
      return Expanded(child: AnimatedContainer(
        duration: Duration(milliseconds: 0),
        height: setHeightMainContainer(context,TransactionProccessNum,TransactionMethod,DataTarif),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 3,
            )
          ],
        ),
        child: setContentMainContainer(),
      ));
    } else {
      return AnimatedContainer(
        duration: Duration(milliseconds: 0),
        height: setHeightMainContainer(context,TransactionProccessNum,TransactionMethod,DataTarif),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 3,
            )
          ],
        ),
        child: setContentMainContainer(),
      );
    }
  }
  Widget HeaderContent(){
    if(TransactionProccessNum == 6){
      if(TransactionMethod == "emergency"){
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
                width: MediaQuery.of(context).size.width - 125,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(currentAddressMainText ?? "",maxLines: 3,style: TextStyle(fontSize: 10.0)),
                  ],
                ),
              ),
              btnUbahHeaderContent()
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
                width: MediaQuery.of(context).size.width - 140,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(currentAddressMainText ?? "",maxLines: 3,style: TextStyle(fontSize: 10.0)),
                    Divider(),
                    AutoSizeText(tujuanAddressMainText ?? "",maxLines: 3,style: TextStyle(fontSize: 10.0))
                  ],
                ),
              ),
              btnUbahHeaderContent(),
            ],
          ),
        );
      }
    } else {
      return VisibleText();
    }
  }
  Widget setContentMainContainer(){
    if(TransactionProccessNum == 2 || TransactionProccessNum == 4){
      String title = currentAddressMainText ?? "";
      String text  = currentAddressSecondText ?? "";
      return Stack(
        children: [
          Container(
            padding: TransactionProccessNum == 1 ? EdgeInsets.fromLTRB(15, 40, 15, 20) : EdgeInsets.fromLTRB(15,15,15,20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Set Lokasi Anda Sekarang",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                      SizedBox(
                        height: 25,
                        width: 60,
                        child: OutlineButton(
                          onPressed: (){
                            setState(() {
                              placesList = [];
                              TransactionProccessNum = TransactionProccessNum - 1;
                              searchJemputController.text = '';
                              catatanController.text = '';
                              productTypeController.text = '';
                              ClearMap();
                            });
                            Future.delayed(const Duration(milliseconds: 500), (){
                              FocusScope.of(context).requestFocus(focusNodeJemput);
                              focusNodeJemput.requestFocus();
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
                              fontSize: 12,
                            ),
                          ),
                        ),
                      )
                    ]
                ),
                Container(
                  child: ListTile(
                    contentPadding: EdgeInsets.only(top:15),
                    leading: IconTF(PrimaryColor,40),
                    title: AutoSizeText(title ?? "",
                        maxLines: 3,
                        style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)
                    ),
                    subtitle: AutoSizeText(text ?? "",
                        maxLines: 3,
                        style: TextStyle(fontSize: 13.0)
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                child:buildTFCatatan(catatanController),
              ),
              btnSetJemputLocation(),
            ],
          )
        ],
      );
    } else if(TransactionProccessNum == 5){
      return  Stack(
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(0, 32, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buttonBackContainer(),
                      Text("Data Kendaraan",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
                    ]
                ),
              ],
            )
          ),
          Container(
            margin: EdgeInsets.only(top:80,bottom:100),
            child: SingleChildScrollView(
                child: Column(
                    children: <Widget>[
                      Container(
                        child: VehicleSelectedValue == "KendaraanForm" ? formVehicle(context,formKeyVehicle) : WidgetVehicleSlide(ListVehicle),
                      ),
                    ]
                )
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildOPVehicleSelect(),
              Container(
                child: ListVehicle.length > 0 && VehicleSelectedValue == "KendaraanPribadi" || VehicleSelectedValue == "KendaraanForm" ? VisibleText() : btnTambahKendaraan(),
              ),
              btnSetJemputLocation(),
            ],
          )
        ],
      );
    } else if(TransactionProccessNum == 6) {
      if(DataTarif == null){
        return  Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 2 - 140,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Tarif Tidak Tersedia",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
                  Text("maaf layanan kami tidak tersedia untuk alamat kota yang anda pilih, silakan pilih alamat kota yang lain.")
                ],
              ),
            ),
          ],
        );
      } else if(TransactionMethod != "paket" && ListVehicle == null || TransactionMethod != "paket" && ListVehicle.length == 0){
        return Stack(
          children: [
            Container(
              padding:EdgeInsets.fromLTRB(15,15,15,20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Tidak Ada Data Kendaraan",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
                        SizedBox(
                          height: 25,
                          width: 30,
                          child: OutlineButton(
                            onPressed: (){
                              ReLoadVehicle();
                            },
                            padding: EdgeInsets.all(1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            borderSide: BorderSide(color: PrimaryColor,),
                            color: Colors.white,
                            child: Icon(Icons.refresh,color: PrimaryColor,),
                          ),
                        )
                      ]
                  ),
                  Text("Anda tidak mempunyai data kendaraan silakan tambah dahulu data kendaraan anda"),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                btnTambahKendaraan(),
              ],
            )
          ],
        );
      } else {
        if(VehicleSelectedValue == "KendaraanForm"){
          VehicleName = "";//vehicleNameController.text;
          VehicleNo = vehicleNoController.text;
          BrandName = brandController.text;
          TypeName = typeController.text;
          Color = colorController.text;
        } else {
          VehicleName = ListVehicle[currentPage]["Name"];
          VehicleNo   = ListVehicle[currentPage]["VehicleNo"];
          BrandName   = ListVehicle[currentPage]["BrandName"];
          TypeName    = ListVehicle[currentPage]["TypeName"];
          Color       = ListVehicle[currentPage]["Color"];
        }
        return  Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 2 - 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(top:16,left: 16,right: 16),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("Pilih Metode Pembayaran",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.start,),
                        ]
                    ),
                  ),
                  VehicleBox(VehicleName,VehicleNo,BrandName,TypeName,Color),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        height: 40,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(0),
                          title: Row(
                            children: [
                              PaymentSelectedIcon,
                              SizedBox(width: 15,),
                              Text(PaymentSelectedText,style: TextStyle(fontWeight: FontWeight.bold),)
                            ],
                          ),
                          trailing: Icon(Icons.more_vert),
                          onTap: (){
                            showModalPayment();
                          },
                        ),
                      ),
                      buildOPVehicleCondition(),
                      buildTFVehicleCondition(vehicleConditionRemarkController),
                      buildTFProductType(productTypeController),
                      btnPesan()
                    ],
                  ),
                )
              ],
            )
          ],
        );
      }
    } else {
      return Column(
        children: [
          Container(
            padding: TransactionProccessNum == 1 || TransactionProccessNum == 3? EdgeInsets.fromLTRB(15, 40, 15, 20) : EdgeInsets.fromLTRB(15,15,15,20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  buttonBackContainer(),
                  Text("Lokasi Tujuan",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
                ]),
                buildFormTujuan(),
              ],
            ),
          ),
          ListAddress(),
        ],
      );
    }
  }
  Widget WidgetVehicleSlide(ListVehicle) {
    if(TransactionMethod == "derek" || TransactionMethod == "emergency"){
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(top:16,left:16,bottom:0,right:16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Pilih Kendaraan Pribadi Anda",style: TextStyle(fontWeight: FontWeight.bold),),
                SizedBox(
                  height: 25,
                  width: 30,
                  child: TransactionMethod == "paket" ? VisibleText() : OutlineButton(
                    onPressed: (){
                      ReLoadVehicle();
                    },
                    padding: EdgeInsets.all(1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    borderSide: BorderSide(color: PrimaryColor,),
                    color: Colors.white,
                    child: Icon(Icons.refresh,color: PrimaryColor,),
                  ),
                )
              ],
            ),
          ),
          Container(
            child: ListVehicle.length > 0 ? VisibleText() : Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text("Anda tidak mempunyai data kendaraan, silakan tambah data kendaraan dengan menekan tombol tambah kendaraan di bawah"),
                ],
              ),
            ),
          ),
          Container(
            height: 125,
            child: PageView.builder(
              physics: BouncingScrollPhysics(),
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  currentPage = page;
                  VehicleIDSelected = ListVehicle[page]["VehicleID"];
                });
              },
              itemBuilder: (context, index) {
                var items = ListVehicle[index];
                if(currentPage == 0){
                  VehicleIDSelected = ListVehicle[0]["VehicleID"];
                }
                return DivVehicle(items);
              },
              itemCount: ListVehicle.length,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildPageIndicator(ListVehicle),
          ),
        ],
      );
    } else {
      return VisibleText();
    }
  }
  Widget HeaderButton(){
    if(TransactionProccessNum != 1 || TransactionProccessNum != 3){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buttonBackTransaction(),
          buttonCurrentLocation()
        ],
      );
    } else {
      return VisibleText();
    }
  }
  Widget buttonBackTransaction(){
    if(TransactionProccessNum != 3 && TransactionProccessNum != 1 && TransactionProccessNum != 5){
      return Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            onTap: (){
              if(TransactionProccessNum == 0){
                Navigator.of(context).pop();
              } else {
                setState(() {
                  TransactionProccessNum = TransactionProccessNum - 1;
                  if(TransactionProccessNum == 1){
                    searchTujuanController.text = "";
                    searchJemputController.text = "";
                  } else if(TransactionProccessNum < 6){
                    ClearMap();
                  }
                });
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(1, 2), // changes position of shadow
                    ),
                  ]
              ),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black, size: 35),
            ),
          )
      );
    } else {
      return VisibleText();
    }
  }
  Widget buttonCurrentLocation(){
    if(TransactionProccessNum != 3 && TransactionProccessNum != 1 && TransactionProccessNum != 5){
      return Padding(
          padding: const EdgeInsets.all(10),
          child: InkWell(
            onTap: (){
              goToCurrentLocation(Method: 'search_location',data:null);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(1, 2), // changes position of shadow
                    ),
                  ]
              ),
              child: Icon(Icons.my_location, color: Colors.blue, size: 20),
            ),
          )
      );
    } else {
      return VisibleText();
    }
  }
  Widget ListAddress(){
    return Expanded(
      child: AnimatedOpacity(
        opacity: TransactionProccessNum == 1 || TransactionProccessNum == 3? 1 : 0,
        duration: Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
              border: Border(
                  top: BorderSide( //                   <--- left side
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  )
              )
          ),
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: placesList.length ?? 0,
            itemBuilder: (BuildContext context, int index) =>
                buildPlaceCard(context, index),
          ),
        ),
      ),
    );
  }
  Widget buildFormTujuan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
//                blurRadius: 3,
              )
            ],
          ),
          margin: EdgeInsets.only(top:15),
          padding: EdgeInsets.only(left: 5,right: 5),
          child: Column(
            children: [
              buildTFJemput(searchJemputController,focusNodeJemput),
              buildTFTujuan(searchTujuanController,focusNodeTujuan),
            ],
          ),
        ),
      ],
    );
  }
  Widget BtnMyLocation(){
    return Container(
//      margin: EdgeInsets.only(bottom:100,left:30),
      child: Padding(
          padding: const EdgeInsets.all(0),
          child: InkWell(
            onTap: (){
              goToCurrentLocation(Method: 'search_location',data:null);
            },
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50)
              ),
              child: Icon(Icons.my_location, color: Colors.black, size: 25),
            ),
          )
      ),
    );
  }
  Widget buildPlaceCard(BuildContext context, int index) {
    String method = placesList[index].method;
    String main_text = placesList[index].main_text;
    return Hero(
      tag: "SelectedTrip-${placesList[index].name}",
      transitionOnUserGestures: true,
      child: Container(
        child: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              right: 8.0,
            ),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Container(
                    padding:EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Icon(Icons.location_on,color: Colors.grey,),
                        Text("${placesList[index].distance_km} km",style: TextStyle(fontSize: 10),),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: AutoSizeText(placesList[index].main_text ?? "",
                                    maxLines: 3,
                                    style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Flexible(
                                child: AutoSizeText(placesList[index].second_text ?? "",
                                    maxLines: 3,
                                    style: TextStyle(fontSize: 13)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                setLocationClick(method,placesList[index]);
              },
            )
        ),
      ),
    );
  }
}