import 'dart:async';
import 'dart:math';
import 'package:car_rental/pages/details_state.dart';
import 'package:car_rental/widgets/build_snack_error.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';
import 'package:car_rental/pages/maps.dart';

class DetailsPage extends StatefulWidget {
  final String carImage;
  final String carClass;
  final String carName;
  final int carPower;
  final String people;
  final String carId;
  final String bags;
  final int carPrice;
  final String carRating;
  final bool isRotated;
  final isRegistered = false;

  const DetailsPage({
    Key? key,
    required this.carImage,
    required this.carClass,
    required this.carName,
    required this.carPower,
    required this.people,
    required this.bags,
    required this.carId,
    required this.carPrice,
    required this.carRating,
    required this.isRotated,
    
  }) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();

}



Future<bool> isCarAlreadyRented(String carId) async {
  try {
    DocumentSnapshot carSnapshot = await FirebaseFirestore.instance
        .collection('cars') // Assuming 'cars' is the collection where your cars are stored
        .doc(carId) // Specify the ID of the car document you want to check
        .get();

    if (carSnapshot.exists) {
      // Check if the rented_car field is empty or not
      var data = carSnapshot.data() as Map<String, dynamic>?; // Explicitly cast to Map<String, dynamic> or null
      if (data != null && data["rented_user"] == null) {
        // Car is not rented
        return false;
      } else {
        // Car is rented
    
        carData = data;
        return true;
      }
    } else {
      // Car document does not exist
      print('Car document does not exist');
      return false;
    }
  } catch (error) {
    print('Error checking if car is already rented: $error');
    return false;
  }
}
Map<String, dynamic>? carData ;

Future<String?> getCurrentUserId() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;

  if (user != null) {
    return user.uid;
  } else {
    // No user signed in
    return null;
  }
}



class _DetailsPageState extends State<DetailsPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = LatLng(50.470685, 19.070234);
  var isCarReg = false;
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }
  void check(var carId)async{
     bool isCarAlreadyrented= await isCarAlreadyRented(carId);
          if (isCarAlreadyrented == true){
              final userid = await getCurrentUserId();


              if (carData!["rented_user"] == userid){
              context.read<detialedCubit>().change(true);
              
              }else{
                    context.read<detialedCubit>().change(false);

              }}
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; //check the size of device
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness ==
        Brightness.dark; //check if device is in dark or light mode

      check(widget.carId);

    return 
    
    Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0), //appbar size
        child: AppBar(
          bottomOpacity: 0.0,
          elevation: 0.0,
          shadowColor: Colors.transparent,
          backgroundColor: isDarkMode
              ? const Color(0xff06090d)
              : const Color(0xfff8f8f8), //appbar bg color

          leading: Padding(
            padding: EdgeInsets.only(
              left: size.width * 0.05,
            ),
            child: SizedBox(
              height: size.width * 0.1,
              width: size.width * 0.1,
              child: InkWell(
                onTap: () {
                  Get.back(); //go back to home page
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xff070606)
                        : Colors.white, //icon bg color
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  child: Icon(
                    UniconsLine.multiply,
                    color: isDarkMode ? Colors.white : const Color(0xff3b22a1),
                    size: size.height * 0.025,
                  ),
                ),
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          leadingWidth: size.width * 0.15,
          title: Image.asset(
            isDarkMode
                ? 'assets/icons/SobGOGlight.png'
                : 'assets/icons/SobGOGdark.png',
            height: size.height * 0.06,
            width: size.width * 0.35,
          ),
          centerTitle: true,
        ),
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Center(
        child: Container(
          height: size.height,
          width: size.height,
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xff06090d)
                : const Color(0xfff8f8f8), //background color
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.05,
              ),
              child: Stack(
                children: [
                  ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      widget.isRotated
                          ? Image.network(
                              widget.carImage,
                              height: size.width * 0.5,
                              width: size.width * 0.8,
                              fit: BoxFit.contain,
                            )
                          : Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(pi),
                              child: Image.network(
                                widget.carImage,
                                height: size.width * 0.5,
                                width: size.width * 0.8,
                                fit: BoxFit.contain,
                              ),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.carClass,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xff3b22a1),
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.star,
                            color: Colors.yellow[800],
                            size: size.width * 0.06,
                          ),
                          Text(
                            widget.carRating,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.yellow[800],
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            widget.carName,
                            textAlign: TextAlign.left,
                            style: GoogleFonts.poppins(
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xff3b22a1),
                              fontSize: size.width * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${widget.carPrice}\Rs',
                            style: GoogleFonts.poppins(
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xff3b22a1),
                              fontSize: size.width * 0.04,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '/per day',
                            style: GoogleFonts.poppins(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.black.withOpacity(0.8),
                              fontSize: size.width * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: size.height * 0.02,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            buildStat(
                              UniconsLine.dashboard,
                              '${widget.carPower} KM',
                              'Power',
                              size,
                              isDarkMode,
                            ),
                            buildStat(
                              UniconsLine.users_alt,
                              'People',
                              '( ${widget.people} )',
                              size,
                              isDarkMode,
                            ),
                            buildStat(
                              UniconsLine.briefcase,
                              'Bags',
                              '( ${widget.bags} )',
                              size,
                              isDarkMode,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: size.height * 0.03,
                        ),
                        child: Text(
                          'Vehicle Location',
                          style: GoogleFonts.poppins(
                            color: isDarkMode
                                ? Colors.white
                                : const Color(0xff3b22a1),
                            fontSize: size.width * 0.055,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Center(
                        child: SizedBox(
                          height: size.height * 0.15,
                          width: size.width * 0.9,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.05)
                                  : Colors.white,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(
                                  10,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.05,
                                    vertical: size.height * 0.015,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        UniconsLine.map_marker,
                                        color: const Color(0xff3b22a1),
                                        size: size.height * 0.05,
                                      ),
                                      Text(
                                        'Belgaum ',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: isDarkMode
                                              ? Colors.white
                                              : const Color(0xff3b22a1),
                                          fontSize: size.width * 0.05,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Near Kle Tech Belgaum',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          color: isDarkMode
                                              ? Colors.white.withOpacity(0.7)
                                              : Colors.black.withOpacity(0.7),
                                          fontSize: size.width * 0.032,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: size.height * 0.17,
                                  width: size.width * 0.29,
                                  child: GoogleMap(
                                    mapType: MapType.hybrid,
                                    onMapCreated: _onMapCreated,
                                    initialCameraPosition: const CameraPosition(
                                      target: _center,
                                      zoom: 13.0,
                                    ),
                                    onTap: (latLng) => Get.to(Maps()),
                                    zoomControlsEnabled: false,
                                    scrollGesturesEnabled: true,
                                    zoomGesturesEnabled: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  buildSelectButton(size, isDarkMode , widget.carId , context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding buildStat(
      IconData icon, String title, String desc, Size size, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.015,
      ),
      child: SizedBox(
        height: size.width * 0.32,
        width: size.width * 0.25,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(
                10,
              ),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: size.width * 0.03,
              left: size.width * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  color: const Color(0xff3b22a1),
                  size: size.width * 0.08,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.width * 0.02,
                  ),
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.poppins(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Align buildSelectButton(Size size, bool isDarkMode  , String carId , BuildContext context) {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Padding(
      padding: EdgeInsets.only(
        bottom: size.height * 0.01,
      ),
      child: SizedBox(
        height: size.height * 0.07,
        width: size.width,
        child: InkWell(
          onTap: () async {
          context.read<detialedCubit>().change(null);

          bool isCarAlreadyrented= await isCarAlreadyRented(carId);
          if (isCarAlreadyrented == true){
              final userid = await getCurrentUserId();


              if (carData!["rented_user"] == userid){
              context.read<detialedCubit>().change(true);
              EasyLoading.dismiss();

                  buildSnackError(
"you already have rented this car"                         ,                     context,
                                              size,
                                            );
              print("you already have rented this car");

              }else{
                                          context.read<detialedCubit>().change(false);

                              EasyLoading.dismiss();

                 buildSnackError(
"already another user is rented this car"                         ,                     context,
                                              size,
                                            );
              print("already another user is rented this car");
              }
          }else{
              final userid = await getCurrentUserId();
              FirebaseFirestore.instance
                  .collection('cars') // Assuming 'cars' is the collection where your cars are stored
                  .doc(carId) // Specify the ID of the car document you want to update
                  .update({
                'rented_user': userid,
              }).then((value) {
                    context.read<detialedCubit>().change(true);
                                  EasyLoading.dismiss();


                 buildSnackError(
"You Rented this car successfully"                         ,                     context,
                                              size,
                                            );
                print('Rented user updated successfully');
              }).catchError((error) {
                          context.read<detialedCubit>().change(false);

                              EasyLoading.dismiss();

                             buildSnackError(
"Failed to update rented user"                         ,                     context,
                                              size,
                                            );
                print('Failed to update rented user: $error');

              });
        }
 
  
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xff3b22a1),
            ),
            child: Align(
              child: 
              BlocBuilder<detialedCubit , bool?>(builder: (context, state) {
                return
                state == null ?
                Center(child: CircularProgressIndicator(),) : 
                 Text(
                 state == true ? 'Rented' : "Select",
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: size.height * 0.025,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
              },)
              
            ),
          ),
        ),
      ),
    ),
  );
  
}