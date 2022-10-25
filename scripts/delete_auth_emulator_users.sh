#!/bin/bash

curl -H 'Authorization: Bearer owner' -X DELETE \
	'http://localhost:9099/emulator/v1/projects/bionic-water-366401/accounts'
