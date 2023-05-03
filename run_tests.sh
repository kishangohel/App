#!/bin/bash

# flutter test --coverage \
# 	./test/src/features/authentication/presentation/phone_number/*_test.dart
# if [ $? -eq 0 ]; then
# 	lcov --remove coverage/lcov.info 'lib/**/*.g.dart' -o coverage/lcov.info
# 	genhtml coverage/lcov.info -o coverage/html
#
# fi

flutter test \
	./test/src/features/authentication/auth_flow_test.dart
