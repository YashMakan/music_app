import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:json_http_test/MusicModel.dart';

class MusicRepo{

  Future<MusicModel> getMusic() async{
    final result = await http.Client().get("https://api.musixmatch.com/ws/1.1/chart.tracks.get?apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7");
    
    if(result.statusCode != 200)
      throw Exception();

    return parsedJson(result);
  }

  MusicModel parsedJson(final response){
    final jsonDecoded = json.decode(response.body);
    final jsonWeather = jsonDecoded["message"]["body"]["track_list"];
    print(jsonWeather[0]["track"]["track_name"]);
    print(jsonWeather.length);
    return MusicModel.fromJson(jsonWeather);
  }
}