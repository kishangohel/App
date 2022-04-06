import 'package:bloc/bloc.dart';
import 'package:verifi/blocs/tab/tab_event.dart';
import 'package:verifi/models/app_tab.dart';

class TabBloc extends Bloc<TabEvent, AppTab> {
  TabBloc() : super(AppTab.create(AppTabEnum.feed)) {
    on<UpdateTab>(_onUpdateTab);
  }

  void _onUpdateTab(UpdateTab event, Emitter<AppTab> emit) {
    emit(event.tab);
  }
}
