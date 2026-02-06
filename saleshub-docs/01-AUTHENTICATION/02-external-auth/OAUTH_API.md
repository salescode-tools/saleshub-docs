# OAuth 2.0 API Documentation

Salescodeai Saleshub supports the **OAuth 2.0 Client Credentials Flow**. This allows external applications (e.g., ERPs, BI tools, or custom integrations) to authenticate and interact with Saleshub APIs within a specific tenant context without requiring user-level credentials.

---

## **1. Concepts**

- **Client ID**: A unique identifier for your external application.
- **Client Secret**: A secure passphrase used to authenticate your application. (Store this securely!)
- **Access Token**: A short-lived JWT token used to call protected Saleshub APIs (default: 10 hours).
- **Refresh Token**: A long-lived token used to obtain a new access token without re-authenticating (30 days).
- **Extended Attributes**: Customizable metadata stored with each OAuth client.

---

## **2. Client Management**

*Note: These endpoints require `TENANT_ADMIN` role.*

### **Register a New OAuth Client**
**Endpoint**: `POST /oauth/clients`  
**Authentication**: Required (JWT Bearer Token as Admin)

**Request Body**:
```json
{
  "name": "Acme Integration App",
  "scopes": ["READ", "WRITE"],
  "extendedAttr": {
    "version": "1.0.0",
    "department": "Engineering"
  }
}
```

**Response (201 Created)**:
```json
{
  "id": 12,
  "tenantId": "t_abc123",
  "clientId": "a1b2c3d4e5f6...",
  "clientSecret": "very-long-plain-text-secret...",
  "clientName": "Acme Integration App",
  "scopes": ["READ", "WRITE"],
  "extendedAttr": {
    "version": "1.0.0",
    "department": "Engineering"
  },
  "createdAt": "2026-01-29T12:00:00Z"
}
```
> ⚠️ **IMPORTANT**: The `clientSecret` is ONLY returned once during registration. If lost, you must delete and recreate the client.

### **List OAuth Clients**
**Endpoint**: `GET /oauth/clients`  
**Response**: `200 OK` with an array of clients (secrets are hashed and not returned).

### **Delete OAuth Client**
**Endpoint**: `DELETE /oauth/clients/{id}`  
**Response**: `204 No Content`.

---

## **3. Obtaining an Access Token**

External applications use their credentials to obtain a JWT access token.

**Endpoint**: `POST /oauth/token`  
**Authentication**: None (Public)  
**Required Header**: `X-Tenant-Id` (The ID of the tenant the app belongs to)

The endpoint supports both **JSON** and **Form-Urlencoded** request formats.

### **Option A: Form Data (Standard OAuth2)**
```http
POST /oauth/token
X-Tenant-Id: your-tenant-id
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&client_id=YOUR_ID&client_secret=YOUR_SECRET
```

### **Option B: JSON Payload**
```http
POST /oauth/token
X-Tenant-Id: your-tenant-id
Content-Type: application/json

{
  "grant_type": "client_credentials",
  "client_id": "YOUR_ID",
  "client_secret": "YOUR_SECRET"
}
```

### **Success Response (200 OK)**
```json
{
  "access_token": "eyJhbGciOiJIUzI1Ni...",
  "refresh_token": "eyJhbGciOiJIUzI1Ni...",
  "token_type": "Bearer",
  "expires_in": 36000,
  "scope": "READ WRITE",
  "tenant_id": "your-tenant-id"
}
```

---

## **4. Refreshing an Access Token**

When an access token expires (or is near expiration), your application can use the `refresh_token` to obtain a new one.

**Endpoint**: `POST /oauth/token`  
**Authentication**: None (Public)  
**Required Header**: `X-Tenant-Id`

### **Request**
```http
POST /oauth/token
X-Tenant-Id: your-tenant-id
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token&refresh_token=YOUR_REFRESH_TOKEN
```

The system will verify the refresh token and return a new `access_token` and a new `refresh_token`.

---

## **5. Using the Access Token**

Once you have the `access_token`, include it in the `Authorization` header of all subsequent API calls:

```http
GET /products
Authorization: Bearer <access_token>
X-Tenant-Id: your-tenant-id
```

The system will treat the request as coming from the application. The `user_id` in the system log will be `-1`, and the `username` will be the `client_id`.

---

## **6. Security Considerations**

1. **Secret Management**: Never commit client secrets to version control. Use environment variables or secret managers.
2. **Token Lifecycle**: Access tokens are valid for 10 hours, while refresh tokens are valid for 30 days.
3. **Refresh Token Usage**: Refresh tokens are one-time use or rotating. Every time you refresh, you get a NEW refresh token. Always discard the old one.
4. **Tenant Isolation**: OAuth tokens are strictly bound to the tenant they were created for. You cannot access data from other tenants using an app's token.
