# 🔐 User Registration API Documentation

This document details the public registration endpoints available in Salescodeai Saleshub. These endpoints are accessible without a JWT token to facilitate new user and tenant onboarding.

---

## 📋 Table of Contents
- [Overview](#-overview)
- [OTP Flow](#-otp-flow)
- [Endpoints](#-endpoints)
  - [1. Generate OTP](#1-generate-otp)
  - [2. Confirm OTP](#2-confirm-otp)
  - [3. Register via OTP (Auto-Login)](#3-register-via-otp-auto-login)
  - [4. Register Standalone User (Manual)](#4-register-standalone-user-manual)
  - [5. Register Tenant & Admin](#5-register-tenant--admin)
  - [6. Associate Outlet](#6-associate-outlet)
- [Configuration](#-configuration)

---

## 🏗️ Overview

The platform supports two primary registration flows:
1. **Tenant Registration**: Creates a new business tenant and its initial `TENANT_ADMIN` user.
2. **User Registration**: Adds a new user to an existing tenant. This flow can be configured to require OTP verification for increased security.

---

## 🔄 OTP Flow

When OTP verification is enabled (either via request flag or tenant settings), the registration process follows these steps:

1. **Generate**: Client calls `/otp/generate` with a phone number.
2. **Confirm**: User enters the received code; client calls `/otp/confirm` to obtain a **verified session token**.
3. **Register**: 
    - For a streamlined mobile flow, client calls **`/users/register-otp`** (using phone as username). This returns a JWT token immediately.
    - Alternatively, client calls `/auth/user-register` including the `otpToken`.

---

## 🚀 Endpoints

### 1. Generate OTP
**`POST /otp/generate`**

Initiates an OTP challenge for a specific phone number.

**Headers:**
- `X-Tenant-Id`: Required (e.g., `dhaneesh`)

**Request Body:**
```json
{
  "phoneNumber": "+919876543210",
  "countryCode": "+91"
}
```

**Response (200 OK):**
```json
{
  "token": "uuid-session-token",
  "otp": "123456",
  "expiresAt": "2025-11-21T10:00:00"
}
```
> **Note:** In dummy/testing mode, the OTP is returned in the response. In production, it is sent via SMS.

---

### 2. Confirm OTP
**`POST /otp/confirm`**

Verifies the OTP code entered by the user.

**Headers:**
- `X-Tenant-Id`: Required

**Request Body:**
```json
{
  "token": "uuid-session-token",
  "otp": "123456"
}
```

**Response (200 OK):**
```json
{
  "message": "OTP verified successfully",
  "token": "uuid-session-token",
  "isExistingUser": false
}
```

---

### 3. Register via OTP (Auto-Login)
**`POST /users/register-otp`**

Registers a new user (using their phone number as the username) and returns an authentication token immediately.

**Headers:**
- `X-Tenant-Id`: Required
- `Content-Type: application/json`

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `token` | string | ✅ | Verified OTP token from `/otp/confirm` |
| `firstName` | string | ✅ | User's first name |
| `lastName` | string | ❌ | User's last name |
| `email` | string | ❌ | Email address |
| `password` | string | ❌ | Optional password (system generates one if omitted) |
| `orgType` | string | ❌ | Defaults to `RETAILER` |
| `orgCode` | string | ❌ | Optional organization code |

**Response (201 Created):**
Returns an `AuthResponse` object, identical to the login response.
```json
{
  "tenantId": "pepsi",
  "userId": 567,
  "username": "9876543210",
  "token": "eyJhbGciOiJIUzI1Ni...",
  "roles": ["MEMBER"],
  "orgType": "RETAILER",
  "orgCode": null,
  "expiresAt": "2026-02-05T13:00:00Z"
}
```

---

### 4. Register Standalone User (Manual)
**`POST /auth/user-register`**

Registers a new user into an existing tenant.

**Headers:**
- `Content-Type: application/json`

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `tenantId` | string | ✅ | Target tenant ID |
| `username` | string | ✅ | Desired username |
| `password` | string | ✅ | Login password |
| `firstName` | string | ✅ | User's first name |
| `lastName` | string | ✅ | User's last name |
| `email` | string | ❌ | Email address |
| `phone` | string | ❌ | Phone number |
| `address` | string | ❌ | Full address |
| `pincode` | string | ❌ | Postal/Zip code |
| `lat` | number | ❌ | Latitude |
| `lon` | number | ❌ | Longitude |
| `location` | map | ❌ | Hierarchical location map (e.g. `{"STATE": "MH", "CITY": "PUNE"}`) |
| `otpEnabled` | boolean | ❌ | Force OTP check for this request (default `false`) |
| `otpToken` | string | ⚠️ | Required if `otpEnabled` is true or enforced by settings |

#### 📍 Hierarchical Location Registration
The registration endpoint supports an advanced **Hierarchical Location** facility. This allows you to associate a user with a specific geographical level while ensuring the system maintains parent-child relationships.

**Key Features:**
- **Lowest Level Association**: The user is automatically mapped to the most granular level provided in the map.
- **Auto-Creation**: If a location code provided in the map does not exist, the system **automatically creates it** and links it to the parent level provided in the same map.
- **Hierarchy Awareness**: It uses the system's `org_location_def` to ensure levels are processed in the right order (e.g., State → District → City).

**Example: Auto-Creating a City under an existing State**
```json
{
  "tenantId": "dhaneesh",
  "username": "pune_retailer",
  "password": "Password123!",
  "firstName": "Rahul",
  "lastName": "Sharma",
  "location": {
    "STATE": "MAHARASHTRA", 
    "CITY": "PUNE_NEW_CORE" 
  }
}
```
*In this example: If "MAHARASHTRA" exists but "PUNE_NEW_CORE" doesn't, the system will create the city, set its parent to Maharashtra, and associate the user with the city.*

---


**Example Request:**
```json
{
  "tenantId": "dhaneesh",
  "username": "jdoe_retailer",
  "password": "SecurePass123!",
  "firstName": "John",
  "lastName": "Doe",
  "address": "123 Main St, Pune",
  "pincode": "411001",
  "lat": 18.5204,
  "lon": 73.8567,
  "otpEnabled": true,
  "otpToken": "uuid-verified-token"
}
```

---

### 5. Register Tenant & Admin
**`POST /auth/register`**

Registers a completely new tenant and creates its first `TENANT_ADMIN`.

**Request Body:**
```json
{
  "tenantId": "new_corp",
  "tenantName": "New Corporation",
  "username": "admin_user",
  "password": "AdminPassword123!",
  "firstName": "Admin",
  "lastName": "User",
  "email": "admin@newcorp.com"
}
```


---

### 6. Associate Outlet
**`POST /outlets/register`**

After a user is registered, they can associate themselves with a new or existing outlet. This endpoint requires authentication (JWT token).

**Headers:**
- `Authorization: Bearer <token>`
- `X-Tenant-Id: <tenant_id>`

**Request Body:**
```json
{
  "code": "OUTLET_001",
  "name": "My Retail Store",
  "channel": "RETAIL",
  "address": "123 Main St",
  "pincode": "411001",
  "lat": 12.9716,
  "lon": 77.5946
}
```

**Response (201 Created):**
```json
{
  "outlet": {
    "id": 123,
    "code": "OUTLET_001",
    "name": "My Retail Store",
    ...
  },
  "user": "authenticated_username",
  "message": "Outlet created and user mapped."
}
```

> **Security Note:** If a user has the `RETAILER` role, the list and search endpoints for outlets will automatically filter results to only include outlets associated with that user.

---

## ⚙️ Configuration

The OTP requirement for user registration can be globally enforced per tenant using the Settings API.

**Setting Details:**
- **Feature**: `auth`
- **Key**: `registration_otp_enabled`
- **Value Type**: `BOOLEAN`

If this setting is set to `true` for a tenant, the `/auth/user-register` endpoint will **always** require a verified `otpToken`, regardless of the `otpEnabled` flag in the JSON payload.
