# OTP Registration API Documentation

This document outlines the API endpoints for user registration using OTP (One-Time Password) verification. In this flow, the user's phone number serves as their username.

## Overview

The registration process consists of three steps:
1.  **Generate OTP**: Request an OTP for a specific phone number and tenant (via header).
2.  **Confirm OTP**: Verify the received OTP code to get a verified session token.
3.  **Register/Login**: Create user or login using the verified session token.

**Common Headers:**
- `X-Tenant-ID`: Required for all OTP endpoints to identify the tenant.

---

## 1. Generate OTP

**POST** `/otp/generate`

Generates a temporary OTP session.
*Note: For development/testing purposes, the OTP code is currently returned in the response.*

**Request Body:**
```json
{
  "countryCode": "+91",
  "phoneNumber": "9876543210"
}
```

**Response:**
```json
{
  "token": "550e8400-e29b-41d4-a716-446655440000",
  "otp": "123456",
  "expiresAt": "2023-10-27T10:10:00"
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/otp/generate \
  -H 'Content-Type: application/json' \
  -H 'X-Tenant-ID: default' \
  -d '{
    "countryCode": "+91",
    "phoneNumber": "9876543210"
  }'
```

---

## 2. Confirm OTP

**POST** `/otp/confirm`

Verifies the OTP code provided by the user. If successful, the session token is marked as verified.

**Request Body:**
```json
{
  "token": "550e8400-e29b-41d4-a716-446655440000",
  "otp": "123456"
}
```

**Response:**
```json
{
  "message": "OTP verified successfully",
  "token": "550e8400-e29b-41d4-a716-446655440000",
  "isExistingUser": true
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/otp/confirm \
  -H 'Content-Type: application/json' \
  -H 'X-Tenant-ID: default' \
  -d '{
    "token": "550e8400-e29b-41d4-a716-446655440000",
    "otp": "123456"
  }'
```

---

## 3. Login with OTP (If User Exists)

**POST** `/auth/login-otp`

Logs in an existing user using the verified OTP token.
- Use this if `isExistingUser` is `true` in the confirm response.

**Request Body:**
```json
{
  "token": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response:** `200 OK`
```json
{
  "tenantId": "default",
  "userId": 123,
  "username": "9876543210",
  "roles": ["MEMBER"],
  "token": "jwt-token...",
  "expiresAt": "..."
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/auth/login-otp \
  -H 'Content-Type: application/json' \
  -H 'X-Tenant-ID: default' \
  -d '{
    "token": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

---

## 4. Register User with OTP (If New User)

**POST** `/users/register-otp`

Registers a new user using the verified OTP token.
- Use this if `isExistingUser` is `false` in the confirm response.
- The **username** will be automatically set to the **phone number**.
- If **password** is not provided, a random one will be generated.

**Request Body:**
```json
{
  "token": "550e8400-e29b-41d4-a716-446655440000",
  "firstName": "Jane",
  "lastName": "Doe",
  "email": "jane.doe@example.com",
  "orgCode": "RET-001",
  "orgType": "RETAILER",
  "extendedAttr": {
    "region": "North"
  }
}
```

**Response:** `201 Created`
```json
{
  "id": 123,
  "firstName": "Jane",
  "lastName": "Doe",
  "username": "9876543210",
  "email": "jane.doe@example.com",
  "phone": "9876543210",
  ...
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/users/register-otp \
  -H 'Content-Type: application/json' \
  -H 'X-Tenant-ID: default' \
  -d '{
    "token": "550e8400-e29b-41d4-a716-446655440000",
    "firstName": "Jane",
    "lastName": "Doe",
    "email": "jane.doe@example.com",
    "orgCode": "RET-001"
  }'
```
