/**
* Example:
curl -X POST 'http://localhost:8080/sales/upload?header=true&autoMasters=true&ignoreTopRows=0' \
-H 'Content-Type: text/csv' \
-H "Authorization: Bearer $TOKEN" \
--data-binary @/Users/dhaneesh/applicate/sales_lite/sample.csv
  