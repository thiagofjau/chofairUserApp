import 'dart:async';
import 'package:chofair_user/assistants/assistant_methods.dart';
import 'package:chofair_user/assistants/geofire_assistant.dart';
import 'package:chofair_user/global/global.dart';
import 'package:chofair_user/info_handler/app_info.dart';
import 'package:chofair_user/mainscreens/search_places_screen.dart';
import 'package:chofair_user/mainscreens/select_nearest_active_driver_screen.dart';
import 'package:chofair_user/models/active_nearby_available_drivers.dart';
import 'package:chofair_user/widgets/my_drawer.dart';
import 'package:chofair_user/widgets/progress_dialog.dart';
import 'package:chofair_user/widgets/snack_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});


  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

final Completer<GoogleMapController> _controllerGoogleMap = Completer();
GoogleMapController? newGoogleMapController;

static const CameraPosition _jau = CameraPosition(
    target: LatLng(-22.2963, -48.5587), // <- LatLng de Jaú, iniciar posição da câmera aqui
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> sKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();




  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polylineSet = {};

  //ícone marcador atual e destino após traçar rota
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  String userName = "Nome";
  String userEmail = "E-mail";

  bool openNavigationDrawer = true; //cria boolean drawer false true para cancelar trajeto
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;

  List<ActiveNearbyAvailableDrivers> onlineNearbyAvailableDriversList = [];

  DatabaseReference? referenceRideRequest;

  // Função para remover a solicitação de corrida e atualizar a tela
  void removeRequestAndRefresh() {
    // Remova a solicitação de corrida do banco de dados aqui
    // ...
    // Após a remoção, atualize a interface do usuário
    setState(() {
      // Atualize a interface do usuário aqui
      // Você pode definir dList para uma nova lista vazia ou null, por exemplo
      dList = [];
    });
  }

  // Função para limpar a pesquisa e redefinir o texto "Toque para definir onde deseja ir"
  void clearSearchAndResetText() {
    Provider.of<AppInfo>(context, listen: false).userDropOffLocation = null;
  }
  

cleanThemeGoogleMap() {
  newGoogleMapController!.setMapStyle('''
                    [  {
    "featureType": "administrative",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#d6e2e6"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#cfd4d5"
      }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#7492a8"
      }
    ]
  },
  {
    "featureType": "administrative.neighborhood",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "lightness": 25
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#dde2e3"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#cfd4d5"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#dde2e3"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#7492a8"
      }
    ]
  },
  {
    "featureType": "landscape.natural.terrain",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#dde2e3"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [
      {
        "saturation": -100
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#588ca4"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#a9de83"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#bae6a1"
      }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#c6e8b3"
      }
    ]
  },
  {
    "featureType": "poi.sports_complex",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#bae6a1"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.icon",
    "stylers": [
      {
        "saturation": -45
      },
      {
        "lightness": 10
      },
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#41626b"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#c1d1d6"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#a6b5bb"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "road.highway.controlled_access",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#9fb6bd"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.icon",
    "stylers": [
      {
        "saturation": -70
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#b4cbd4"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#588ca4"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#008cb5"
      }
    ]
  },
  {
    "featureType": "transit.station.airport",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "saturation": -100
      },
      {
        "lightness": -5
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#a6cbe3"
      }
    ]
  }
]
                ''');
            
}

//pedir permissão da localização
checkIfLocationPermissionAllowed() async {
  _locationPermission = await Geolocator.requestPermission();

  if(_locationPermission == LocationPermission.denied)
  {
    _locationPermission = await Geolocator.requestPermission();
  }
}

locateUserPosition() async {
  //aqui pega a posicao atual do user
 Position cPosition =  await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
 userCurrentPosition = cPosition;

 LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
 CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 15);

 newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

  String humanReadableAddress = await AssistantMethods.searchAddressForGeoCoordinates(userCurrentPosition!, context);
 print("Está é minha localização: $humanReadableAddress");

 userName = userModelCurrentInfo!.name!;
 userEmail = userModelCurrentInfo!.email!;


 initializeGeoFireListener();
}

@override
  void initState() {
    super.initState(); 
    checkIfLocationPermissionAllowed();   
  }

  saveRideRequestInformation() {
    //1. salvar a informação da solicitação de corrida

    referenceRideRequest = FirebaseDatabase.instance.ref().child("All Ride Requests").push(); //.push gera um uID

    var originLocation = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationLocation = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    Map originLocationMap = {
      "latitude": originLocation!.locationLatitude.toString(),
      "longitude": originLocation.locationLongitude.toString(),
    };

    Map destinationLocationMap = {
      "latitude": destinationLocation!.locationLatitude.toString(),
      "longitude": destinationLocation.locationLongitude.toString(),
    };

    Map userInformationMap = { 
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": userModelCurrentInfo!.name,
      "userPhone": userModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };

    referenceRideRequest!.set(userInformationMap);

    onlineNearbyAvailableDriversList = GeoFireAssistant.activeNearbyAvailableDriversList;
    searchNearestOnlineDrivers();
  }

  searchNearestOnlineDrivers() async {
    //nenhum motorista disponível
    if(onlineNearbyAvailableDriversList.length == 0) //alterar para isEmpty?
    {
       referenceRideRequest!.remove();
       //cancelar/deletar a solicitação
      setState(() {
        polylineSet.clear();
        markersSet.clear();
        circlesSet.clear();
        pLineCoordinatesList.clear();
      });

      showRedSnackBar(context, "Nenhum motorista próximo, tente mais tarde. Recarregando...");
      Future.delayed(const Duration(milliseconds: 4000), ()
      {
        // MyApp.restartApp(context); //AQUI VOLTA SEM FECHAR APP, MAS TALVEZ NÃO EXCLUA A REQUEST DO DB
        SystemNavigator.pop();
      }
       );
      
      return;
    }
    //motorista disponível, executa o código abaixo
    await retrieveOnlineDriversInformation(onlineNearbyAvailableDriversList);

    Navigator.push(context, MaterialPageRoute(builder: (c) => 
    SelectNearestActiveDriverScreen(referenceRideRequest: referenceRideRequest)));
  }

  retrieveOnlineDriversInformation(List onlineNearbyAvailableDriversList) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for(int i=0; i<onlineNearbyAvailableDriversList.length; i++) {
      await ref.child(onlineNearbyAvailableDriversList[i].driverId.toString())
          .once()
          .then((dataSnapshot){
            var driverInfoKey = dataSnapshot.snapshot.value;
            dList.add(driverInfoKey);
          });
    }
  }
  
  @override
  Widget build(BuildContext context) {

    createActiveNearbyDriverIconMarker();

    return Scaffold(
      // appBar: AppBar(),
      key: sKey,
      drawer: SizedBox( //sugeriu replace o Container que estava
        width: 250,
        child: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: const Color(0xFF222222)
          ),
          child: MyDrawer(
            name: userName,
            email: userEmail,
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: _jau,
            polylines: polylineSet,
            markers: markersSet,
            circles: circlesSet,
            onMapCreated: (GoogleMapController controller)
            {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              // Google Map clean theme
                cleanThemeGoogleMap();

                setState(() {
                  bottomPaddingOfMap = 255;
                });

              locateUserPosition();

              },
          ),

          //custom hamburger button for drawer or close
          Positioned(
            top: 45,
            left: 25,
            child: GestureDetector(
              onTap: () {
                if(openNavigationDrawer) {
                  sKey.currentState!.openDrawer(); //exibir hamburguer
                }
                else {
                  
                    // Chame a função para limpar a pesquisa e redefinir o texto
        clearSearchAndResetText();
        removeRequestAndRefresh();
        // Retorne ao estado anterior pronto para buscar um novo local
        Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));

                    
        // Retorne ao estado anterior pronto para buscar um novo local ESTE CODE ESTAVA TRAVANDO EM DEPURACAO
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const MySplashScreen()),
        // );
      }
               
              },
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, // Define a forma como um círculo
                  boxShadow: [
                            BoxShadow(
                              blurRadius: 3,
                              spreadRadius: 0.8,
                              color: Color.fromARGB(209, 78, 78, 78),
                              offset: Offset(0, 1),
                            ),
                          ],
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF222222), radius: 25, // tamanho do circle
                  child: Icon( //condicao se navdrawer hamburguer true, show menu icon, se navdrawer é false, show close icon
                   openNavigationDrawer ? Icons.menu 
                   : Icons.close, size: 33, //size do icone open e close
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          //UI for searching location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: 545, //altura card branco textos e locais para escolher
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow( //shadow no topo do container de positioned
                      blurRadius: 12,
                      spreadRadius: 2,
                      color: Color.fromARGB(209, 78, 78, 78),
                      offset: Offset(0, 8),
                    )
                  ]
                ),
                child: Padding(
                  padding:  const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column( //se pa voltar o const
                    children: [
                      //Partindo de:
                    Row(
                      children: [
                         const Icon(Icons.my_location, color: Color(0xFF222222)),
                           const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Seu local:',
                            style: TextStyle(color: Color(0xFF222222), fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              Provider.of<AppInfo>(context).userPickUpLocation != null 
                              ? "${(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0,34)}..."
                              : "endereço não encontrado",
                            style: const TextStyle(color: Color(0xFF222222), fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    //destino
                    GestureDetector(
                      onTap: () async {

                        //vai pra searchplacesscreen
                        var responseFromSearchScreen = await Navigator.push(context, MaterialPageRoute(builder: (c) => SearchPlacesScreen()));

                        if(responseFromSearchScreen == "destinoDefinido") {

                          setState(() {
                            openNavigationDrawer = false; //mudar drawer para icon close
                          });

                          //draw routes - draw polyline 
                          await drawPolylineFromOriginToDestination();
                        }
                      },
                      child: Row(
                        children: [
                           const Icon(Icons.search, color: Color(0xFF222222)),
                           const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Destino:',
                              style: TextStyle(color: Color(0xFF222222), fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                                Text( //CASO COMEÇAR DAR ERRO NA BUSCA DE LOCAL, VOLTAR O CÓDIGO ABAIXO
                                  Provider.of<AppInfo>(context).userDropOffLocation != null
                                      ? (Provider.of<AppInfo>(context).userDropOffLocation!.locationName!.length > 34
                                          ? "${Provider.of<AppInfo>(context).userDropOffLocation!.locationName!.substring(0, 34)}..."
                                          : Provider.of<AppInfo>(context).userDropOffLocation!.locationName!)
                                      : 'Toque para definir onde deseja ir',
                                  style: const TextStyle(color: Color(0xFF222222), fontSize: 14),
                                ),
                              // Text(
                              //   Provider.of<AppInfo>(context).userDropOffLocation != null 
                              //   ? Provider.of<AppInfo>(context).userDropOffLocation!.locationName!.substring(0,34) //substring 38 aqui deu bug, estudar
                              //   : 'Toque para definir onde deseja ir',
                              // style: const TextStyle(color: Color(0xFF222222), fontSize: 14),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity, height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          if(Provider.of<AppInfo>(context, listen: false).userDropOffLocation != null) {
                            saveRideRequestInformation();
                          }
                          else {
                            showRedSnackBar(context, 'Por favor, escolha para onde deseja ir.');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(250, 50),
                          backgroundColor: const Color(0xFF222222),
                          foregroundColor:  Colors.white,
                          textStyle: const TextStyle(fontSize: 16,
                          fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                        child: const Text("BUSCAR CORRIDA",
                        ),
                      ),
                    ),
                  ]
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }

  // Future<void> drawPolylineFromOriginToDestination() async CÓDIGO ABAIXO POSSIVELMENTE CORRIGIDO, TESTAR, SENÃO, VOLTAR PARA ESSE
  // {
  //   var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
  //   var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

  //   var originLatLng = LatLng(originPosition!.locationLatitude!, originPosition.locationLongitude!);
  //   var destinationLatLng = LatLng(destinationPosition!.locationLatitude!, destinationPosition.locationLongitude!);
  Future<void> drawPolylineFromOriginToDestination() async {
  var originPosition = Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
  var destinationPosition = Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

  if (originPosition == null || destinationPosition == null) {
    // Lida com a situação em que as posições de origem ou destino são nulas
    return;
  }

  var originLatLng = LatLng(originPosition.locationLatitude!, originPosition.locationLongitude!);
  var destinationLatLng = LatLng(destinationPosition.locationLatitude!, destinationPosition.locationLongitude!);

      showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(message: "Carregando..."));

    var directionDetailsInfo = await AssistantMethods.obtainOriginToDestinationDirectionDetails(originLatLng, destinationLatLng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });

    Navigator.pop(context);
  
    print("These são os points =");
    print(directionDetailsInfo!.e_points);

    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    pLineCoordinatesList.clear();

    if(decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();    

    setState(() {
    Polyline polyline = Polyline(
      color: const Color(0xFF222222),
      polylineId: const PolylineId("PolylineID"),
      jointType: JointType.round,
      //largura da linha
      width: 4,
      points: pLineCoordinatesList,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      //traço em pontinhos
      // patterns: const [PatternItem.dot, PatternItem.dot],
      geodesic: true,
      );

      polylineSet.add(polyline);
      });

      //condições para o zoom ajustar o mapa quando o desenho traçar a rota, aparecer correto na tela
      LatLngBounds boundsLatLng;
      if(originLatLng.latitude > destinationLatLng.latitude &&
      originLatLng.longitude > destinationLatLng.longitude) {
        boundsLatLng = LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
      }
      else if(originLatLng.longitude > destinationLatLng.longitude) {
        boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          );
      }
      else if(originLatLng.latitude > destinationLatLng.latitude) {
        boundsLatLng = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
          );
      }
      else {
        boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
      }

      newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

      //definindo os markers com ícones de partida e destino
      Marker originMarker = Marker(
        markerId: const MarkerId("originID"),
        //ao tocar no marker exibe endereço partida e texto
        infoWindow: InfoWindow(title: originPosition.locationName, snippet: "Partida"),
        position: originLatLng, 
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
      );
      Marker destinationMarker = Marker(
        markerId: const MarkerId("destinationID"),
        //ao tocar no marker exibe endereço destino e texto
        infoWindow: InfoWindow(title: destinationPosition.locationName, snippet: "Destino"),
        position: destinationLatLng, 
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
      );

      setState(() {
        markersSet.add(originMarker);
        markersSet.add(destinationMarker);
      });
      //círculo onde fica o pin do marker
      Circle originCircle = Circle(
        circleId: const CircleId("originID"),
        fillColor: const Color.fromRGBO(255, 255, 255, 0.459),
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.black87,
        center: originLatLng,
      );
      Circle destinationCircle = Circle(
        circleId: const CircleId("destinationID"),
        fillColor: const Color.fromRGBO(255, 255, 255, 0.459),
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.grey.shade700,
        center: destinationLatLng,
      );

      setState(() {
        circlesSet.add(originCircle);
        circlesSet.add(destinationCircle);
      });
  }

  initializeGeoFireListener()
  {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(userCurrentPosition!.latitude, 
    userCurrentPosition!.longitude, 10)!
    .listen((map) {
       // print(map);
        if (map != null) {
          var callBack = map['callBack'];

          //latitude will be retrieved from map['latitude']
          //longitude will be retrieved from map['longitude']

          switch (callBack) 
          {
            //cada driver que ficar online, pegamos as infos abaixo uid latlng e joga na lista
            case Geofire.onKeyEntered: 
              ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
              activeNearbyAvailableDriver.locationLatitude = map['latitude'];//
              activeNearbyAvailableDriver.locationLongitude = map['longitude'];//
              activeNearbyAvailableDriver.driverId = map['key'];// 
              // 3 linhas acima vai pegando o uid latlng de cada driver e jogando na lista abaixo
              GeoFireAssistant.activeNearbyAvailableDriversList.add(activeNearbyAvailableDriver);
              if(activeNearbyDriverKeysLoaded == true) 
              {
                displayActiveDriversOnUsersMap();
              }
              break;

             //quando cada driver ficar off
            case Geofire.onKeyExited:
              GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
              break;

            //enquanto driver se movimenta - atualizar driver location
            case Geofire.onKeyMoved:
              ActiveNearbyAvailableDrivers activeNearbyAvailableDriver = ActiveNearbyAvailableDrivers();
              activeNearbyAvailableDriver.locationLatitude = map['latitude'];//
              activeNearbyAvailableDriver.locationLongitude = map['longitude'];//
              activeNearbyAvailableDriver.driverId = map['key'];// 
              GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(activeNearbyAvailableDriver);
              displayActiveDriversOnUsersMap();
              break;

            //mostrar os drivers online no mapa de users
            case Geofire.onGeoQueryReady:
              activeNearbyDriverKeysLoaded = true;
              displayActiveDriversOnUsersMap();
              break;
          }
        }

        setState(() {});
   });
  }

displayActiveDriversOnUsersMap() 
{
  setState(() {
    markersSet.clear();
    circlesSet.clear();

    Set<Marker> driversMarkerSet = Set<Marker>();
    for(ActiveNearbyAvailableDrivers eachDriver in GeoFireAssistant.activeNearbyAvailableDriversList) {
      LatLng eachDriverActivePosition = LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

      Marker marker = Marker(
        markerId: MarkerId(eachDriver.driverId!),
        position: eachDriverActivePosition,
        icon: activeNearbyIcon!,
        // BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta)
        rotation: 360,
      );
      driversMarkerSet.add(marker);
    }

    setState(() {
      markersSet = driversMarkerSet;
    });
  });
}

// createActiveNearbyDriverIconMarker()
// {
//   if(activeNearbyIcon == null) 
//   {
//     ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(800, 800));
//     BitmapDescriptor.fromAssetImage(imageConfiguration, "images/pin.png").then((value) 
//     {
//       activeNearbyIcon = value;
//     });
//   }
// }

createActiveNearbyDriverIconMarker() {
  if (activeNearbyIcon == null) {
    ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: const Size(64, 64)); // Tamanho menor, por exemplo, 64x64
    BitmapDescriptor.fromAssetImage(imageConfiguration, "images/pin.png").then((value) {
      activeNearbyIcon = value;
    });
  }
}





}



 // else {
                //   //restart-refresh-minimize app programatically fechar
                //   //SystemNavigator.pop();
                //   //ou mandar para splashScreen?
                //   Navigator.push(context, MaterialPageRoute(builder: (c) => const MainScreen())
                //   );
                //   //clear field da localização digitada?
                //   //userDropOffLocation.Clear();
                
                  
                // }