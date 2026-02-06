curl -X POST http://localhost:8080/auth/user-register \
-H 'Content-Type: application/json' \
-d '{
"tenantId": "pepsi",
"firstName": "John",
"lastName": "Doe",
"username": "johndoe_retailer",
"password": "SecurePassword123!",
"email": "john.doe@example.com",
"phone": "9876543210",
"orgType": "RETAILER",
"otpEnabled": false,
"extendedAttr": {
"region": "North",
"preferences": {
"notifications": true
}
}
}'
{"id":23152,"username":"johndoe_retailer","authType":"USERNAME_PASSWORD","isActive":true,"failedAttempts":0}