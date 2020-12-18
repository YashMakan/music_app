import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Constants.dart';
import 'SizeConfig.dart';
import 'package:json_http_test/MusicBloc.dart';
import 'package:http/http.dart' as http;
import 'MusicModel.dart';

class MusicHome extends StatefulWidget {
  @override
  _MusicHomeState createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final musicBloc = BlocProvider.of<MusicBloc>(context);
    musicBloc.add(FetchMusic());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MusicBloc, MusicState>(
        builder: (context, state){
          if(state is MusicIsLoading)
            return Center(child : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),));
          else if(state is MusicIsLoaded){
            return DetailsLoaded(state.getMusic);
          }
          else
            return Center(child: Column(children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height/3,),
              Icon(Icons.warning,color: Colors.redAccent,size: SizeConfig.widthMultiplier*40,),
              Text("OOPS! Some Error has occured!", style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 3 * SizeConfig.textMultiplier,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ))
            ],),);
        },
      ),

    );
  }
}
////////////////////////////////////////////////////////////////////////////////
class DetailsLoaded extends StatefulWidget {
  MusicModel music;

  DetailsLoaded(this.music);

  @override
  _DetailsLoadedState createState() => _DetailsLoadedState();
}

class _DetailsLoadedState extends State<DetailsLoaded> {
  var arrSongList = new List<String>();
  bool visi=true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getIndex();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
          child: Row(
            children: <Widget>[
              Visibility(visible:visi,child: GestureDetector(onTap: (){
                setState(() {
                  visi?visi=false:visi=true;
                });
              },child: Icon(Icons.search, color: Colors.black,))),
              Visibility(visible: visi,child: Spacer()),
              Visibility(visible: !visi,child: Expanded(
                child: new TextField(
                  decoration: new InputDecoration(
                      border: new OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(10.0),
                        ),
                      ),
                      filled: true,
                      hintStyle: new TextStyle(color: Colors.grey[800]),
                      hintText: "Type in your text",
                      fillColor: Colors.white70),
                ),
              )),
              GestureDetector(child: Icon(visi?Icons.bookmark_border:Icons.clear, color: Colors.pink,),onTap: (){
                if(visi==false){
                  setState(() {
                    visi=true;
                  });
                }else{
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BookMarkPage(widget.music))
                  );
                }
              },),
            ],
          ),
        ),
        Row(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 34.0, top: 30.0),
            child: Text("Trending", style: GoogleFonts.lato(textStyle: TextStyle(
                color: Colors.black,
                fontFamily: 'Nunito-Regular',
                fontSize: 5.9 * SizeConfig.textMultiplier
            ),)),
          ),
          Icon(Icons.music_note,color: Colors.pink,)
        ],),
        SizedBox(height: SizeConfig.textMultiplier*3,),
        Expanded(
          child: Row(children: <Widget>[
            SizedBox(width: SizeConfig.textMultiplier*3.8,),
            Expanded(
              child: ListView.builder(itemCount: widget.music.length,itemBuilder: (context,i){
                return GestureDetector(onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondPage(name: widget.music.all_names[i]["track"]["track_name"],artist: widget.music.all_names[i]["track"]["artist_name"],album: widget.music.all_names[i]["track"]["album_name"],track_id: widget.music.all_names[i]["track"]["track_id"],exp: widget.music.all_names[i]["track"]["explicit"],)),
                    );
                },child: playListCard(i,widget.music.all_names[i]["track"]["track_name"], widget.music.all_names[i]["track"]["artist_name"], "2:38"),);
              }),
            )
          ],),
        )
      ],
    );
  }

  playListCard(index,String albumName, String artist, String duration) {
    return Container(
      padding: const EdgeInsets.only( bottom: 20.0),
      child: Row(
        children: <Widget>[
          Container(
            height: SizeConfig.textMultiplier*5.5,
            width: SizeConfig.textMultiplier*5.5,
            child: Center(child: Icon(Icons.music_note,color: Colors.white,size: SizeConfig.widthMultiplier*6,),),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(9.0),
            ),
          ),
          SizedBox(width: 20.0,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: SizeConfig.widthMultiplier*40,
                child: Text(albumName, style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 2 * SizeConfig.textMultiplier,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                ),),
              ),
              Text(artist, style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 1.7 * SizeConfig.textMultiplier,
                color: Colors.black,
              ),),
            ],
          ),
          Spacer(),
          Text(duration, style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 2.3 * SizeConfig.textMultiplier,
              color: Colors.black
          ),),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal:8.0),
            child: GestureDetector(
              onTap: () {
                var newArr=jsonEncode(widget.music.all_names);
                print(newArr);
                if(arrSongList.contains(index.toString())){
                  saveIndex(arrSongList);
                  complete(newArr);
                  setState(() {
                    arrSongList.remove(index.toString());
                  });
                }else{
                  saveIndex(arrSongList);
                  complete(newArr);
                  setState(() {
                    arrSongList.add(index.toString());
                  });
                }
                print(arrSongList);
              },
              child: Icon(arrSongList.contains(index.toString())
                  ? Icons.favorite
                  : Icons.favorite_border, color: Colors.red,),
            ),
          )
        ],
      ),
    );
  }
  getIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var v=prefs.getStringList('nameList');
    if(v!=null){
      setState(() {
        arrSongList=v;
      });
    }
  }

  saveIndex(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('nameList',value);
  }

  complete(value) async {
    print(value.runtimeType);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('complete', value);
  }
}
////////////////////////////////////////////////////////////////////////////////
class SecondPage extends StatefulWidget {
  final name;
  final artist;
  final album;
  final track_id;
  final exp;

  const SecondPage({Key key, this.name, this.artist, this.album, this.track_id, this.exp}) : super(key: key);
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String Lyrics='';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLyrics();
  }
  getLyrics() async {
    final result = await http.Client().get("https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=${widget.track_id}&apikey=2d782bc7a52a41ba2fc1ef05b9cf40d7");
    if(result.statusCode != 200)
      setState(() {
        Lyrics="Error 404";
      });
    else{
      final jsonDecoded = json.decode(result.body);
      setState(() {
        Lyrics=jsonDecoded['message']['body']['lyrics']['lyrics_body'].toString();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.pink[100],
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          'Now Playing',
          style: TextStyle(
              fontSize: 15.0,
              color: Colors.white,
              fontWeight: FontWeight.w400),
        ),
        actions: [
          Icon(
            Icons.more_horiz,
            color: Colors.white,
          ),
          SizedBox(width: 10.0,)
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(35.0),
              topRight: Radius.circular(35.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                height: size.height * 0.5,
                child: Center(child: Icon(Icons.music_note,color: Colors.white,size: SizeConfig.widthMultiplier*60,),),
                decoration: BoxDecoration(
                  color: Colors.pink,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.8),
                      blurRadius: 5,
                      offset: Offset(5, 7), // changes position of shadow
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        child: Text(
                          widget.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Spacer(),
                    widget.exp==1?Icon(
                      Icons.explicit,
                      color: Colors.pink,
                    ):Container()
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(children: <Widget>[
                  Text(
                    widget.artist,
                    style: TextStyle(
                        color: kLightColor,
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: SizeConfig.widthMultiplier*8,),
                  Flexible(
                    child: Text(
                      "["+widget.album+"]",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: kLightColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],)
              ),
              Container(
                margin: EdgeInsetsDirectional.only(top: 10.0),
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: double.infinity,
                child: LinearProgressIndicator(
                  backgroundColor: kLightColor2,
                  value: 0.09,
                  valueColor: AlwaysStoppedAnimation(Colors.pink),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Text(
                      '04:30',
                      style: TextStyle(
                          color: kLightColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    Text(
                      '06:30',
                      style: TextStyle(
                          color: kLightColor,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.playlist_add,
                      color: kLightColor,
                      size: 0.09 * size.width,
                    ),
                    Icon(
                      Icons.skip_previous,
                      color: Colors.grey,
                      size: 0.12 * size.width,
                    ),
                    Icon(
                      Icons.play_circle_outline,
                      color: Colors.black,
                      size: 0.18 * size.width,
                    ),
                    Icon(
                      Icons.skip_next,
                      color: Colors.grey,
                      size: 0.12 * size.width,
                    ),
                    Icon(
                      Icons.autorenew,
                      color: kLightColor,
                      size: 0.09 * size.width,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FullLyrics(Lyrics: Lyrics),)
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                  height: size.height * 0.5,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(19.0),
                    child: Text(Lyrics,style: TextStyle(
                        color: Colors.white,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold),),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.8),
                        blurRadius: 5,
                        offset: Offset(5, 7), // changes position of shadow
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
////////////////////////////////////////////////////////////////////////////////
class FullLyrics extends StatelessWidget {
  final Lyrics;

  const FullLyrics({Key key, this.Lyrics}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.pink,
      appBar: AppBar(backgroundColor: Colors.transparent,elevation: 0,),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top:10.0,left: 20,bottom: 30),
          child: Text(Lyrics.toString().split('...')[0]+'...',style: TextStyle(
              color: Colors.white,
              fontSize: 25.0,
              fontWeight: FontWeight.bold),),
        ),
      ),);
  }
}
////////////////////////////////////////////////////////////////////////////////

class BookMarkPage extends StatefulWidget {
  MusicModel music;

  BookMarkPage(this.music);

  @override
  _BookMarkPageState createState() => _BookMarkPageState();
}

class _BookMarkPageState extends State<BookMarkPage> {
  var indexes = new List<String>();
  var comp;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    get_complete();
    getIndex();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0),
            child: Row(
              children: <Widget>[
                Spacer(),
                GestureDetector(child: Icon(Icons.bookmark, color: Colors.pink,),onTap: (){
                  Navigator.pop(context);
                },),
              ],
            ),
          ),
          Row(children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 34.0, top: 30.0),
              child: Text("Favourites", style: GoogleFonts.lato(textStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Nunito-Regular',
                  fontSize: 5.9 * SizeConfig.textMultiplier
              ),)),
            ),
            Icon(Icons.music_note,color: Colors.pink,)
          ],),
          SizedBox(height: SizeConfig.textMultiplier*3,),
          Expanded(
            child: Row(children: <Widget>[
              SizedBox(width: SizeConfig.textMultiplier*3.8,),
              Expanded(
                child: ListView.builder(itemCount: indexes.length, itemBuilder: (context,i){
                  return GestureDetector(onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SecondPage(name: comp[int.parse(indexes[i])]["track"]["track_name"],artist: comp[int.parse(indexes[i])]["track"]["artist_name"],album: comp[int.parse(indexes[i])]["track"]["album_name"],track_id: comp[int.parse(indexes[i])]["track"]["track_id"],exp: comp[int.parse(indexes[i])]["track"]["explicit"],)),
                    );
                  },child: playListCard(i,comp[int.parse(indexes[i])]["track"]["track_name"], comp[int.parse(indexes[i])]["track"]["artist_name"], "2:38"),);
                }),
              )
            ],),
          )
        ],
      ),
    );
  }

  playListCard(index,String albumName, String artist, String duration) {
    return Container(
      padding: const EdgeInsets.only(right: 10.0, bottom: 20.0),
      child: Row(
        children: <Widget>[
          Container(
            height: SizeConfig.textMultiplier*5.5,
            width: SizeConfig.textMultiplier*5.5,
            child: Center(child: Icon(Icons.music_note,color: Colors.white,size: SizeConfig.widthMultiplier*6,),),
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(9.0),
            ),
          ),
          SizedBox(width: 20.0,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: SizeConfig.widthMultiplier*40,
                child: Text(albumName, style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 2 * SizeConfig.textMultiplier,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),),
              ),
              Text(artist, style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 1.7 * SizeConfig.textMultiplier,
                color: Colors.black,
              ),),
            ],
          ),
          Spacer(),
          Text(duration, style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 2.3 * SizeConfig.textMultiplier,
              color: Colors.black
          ),),
          SizedBox(width: 20.0,),
        ],
      ),
    );
  }
  getIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var v=prefs.getStringList('nameList');
    setState(() {
      indexes=v;
    });
  }

  get_complete() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var v=prefs.getString('complete');
    setState(() {
      comp=jsonDecode(v);
      print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      print(comp);
    });
  }
}