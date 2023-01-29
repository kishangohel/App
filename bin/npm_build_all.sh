#!/bin/bash

firebase_path="${BASH_SOURCE%/*}/../firebase/"

echo "verifi-types: npm run build"
(cd "${firebase_path}verifi-types/"; npm run build);
echo "verifi-bootstrap: npm run build"
(cd "${firebase_path}verifi-bootstrap/"; npm run build);
echo "firebase functions: npm run build"
(cd "${firebase_path}functions/"; npm run build);
