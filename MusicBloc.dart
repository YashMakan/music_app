import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:json_http_test/MusicModel.dart';
import 'package:json_http_test/MusicRepo.dart';

class MusicEvent extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];

}

class FetchMusic extends MusicEvent{

  @override
  // TODO: implement props
  List<Object> get props => [];
}

class ResetMusic extends MusicEvent{

}

class MusicState extends Equatable{
  @override
  // TODO: implement props
  List<Object> get props => [];

}


class MusicIsNotSearched extends MusicState{

}

class MusicIsLoading extends MusicState{

}

class MusicIsLoaded extends MusicState{
  final _music;

  MusicIsLoaded(this._music);

  MusicModel get getMusic => _music;

  @override
  // TODO: implement props
  List<Object> get props => [_music];
}

class MusicIsNotLoaded extends MusicState{

}

class MusicBloc extends Bloc<MusicEvent, MusicState>{

  MusicRepo musicRepo;

  MusicBloc(this.musicRepo);

  @override
  // TODO: implement initialState
  MusicState get initialState => MusicIsLoading();
  @override
  Stream<MusicState> mapEventToState(MusicEvent event) async*{
    // TODO: implement mapEventToState
    if(event is FetchMusic){
      try{
        MusicModel music = await musicRepo.getMusic();
        yield MusicIsLoaded(music);
      }catch(_){
        print(_);
        yield MusicIsNotLoaded();
      }
    }else if(event is ResetMusic){
      yield MusicIsNotSearched();
    }
  }

}
