import 'package:chofair_user/assistants/request_assistant.dart';
import 'package:chofair_user/global/global.dart';
import 'package:chofair_user/global/map_key.dart';
import 'package:chofair_user/info_handler/app_info.dart';
import 'package:chofair_user/models/direction_details_info.dart';
import 'package:chofair_user/models/directions.dart';
import 'package:chofair_user/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class AssistantMethods
{

  static Future<String> searchAddressForGeoCoordinates(Position position, context) async {
    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    var requestResponse = await RequestAssistant.receiveRequest(apiUrl);
    if(requestResponse != "Sem resposta. Tente mais tarde") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo() async
  {
    currentFirebaseUser = fAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance
    .ref()
    .child("users")
    .child(currentFirebaseUser!.uid);

    userRef.once().then((snap)
    {
      if (snap.snapshot.value != null) 
      {
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);        
      }
    });
  }
  //pegar origem to destination para traçar rota usando API Direction Google
  static Future<DirectionDetailsInfo?> obtainOriginToDestinationDirectionDetails(LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails = 
    "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
  
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirectionDetails);

    if(responseDirectionApi == "Sem resposta. Tente mais tarde") {
      return null;
    }
    //receber resposta da API Directions
    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    
     directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
     directionDetailsInfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

     directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
     directionDetailsInfo.duration_value = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

     return directionDetailsInfo;
  }

//tarifa 1
  // static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo) {
  //   double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 2; // 01 doll por minuto 
  //   double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 2500); // doll por km?

  //   //dollar ex: U$1
  //   double totalFareAmount = timeTraveledFareAmountPerMinute / distanceTraveledFareAmountPerKilometer;

  //   // double localCurrencyTotalFare = totalFareAmount * 5;

  //   return double.parse(totalFareAmount.toStringAsFixed(2)); //23.123456 )
  // }



  ///tarifa 2
//   static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo) {
//   // Converter a duração para minutos
//   // double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.50;
  
//   // Converter a distância para quilômetros
//   double distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 1000) * 2.50;
  
//   // Calcular o valor total da tarifa
//   // double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
  
//   return double.parse(distanceTraveledFareAmountPerKilometer.toStringAsFixed(2));
// }






// SOMENTE POR KM

static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo) {
  // Converter a duração para minutos
  double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.04; // 0,50 por minuto

  // Converter a distância para quilômetros
  double distanceTraveledFareAmountPerKilometer;
  
  if (directionDetailsInfo.distance_value! <= 4000) {
    distanceTraveledFareAmountPerKilometer = 8.5; // Valor fixo de 8,50 para distâncias menores que 4km
  } 
  else if(directionDetailsInfo.distance_value! <= 8000) {
    distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 1000) * 2.10; // 2,10 por quilômetro
  }
  else if (directionDetailsInfo.distance_value! <= 10000) {
    distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 1000) * 2.10; // 2,10 por quilômetro
  }
  else {
    distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 1000) * 1.65; // 2,10 por quilômetro
  }

  // Calcular o valor total da tarifa
  double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
  
  return double.parse(totalFareAmount.toStringAsFixed(2));
}







// static double calculateFareAmountFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo) {
//   // Converter a duração para minutos
//   double timeTraveledFareAmountPerMinute = (directionDetailsInfo.duration_value! / 60) * 0.50; // 0,50 por minuto

//   // Converter a distância para quilômetros
//   double distanceTraveledFareAmountPerKilometer;
  
//   if (directionDetailsInfo.distance_value! <= 4000) {
//     distanceTraveledFareAmountPerKilometer = 8.5; // Valor fixo de 8,50 para distâncias menores que 4km
//     if (directionDetailsInfo.duration_value! > 600) {
//       // Cobrar R$0,50 por minuto extra se o tempo de viagem for maior que 10 minutos
//       timeTraveledFareAmountPerMinute += ((directionDetailsInfo.duration_value! - 600) / 60) * 0.50;
//     }
//   } 
//   else if (directionDetailsInfo.distance_value! <= 8000) {
//     distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 1000) * 2.20; // 2,20 por quilômetro
//   }
//   else if (directionDetailsInfo.distance_value! <= 10000) {
//     distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 1000) * 1.90; // 1,90 por quilômetro
//   }
//   else {
//     distanceTraveledFareAmountPerKilometer = (directionDetailsInfo.distance_value! / 1000) * 1.65; // 1,65 por quilômetro
//   }

//   // Calcular o valor total da tarifa
//   double totalFareAmount = timeTraveledFareAmountPerMinute + distanceTraveledFareAmountPerKilometer;
  
//   return double.parse(totalFareAmount.toStringAsFixed(2));
// }


} 