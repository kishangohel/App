#!/bin/bash

curl -H 'Authorization: Bearer owner' -X DELETE \
	http://localhost:9099/emulator/v1/projects/verifi-5db5b/accounts
