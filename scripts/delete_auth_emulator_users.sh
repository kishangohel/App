#!/bin/bash

curl -H 'Authorization: Bearer owner' -X DELETE \
	'http://localhost:9099/emulator/v1/projects/dev-verifi/accounts'
