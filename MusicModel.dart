class MusicModel{
  final track_id;
  final length;
  final all_names;
  MusicModel(this.track_id, this.length, this.all_names);

  factory MusicModel.fromJson(List <dynamic> json){
    return MusicModel(
      json[0],
      json.length,
      json
    );
  }
}