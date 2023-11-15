import 'package:chofair_user/assistants/request_assistant.dart';
import 'package:chofair_user/global/map_key.dart';
import 'package:chofair_user/models/predicted_places.dart';
import 'package:chofair_user/widgets/place_predection_tile.dart';
import 'package:flutter/material.dart';

class SearchPlacesScreen extends StatefulWidget {
 

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {

  List<PredictedPlaces> placesPredictedList = [];

  void findPlaceAutoCompleteSearch(String inputText) async
  {
    if(inputText.length > 1)
    {
      String urlAutoCompleteSearch = 
      "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:BR";

      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if(responseAutoCompleteSearch == "Sem resposta. Tente mais tarde")
      {
        return;
      }
      if(responseAutoCompleteSearch["status"] == "OK")
      {
        var placePredictions = responseAutoCompleteSearch["predictions"];

        var placePredictionsList = (placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // aqui pode ter uma imagem com logo ou como buscar...
      body: Column(
        children: [
          //search place UI
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFE0E0E0),
                  blurRadius: 10,
                  spreadRadius: 0.5,
                  offset: Offset(0.1, 
                  0.1),
                )
              ]
            ),
            
          child: Padding(
            
            padding: const EdgeInsets.all(18.0),
            child: Column(
              
              children: [
                
                const SizedBox(height: 25),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const Center(
                      child: Text(
                        "Para onde deseja ir?",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF222222),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(
                      Icons.adjust_sharp,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          autofocus: true, //focus here
                          onChanged: (valueTyped) {
                            findPlaceAutoCompleteSearch(valueTyped);          
                          },
                          decoration: const InputDecoration(
                            hintText: "Digite seu destino", iconColor: Color(0xFF222222),
                            fillColor: Color(0xFFEBEBEB),
                            filled: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(
                              left: 11.0,
                              top: 14.0,
                              bottom: 8.0,
                            ),
                             prefixIcon: Icon(
                                    Icons.search,
                                    color: Color.fromARGB(188, 34, 34, 34),
                                  ),
                          ),
                        ),
                      ),
                    )
                  ],
                )
            ]),
          ),
          ),

          //display place predictions result
          (placesPredictedList.length > 0) 
          ? Expanded(
            child: ListView.separated(
              itemCount: placesPredictedList.length,
              physics: const ClampingScrollPhysics(), //pediu const, se der erro, retirar
              itemBuilder: (context, index)
              {
                return PlacePredictionTileDesign(
                  predictedPlaces: placesPredictedList[index], 
                );
              },
              separatorBuilder: (BuildContext context,  int index)
              {
                return const Divider(
                  height: 1,
                  color: Colors.grey,
                  thickness: 1,
                );
              }
            ),
          ) 
          : Container(),
        ],
      ),
    );
  }
}