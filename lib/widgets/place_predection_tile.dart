import 'package:chofair_user/assistants/request_assistant.dart';
import 'package:chofair_user/global/map_key.dart';
import 'package:chofair_user/info_handler/app_info.dart';
import 'package:chofair_user/models/directions.dart';
import 'package:chofair_user/widgets/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:chofair_user/models/predicted_places.dart';
import 'package:provider/provider.dart';

class PlacePredictionTileDesign extends StatelessWidget
{
  final PredictedPlaces? predictedPlaces;

  const PlacePredictionTileDesign({super.key, this.predictedPlaces});

  getPlaceDirectionDetails(String? placeId, context) async {
    showDialog(context: context, builder: (BuildContext context) => ProgressDialog(
      message: "Definindo destino...",
      ),
    );

    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey ";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    Navigator.pop(context);

    if(responseApi == "Sem resposta. Tente mais tarde") {
      return;
    }
    if(responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

      Navigator.pop(context, "destinoDefinido");
      
    }

  }

  @override
  Widget build(BuildContext context)
  {
    return ElevatedButton(
      onPressed: () {
        getPlaceDirectionDetails(predictedPlaces!.place_id, context);
      },
      style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all(Colors.white)), // Cor de fundo branca dos ro
        child: Row(
          children: [
            const Icon(
              Icons.add_location,
              color: Color(0xFF222222),
            ),
      
            const SizedBox(width: 5.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, //alterar esse cross
                children: [
                  const SizedBox(height: 8.0),
                  Text(
                    predictedPlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                     style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 2.0),
      
                   Text(
                    predictedPlaces!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF222222),
                    ),
                  ),
                  const SizedBox(height: 10.0),
      
                   
                ],
              ),
            )
          ],
        ),
      )
    ;
  }
}