import datetime
import json
import sys

input_file = sys.argv[1]

json_obj = None
with open(input_file) as f:
    json_obj = json.load(f)

data = json_obj["data"]

for doc in data:
    now = datetime.datetime.now()
    data[doc]["LastValidated"] = {
        "__time__": now.strftime("%Y-%m-%dT%T.%fZ"),
    }
    data[doc]["SubmittedBy"] = "0" * 28

json_obj["data"] = data

with open("output.json", "w") as f:
    json.dump(json_obj, fp=f)
