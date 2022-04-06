import 'package:bloc/bloc.dart';
import 'package:verifi/blocs/blocs.dart';
import 'package:verifi/models/models.dart';

class FeedFilterBloc extends Bloc<FeedFilterEvent, FeedFilter> {
  FeedFilterBloc() : super(FeedFilter()) {
    on<FeedFilterUpdate>(_onFeedFilterUpdate);
  }

  void _onFeedFilterUpdate(FeedFilterUpdate event, Emitter<FeedFilter> emit) {
    emit(event.feedFilter);
  }
}
