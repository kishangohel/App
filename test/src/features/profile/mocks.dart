import 'package:mocktail/mocktail.dart';
import 'package:verifi/src/features/authentication/domain/current_user_model.dart';

class MockCurrentUserStream extends Mock implements Stream<CurrentUser?> {}
