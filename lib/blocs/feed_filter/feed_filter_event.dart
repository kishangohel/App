import 'package:equatable/equatable.dart';
import 'package:verifi/models/models.dart';

class FeedFilterEvent extends Equatable {
  const FeedFilterEvent();

  @override
  List<Object> get props => [];

}

class FeedFilterUpdate extends FeedFilterEvent {
  final FeedFilter feedFilter;
  const FeedFilterUpdate(this.feedFilter);

  @override
  List<Object> get props => [];

  @override
  String toString() => 'FeedFilterUpdate: { }';
}