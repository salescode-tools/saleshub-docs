# System Settings Reference

The following table documents the active configuration settings supported by the Salescode Lite system. These settings are stored in the `setting_kv` table and can be managed via the Settings API.

| Feature | Key | Type | Default | Description | Used In |
|---|---|---|---|---|---|
| **application** | `timezone` | `STRING` | - | System timezone configuration (e.g., `Asia/Kolkata`). | General / UI |
| **application** | `currency` | `STRING` | - | Default currency for transactions (e.g., `INR`). | General / UI |
| **application** | `apptype` | `STRING` | - | Application classification or mode (e.g., `COMBO`). | General / UI |
| **application** | `subscription` | `STRING` | - | Tenant subscription level (e.g., `Free`, `Premium`). | General / UI |
| **attendance** | `cutoff_time` | `STRING` | `23:59` | Cutoff time for marking/uploading current day attendance (format: `HH:mm`). | `AttendanceResource`, `MasterStreamMain` |
| **auth** | `registration_otp_enabled` | `BOOLEAN` | `false` | If enabled, user registration via `/auth/user-register` requires a verified OTP token. | `AuthResource` |
| **catalog** | `distributor_search_radius_km` | `NUMBER` | `5.0` | Defines the search radius (in kilometers) for identifying nearby distributors when direct mapping or pincode matching fails. | `CatalogResource`, `ServiceabilityResource` |

---

## Management via API

Settings can be viewed or updated using the following endpoints (see [SETTINGS_API.md](./SETTINGS_API.md) for full details):

- **List All**: `GET /api/settings`
- **Update/Create**: `PUT /api/settings`
- **Delete**: `DELETE /api/settings/{feature}/{key}`
