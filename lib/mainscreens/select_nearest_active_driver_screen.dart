import 'package:chofair_user/assistants/assistant_methods.dart';
import 'package:chofair_user/global/global.dart';
import 'package:chofair_user/widgets/snack_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';

class SelectNearestActiveDriverScreen extends StatefulWidget {
  
  DatabaseReference? referenceRideRequest;

  SelectNearestActiveDriverScreen({this.referenceRideRequest});

  @override
  State<SelectNearestActiveDriverScreen> createState() => _SelectNearestActiveDriverScreenState();
}

 List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polylineSet = {};

  //ícone marcador atual e destino após traçar rota
  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};
// String marcaLength = dList.toString();


class _SelectNearestActiveDriverScreenState extends State<SelectNearestActiveDriverScreen> {


  // void removeRequestAndRefresh() {
  //   // Remova a solicitação de corrida do banco de dados aqui
  //   // ...
  //   // Após a remoção, atualize a interface do usuário
  //   setState(() {
  //     // Atualize a interface do usuário aqui
  //     // Você pode definir dList para uma nova lista vazia ou null, por exemplo
  //     dList = [];
  //   });
  // }

  String fareAmount = "";
  getFareAmountAccordingToVehicleType(int index) {
    if(tripDirectionDetailsInfo != null) {
      if(dList[index]["car_details"]["service"].toString() == "Moto") {
      fareAmount =  (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!) / 2).toStringAsFixed(2); //valor MOTO
      }
      if(dList[index]["car_details"]["service"].toString() == "Carro") {
        fareAmount =  (AssistantMethods.calculateFareAmountFromOriginToDestination(tripDirectionDetailsInfo!)).toString(); //valor CARRO
      }
    } 
    return fareAmount;   
  }

  @override
  Widget build(BuildContext context) {
       // Função para limpar a pesquisa e redefinir o texto "Toque para definir onde deseja ir"
  // void clearSearchAndResetText() {
  //   Provider.of<AppInfo>(context, listen: false).userDropOffLocation = null;
  // }
    return  Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 100,
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          "Motoristas próximos de você",
          style: TextStyle(
            fontSize: 18
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.close, color: Colors.white),
            onPressed: () {
              widget.referenceRideRequest!.remove();
/* ESTUDAR ESSE CÓDIGO PARA REMOVER A REQUEST SE CLICAR EM CLOSE SEM FECHAR O APP
   void driverIsOfflineNow() async {
  // Remove a localização do motorista do "activeDrivers" usando Geofire
  await Geofire.removeLocation(currentFirebaseUser!.uid);

  // Acesse a referência do Firebase
  DatabaseReference driverRef = FirebaseDatabase.instance.ref()
      .child("drivers")
      .child(currentFirebaseUser!.uid);

  // Remova o nó "newRideStatus"
  DatabaseReference newRideStatusRef = driverRef.child("newRideStatus");
  await newRideStatusRef.remove();

  // Remova o motorista do nó "activeDrivers"
  DatabaseReference activeDriversRef = FirebaseDatabase.instance.ref().child("activeDrivers");
  await activeDriversRef.child(currentFirebaseUser!.uid).remove();
}*/

              showDarkSnackBar(context, 'Você cancelou solicitação... Abra o app novamente para uma nova corrida :)');
              Future.delayed(const Duration(milliseconds: 5000), () async
              {       
                SystemNavigator.pop();
              }
       );
   } ),
      ),
      
      body: ListView.builder(
        itemCount: dList.length,
        itemBuilder: (BuildContext context, int index) {
          return  SizedBox(
            height: 146, // Define a altura do card
            child: Card(
              color: Colors.white,
              elevation: 3,
              shadowColor: const Color.fromRGBO(204, 204, 204, 0.409),
              margin: const EdgeInsets.all(4),
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Image.asset(
                    "images/${dList[index]["car_details"]["service"]}.png", //aqui puxa imagem, ToDo imagem do driver ou carro
                    width: 75, height: 75,
                  ),
                ),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   dList[index]["name"],
                  //   style: const TextStyle(
                  //     fontSize: 16,
                  //     color: Color(0xFF222222)
                  //   ),
                  // ), 
                  Text(
                      dList[index]["name"].length > 15
                          ? '${dList[index]["name"].substring(0, 15)}...'  // Limita a 15 caracteres
                          : dList[index]["name"],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF222222)
                      ),
                    ),
                      Text( 
                        dList[index]["car_details"]["marca"],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF222222),
                        ),
                      ), 

                      Text(
                        dList[index]["car_details"]["modelo"],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF222222),
                        ),
                      ),
                    
                  Text( 
                        "Placa:  ${dList[index]["car_details"]["placa"]}",
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF222222),
                        ),
                      ),
                  SmoothStarRating(
                    rating: 3.5,
                    color: Colors.amber,
                    borderColor: Colors.amber,
                    allowHalfRating: true,
                    starCount: 5,
                    size: 15,
                  ),
                ],
              ),
              
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("R\$ " + getFareAmountAccordingToVehicleType(index),
                    style: const TextStyle(
                      fontSize:14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    tripDirectionDetailsInfo != null
                    ? tripDirectionDetailsInfo!.distance_text!
                    :"",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tripDirectionDetailsInfo != null
                    ? tripDirectionDetailsInfo!.duration_text!
                    :"",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222222),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              ),
            ),
          );
        },
        ),
    );
  }
}

    // //ESSES CÓDIGOS TODOS NÃO LIMPAM CACHE E DOBRAM OS MOTORISTAS MESMO SE FUNCIONAR, POR ENQUANTO FECHAR APP PARA NÃO REPETIR DRIVER
 // removeRequestAndRefresh(); AQUI FUNCIONOU, POREM aINDA NÃO LIMPOU OS DRIVERS DO DB
              // clearSearchAndResetText();
              // MyApp.restartApp(context);
              //  Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
              //deletar a solicitação de corrida do DB
      //        Future.delayed(const Duration(milliseconds: 2000), () ////SE DFER ERRO 
      // {
      //   MyApp.restartApp(context);
      // } 
      //  );
              
              // removeRequestAndRefresh();
              
              
      // setState(() {
      //   removeRequestAndRefresh(); //NAO TA LIMPANDO A LISTA, SOMENTE FECHANDO APP
      // });
      // showDarkSnackBar(context, 'Limpando pesquisa. Recarregando...');
      // Future.delayed(const Duration(milliseconds: 4000), () async
      // {       
        
      //   Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
      //   clearSearchAndResetText(); //limpa
      // }
      //  );
      
      // return;
      // //ESSES CÓDIGOS TODOS NÃO LIMPAM CACHE E DOBRAM OS MOTORISTAS MESMO SE FUNCIONAR, POR ENQUANTO FECHAR APP PARA NÃO REPETIR DRIVER
      //       }