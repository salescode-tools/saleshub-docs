#!/bin/bash

# Configuration
BASE_URL="http://localhost:8080"
TENANT_ID="pepsi"
PHONE_NUMBER="9876543210"
COUNTRY_CODE="+91"

echo "--------------------------------------------------"
echo "Starting OTP Registration Flow"
echo "Tenant: $TENANT_ID"
echo "Phone: $PHONE_NUMBER"
echo "--------------------------------------------------"

# 1. Generate OTP
echo ""
echo "[1] Generating OTP..."
GENERATE_RESPONSE=$(curl -s -X POST "$BASE_URL/otp/generate" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: $TENANT_ID" \
  -d "{
    \"countryCode\": \"$COUNTRY_CODE\",
    \"phoneNumber\": \"$PHONE_NUMBER\"
  }")

echo "Response: $GENERATE_RESPONSE"

# Extract Token and OTP (using jq or grep/sed fallback)
if command -v jq &> /dev/null; then
  TOKEN=$(echo "$GENERATE_RESPONSE" | jq -r '.token')
  OTP=$(echo "$GENERATE_RESPONSE" | jq -r '.otp')
else
  # Fallback for environments without jq
  TOKEN=$(echo "$GENERATE_RESPONSE" | grep -o '"token":"[^"]*' | cut -d'"' -f4)
  OTP=$(echo "$GENERATE_RESPONSE" | grep -o '"otp":"[^"]*' | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
  echo "Error: Failed to get token"
  exit 1
fi

echo "Token: $TOKEN"
echo "OTP: $OTP"

# 2. Confirm OTP
echo ""
echo "[2] Confirming OTP..."
CONFIRM_RESPONSE=$(curl -s -X POST "$BASE_URL/otp/confirm" \
  -H "Content-Type: application/json" \
  -H "X-Tenant-ID: $TENANT_ID" \
  -d "{
    \"token\": \"$TOKEN\",
    \"otp\": \"$OTP\"
  }")

echo "Response: $CONFIRM_RESPONSE"

# Check if existing user
if command -v jq &> /dev/null; then
  IS_EXISTING=$(echo "$CONFIRM_RESPONSE" | jq -r '.isExistingUser')
else
  IS_EXISTING=$(echo "$CONFIRM_RESPONSE" | grep -o '"isExistingUser":[^,}]*' | cut -d':' -f2 | tr -d ' ')
fi

echo "Is Existing User: $IS_EXISTING"

if [ "$IS_EXISTING" == "true" ]; then
  # 3a. Login
  echo ""
  echo "[3a] User exists. Logging in..."
  LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login-otp" \
    -H "Content-Type: application/json" \
    -H "X-Tenant-ID: $TENANT_ID" \
    -d "{
      \"token\": \"$TOKEN\"
    }")
  echo "Login Response: $LOGIN_RESPONSE"

else
  # 3b. Register
  echo ""
  echo "[3b] New user. Registering..."
  REGISTER_RESPONSE=$(curl -s -X POST "$BASE_URL/users/register-otp" \
    -H "Content-Type: application/json" \
    -H "X-Tenant-ID: $TENANT_ID" \
    -d "{
      \"token\": \"$TOKEN\",
      \"firstName\": \"Test\",
      \"lastName\": \"User\",
      \"email\": \"test.user@example.com\",
      \"orgType\": \"RETAILER\"
    }")
  echo "Register Response: $REGISTER_RESPONSE"
fi

echo ""
echo "--------------------------------------------------"
echo "Flow Complete"
echo "--------------------------------------------------"
