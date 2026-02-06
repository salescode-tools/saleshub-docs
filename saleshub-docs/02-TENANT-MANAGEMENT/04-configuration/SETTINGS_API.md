# Settings API

The Settings API provides a flexible key-value store for application configuration, feature flags, and other runtime settings. It supports features, data types, and secret masking.

## Base URL
`/api/settings`

---

## Data Model: SettingKv

| Field | Type | Description |
|---|---|---|
| `id` | Number | Unique identifier (read-only) |
| `feature` | String | Grouping for settings (e.g., "LOGIN", "CATALOG") |
| `key` | String | Unique key within the feature |
| `valueType` | String | Type of value: `STRING`, `NUMBER`, `BOOLEAN`, `JSON`, `ARRAY`, `NULL` |
| `valueJson` | JSON | The actual value |
| `description` | String | Optional description of the setting |
| `defaultJson` | JSON | Optional default value |
| `isSecret` | Boolean | If true, value is masked in responses unless explicitly requested |
| `updatedBy` | String | Username of the last updater |
| `createdAt` | Timestamp | Creation time (read-only) |
| `updatedAt` | Timestamp | Last update time (read-only) |

---

## 1. List Settings

Retrieves a list of settings, optionally filtered by feature or search query. Secrets are masked by default.

### Request
- **Method**: `GET`
- **URL**: `/api/settings`
- **Query Parameters**:
    - `feature` (optional): Filter by feature name.
    - `q` (optional): Search query (matches key, feature, or description).
    - `include_secrets` (optional): `true` to reveal secret values (default: `false`).
    - `limit` (optional): Max results (default: 100).
    - `offset` (optional): Pagination offset (default: 0).

### Response
- **Status**: `200 OK`
- **Body**:
```json
{
  "items": [
    {
      "id": 1,
      "feature": "APP_CONFIG",
      "key": "THEME_COLOR",
      "valueType": "STRING",
      "valueJson": "blue",
      "isSecret": false,
      ...
    }
  ]
}
```

---

## 2. Get Setting

Retrieves a single setting by feature and key.

### Request
- **Method**: `GET`
- **URL**: `/api/settings/{feature}/{key}`
- **Query Parameters**:
    - `include_secrets` (optional): `true` to reveal secret values (default: `false`).

### Response
- **Status**: `200 OK`
- **Body**: JSON object of `SettingKv`.
- **Status**: `404 Not Found` if the setting does not exist.

---

## 3. Create / Update Setting (Upsert)

Creates a new setting or updates an existing one (based on feature + key).

### Request
- **Method**: `PUT`
- **URL**: `/api/settings`
- **Headers**: `Content-Type: application/json`
- **Body**:
```json
{
  "feature": "PAYMENTS",
  "key": "API_KEY",
  "valueType": "STRING",
  "valueJson": "sk_test_12345",
  "description": "Stripe API Key",
  "isSecret": true
}
```

### Response
- **Status**: `200 OK`
- **Body**: `{"id": <number>}`

---

## 4. Bulk Create / Update

Upserts multiple settings in a single request.

### Request
- **Method**: `PUT`
- **URL**: `/api/settings/bulk`
- **Headers**: `Content-Type: application/json`
- **Body**: JSON Array of `SettingKv` objects.

### Response
- **Status**: `200 OK`
- **Body**: `{"upserted": <count>}`

---

## 5. List Features

Retrieves a list of all unique feature names currently used.

### Request
- **Method**: `GET`
- **URL**: `/api/settings/features`

### Response
- **Status**: `200 OK`
- **Body**:
```json
{
  "items": ["APP_CONFIG", "PAYMENTS", "LOGIN", ...]
}
```

---

## 6. Delete Setting

Deletes a specific setting.

### Request
- **Method**: `DELETE`
- **URL**: `/api/settings/{feature}/{key}`

### Response
- **Status**: `204 No Content`
- **Status**: `404 Not Found` if the setting did not exist.
