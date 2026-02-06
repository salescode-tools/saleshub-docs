# File Upload & Document API

The File Upload API provides endpoints for managing files within the system. All files are stored securely in S3, while metadata is tracked in the local database for fast retrieval and indexing.

## Base URL
`/documents`

---

## Endpoints

### 1. Upload Document
Upload a file to the platform. Supports both private (default) and public access modes.

- **URL**: `POST /documents/upload`
- **Method**: `POST`
- **Content-Type**: `multipart/form-data`

**Request Parameters:**
| Parameter | Type | Required | Description |
| :--- | :--- | :--- | :--- |
| `file` | `Binary` | Yes | The actual file content to be uploaded. |
| `name` | `String` | No | A custom name for the document. Defaults to filename. |
| `description` | `String` | No | A brief description of the document. |
| `isPublic` | `Boolean` | No | If `true`, the file can be accessed without strict tenant-user checks (though still secured by ID). Default: `false`. |

**Success Response (201 Created):**
```json
{
  "documentId": "550e8400-e29b-41d4-a716-446655440000",
  "filename": "quarterly_report.pdf",
  "name": "Q3 Financials",
  "description": "Final version of Q3 report",
  "fileSize": 124500,
  "contentType": "application/pdf",
  "downloadUrl": "/documents/550e8400-e29b-41d4-a716-446655440000"
}
```

---

### 2. List Documents
Get a paginated list of documents uploaded by the current tenant.

- **URL**: `GET /documents`
- **Method**: `GET`
- **Query Parameters**:
  - `limit`: (Optional) Max items to return (default: 20).
  - `offset`: (Optional) Pagination offset (default: 0).

**Success Response (200 OK):**
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "filename": "quarterly_report.pdf",
    "name": "Q3 Financials",
    "description": "Final version of Q3 report",
    "fileSize": 124500,
    "contentType": "application/pdf",
    "downloadUrl": "/documents/550e8400-e29b-41d4-a716-446655440000",
    "createdAt": "2023-11-01T10:00:00Z"
  }
]
```

---

### 3. Get Document Info
Retrieve metadata for a specific document without streaming the biological bits.

- **URL**: `GET /documents/{id}/info`
- **Method**: `GET`

**Success Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "filename": "quarterly_report.pdf",
  "name": "Q3 Financials",
  "description": "Final version of Q3 report",
  "fileSize": 124500,
  "contentType": "application/pdf",
  "downloadUrl": "/documents/550e8400-e29b-41d4-a716-446655440000",
  "isPublic": false,
  "createdByUserId": 123,
  "createdAt": "2023-11-01T10:00:00Z"
}
```

---

### 4. Download / View Document
Download the actual file content. The response includes appropriate `Content-Type` and `Content-Disposition` headers.

- **URL**: `GET /documents/{id}`
- **Method**: `GET`
- **Produces**: `application/octet-stream` (or the file's specific MIME type)

**Response Headers:**
- `Content-Disposition`: `attachment; filename="filename.ext"`
- `Content-Length`: Size of the file.
- `X-Document-ID`: The ID of the document served.

---

### 5. Delete Document
Permanently remove a document and its storage entry.

- **URL**: `DELETE /documents/{id}`
- **Method**: `DELETE`

**Success Response:** `204 No Content`

---

## Security & Multitenancy
- **Tenant Isolation**: All operations are scoped to the `X-Tenant-ID` provided in the header.
- **Audit Logging**: Every upload and download attempt is recorded in the system audit logs for compliance tracking.
