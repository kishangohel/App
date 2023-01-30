#!/bin/bash

firebase_path="${BASH_SOURCE%/*}/../firebase/"

echo "firebase functions: npm run build"
(cd "${firebase_path}functions/"; npm run build);

echo "bootstrap: npm run build"
(cd "${firebase_path}bootstrap/"; npm run build);
