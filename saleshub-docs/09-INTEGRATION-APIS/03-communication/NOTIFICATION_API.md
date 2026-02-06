# 🔔 Notification & Device Management API

This document details the APIs for managing mobile device registrations and sending push notifications via Firebase Cloud Messaging (FCM).

---

## 📋 Table of Contents
- [Overview](#-overview)
- [Authentication](#-authentication)
- [Device Management Endpoints](#-device-management-endpoints)
  - [1. Register/Update Device](#1-registerupdate-device)
  - [2. Unregister Device](#2-unregister-device)
- [Notification Engine Endpoints](#-notification-engine-endpoints)
  - [1. Send Notification](#1-send-notification)
  - [2. Get Notification History](#2-get-notification-history)
  - [3. Configure Firebase Service Account](#3-configure-firebase-service-account)

---

## 🏗️ Overview

The platform provides a robust multi-tenant notification engine that handles:
1. **Device Tracking**: Mapping FCM tokens to users across platforms (iOS, Android, Web).
2. **Flexible Metadata**: Storing extended device attributes (e.g., app version, model).
3. **Secure Delivery**: Using OAuth 2.0 with Firebase HTTP v1 API.
4. **Audit Trail**: Tracking delivery status and errors for every notification.

---

## 🔐 Authentication

All endpoints in this document require a valid authentication context.

**Required Headers:**
- `Authorization: Bearer <JWT_TOKEN>`
- `X-Tenant-ID: <TENANT_ID>`
- `Content-Type: application/json`

---

## 📱 Device Management Endpoints
**Base Path:** `/v1/devices`

### 1. Register/Update Device
**`PUT /v1/devices`**

Registers a mobile device FCM token for the currently authenticated user. If the token already exists for the user, it updates the platform and extended attributes.

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `fcmToken` | string | ✅ | The Firebase Cloud Messaging token. |
| `platform` | string | ❌ | Target platform (`android`, `ios`, `web`). |
| `extendedAttributes` | object | ❌ | Key-value JSON for extra metadata (e.g. `{"app_version": "1.0.2"}`). |

**Example Request:**
```json
{
  "fcmToken": "dk39...f92k",
  "platform": "android",
  "extendedAttributes": {
    "app_version": "2.4.0",
    "device_model": "Pixel 7"
  }
}
```

**Response (200 OK):**
```json
{
  "message": "Device registered successfully"
}
```

---

### 2. Unregister Device
**`DELETE /v1/devices/{token}`**

Removes a specific device registration for the current tenant.

**Response (200 OK):**
```json
{
  "message": "Device unregistered successfully"
}
```

---

## 🚀 Notification Engine Endpoints
**Base Path:** `/notification/v1`

### 1. Send Notification
**`POST /notification/v1/send`**

Triggers a push notification to one or more recipients.

**Request Body:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `recipients` | array[string] | ✅ | List of usernames to target. |
| `title` | string | ✅ | Title of the notification. |
| `body` | string | ✅ | Main message content. |
| `mediaUrl` | string | ❌ | URL for an image or video attachment. |
| `data` | object | ❌ | Custom JSON data payload for the app to handle. |

**Example Request:**
```json
{
  "recipients": ["dhaneesh", "salesrep_01"],
  "title": "New Order Placed",
  "body": "Retailer 'Big Mart' has placed a new order of $150.",
  "data": {
    "orderId": "ORD-9923",
    "type": "NEW_ORDER"
  }
}
```

**Response (200 OK):**
```json
{
  "message": "Notification processing initiated"
}
```

---

### 2. Get Notification History
**`GET /notification/v1/history`**

Retrieves the paginated list of notifications sent to the current user.

**Query Parameters:**
- `limit`: (Default 20) Number of records to return.
- `offset`: (Default 0) Pagination offset.

**Response (200 OK):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "New Order Placed",
    "body": "...",
    "status": "SUCCESS",
    "createdAt": "2026-02-04T13:00:00Z",
    "sentAt": "2026-02-04T13:00:05Z",
    "dataJson": { ... }
  }
]
```

---

### 3. Configure Firebase Service Account
**`POST /notification/v1/config/firebase`**

Stores the official Google Service Account JSON for FCM. This is required per tenant to enable push notifications. This data is stored as a **secret** and is never exposed in standard listings.

**Request Body:**
Paste the raw content of your `service-account.json` downloaded from the Firebase Console.

**Response (200 OK):**
```json
{
  "message": "Firebase service account configured successfully"
}
```

---

## ✅ Notification Status Acknowledgment
**Base Path:** `/notification/v1/acknowledge`

Mobile apps should use these endpoints to report when a notification has been successfully received (delivered) or opened (read) by the user.

### 1. Mark as Delivered
**`POST /notification/v1/acknowledge/{id}/delivered`**

Records the timestamp when the notification payload was received by the device's background handler.

**Parameters:**
- `id`: The UUID of the notification.

**Response (200 OK):**
```json
{
  "message": "Delivery acknowledged"
}
```

---

### 2. Mark as Read
**`POST /notification/v1/acknowledge/{id}/read`**

Records the timestamp when the user clicked on or opened the notification.

**Parameters:**
- `id`: The UUID of the notification.

**Response (200 OK):**
```json
{
  "message": "Read acknowledged"
}
```

---

## 🛠️ Internal Statuses
Each notification in the history will have one of the following statuses:
- `PENDING`: Queued for sending.
- `SUCCESS`: Accepted by Firebase GCM/FCM gateway.
- `FAILURE`: Failed to send (see `errorMessage` for details).
