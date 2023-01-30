#!/bin/bash

firebase_path="${BASH_SOURCE%/*}/../firebase/"

echo "firebase functions: npm install"
(cd "${firebase_path}functions/"; npm install);
echo "bootstrap: npm install"
(cd "${firebase_path}bootstrap/"; npm install);
