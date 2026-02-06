# Plugin and Subscription API Documentation

## Overview
This API allows tenants to upload, manage, and subscribe to plugins. It supports cross-tenant plugin sharing via a subscription model with Row Level Security (RLS) enforcement.

## Endpoints

### 1. Register/Upload Plugin
Uploads a new plugin ZIP file. The system extracts metadata (ID, version, description, features, extended attributes) from `plugin.js` inside the ZIP.

- **Method**: `POST`
- **URL**: `/plugins/register`
- **Content-Type**: `multipart/form-data`
- **Authorization**: `Bearer <TOKEN>`
- **Parameters**:
  - `file`: The plugin ZIP file (Required).

**Response (200 OK):**
```json
{
  "id": "uuid",
  "tenantId": "owner_tenant",
  "pluginId": "sample-plugin",
  "version": "1.0.1",
  "description": "A sample plugin",
  "zipUrl": "https://s3.amazonaws.com/...",
  "active": true,
  "features": ["feature1", "feature2"],
  "extendedAttributes": {
    "author": "Salescode Team"
  },
  "createdAt": "2026-01-07T10:00:00Z",
  "updatedAt": "2026-01-07T10:00:00Z"
}
```

---

### 2. List Plugins
Lists all plugins available to the current tenant. This includes:
1. Plugins owned by the current tenant.
2. Plugins from other tenants that the current tenant has subscribed to.

- **Method**: `GET`
- **URL**: `/plugins`
- **Authorization**: `Bearer <TOKEN>`

**Response (200 OK):**
```json
[
  {
    "id": "uuid",
    "tenantId": "owner_tenant",
    "pluginId": "sample-plugin",
    "version": "1.0.1",
    "active": true,
    ...
  }
]
```

---

### 3. Subscribe to Plugin
Allows a tenant to subscribe to a plugin owned by another tenant. This grants access to view and download the plugin.

- **Method**: `POST`
- **URL**: `/plugins/subscribe`
- **Content-Type**: `application/json`
- **Authorization**: `Bearer <TOKEN>`
- **Body**:
```json
{
  "pluginId": "sample-plugin",
  "ownerTenantId": "bepensa"
}
```

**Response (200 OK)**

---

### 4. Unsubscribe from Plugin
Removes access to a subscribed plugin.

- **Method**: `POST`
- **URL**: `/plugins/unsubscribe`
- **Content-Type**: `application/json`
- **Authorization**: `Bearer <TOKEN>`
- **Body**:
```json
{
  "pluginId": "sample-plugin",
  "ownerTenantId": "bepensa"
}
```

**Response (200 OK)**

---

### 5. Activate Plugin Version
Manually activates a specific version of a plugin. Only one version of a plugin can be active at a time for a tenant.

- **Method**: `PUT`
- **URL**: `/plugins/{id}/activate`
- **Authorization**: `Bearer <TOKEN>`
- **Path Parameters**:
  - `id`: The unique UUID of the plugin version to activate.

**Response (200 OK):** returns the activated plugin object.

---

### 6. Delete Plugin
Deletes a plugin version owned by the current tenant.

- **Method**: `DELETE`
- **URL**: `/plugins/{id}`
- **Authorization**: `Bearer <TOKEN>`
- **Path Parameters**:
  - `id`: The unique UUID of the plugin version.

**Response (204 No Content)**
