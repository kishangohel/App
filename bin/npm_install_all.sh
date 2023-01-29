#!/bin/bash

firebase_path="${BASH_SOURCE%/*}/../firebase/"

echo "verifi-types: npm install"
(cd "${firebase_path}verifi-types/"; npm install);
echo "verifi-bootstrap: npm install"
(cd "${firebase_path}verifi-bootstrap/"; npm install);
echo "firebase functions: npm install"
(cd "${firebase_path}functions/"; npm install);
