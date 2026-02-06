# Ticket Management API

The Ticket Management System provides a robust way to create, track, and manage support tickets or tasks within the platform. It supports alpha-numeric ticket IDs, multi-attachment references, conversion tracking, and comprehensive filtering.

## Data Models

### Ticket
| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | `String` | Unique Alpha-numeric ID (e.g., `DEMO-1001`). Generated as `UPPER(tenantId) + '-' + seq`. |
| `subject` | `String` | Primary title of the ticket. |
| `description` | `String` | Detailed explanation of the issue or task. |
| `category` | `String` | Functional grouping (e.g. `TECHNICAL`, `BILLING`, `LOGISTICS`). |
| `status` | `String` | Current state (default: `OPEN`). Common values: `OPEN`, `IN_PROGRESS`, `RESOLVED`, `CANCELED`. |
| `tags` | `List<String>` | Array of labels for filtering. |
| `documents` | `List<String>` | Array of URLs or references to related documents. |
| `outletCode` | `String` | Optional reference to a specific outlet. |
| `salesrepCode` | `String` | Optional reference to a sales representative. |
| `distributorCode` | `String` | Optional reference to a distributor. |
| `createdBy` | `String` | User ID who created the ticket. |
| `updatedBy` | `String` | Last user ID who modified the ticket. |
| `createdAt` | `Timestamp` | Time of creation. |
| `updatedAt` | `Timestamp` | Last modification time. |
| `details` | `JSON` | Extra structured data/custom fields. |

---

## Endpoints

### 1. Create Ticket
Create a new ticket for the current tenant.

- **URL**: `POST /tickets`
- **Authentication**: Required (Admin/User)
- **Request Body**:
```json
{
  "subject": "App crash on sync",
  "description": "The application crashes as soon as I press the sync button on the home screen.",
  "category": "TECHNICAL",
  "tags": ["critical", "ios"],
  "documents": ["https://storage.com/logs/123.txt"],
  "outletCode": "OUT_999",
  "initialContent": "Initial report or first comment on the ticket.",
  "details": {
    "appVersion": "1.2.3",
    "device": "iPhone 13"
  }
}
```
- **Response** (`201 Created`):
```json
{
  "id": "DEMO-1001",
  "status": "ok"
}
```

### 2. Ticket Summary (Dashboard)
Get aggregated statistics for tickets, including total counts, counts by status, and counts by category.

- **URL**: `GET /tickets/summary`
- **Response** (`200 OK`):
```json
{
  "total": 150,
  "byStatus": {
    "OPEN": 45,
    "IN_PROGRESS": 20,
    "RESOLVED": 80,
    "CANCELED": 5
  },
  "byCategory": {
    "TECHNICAL": 60,
    "BILLING": 30,
    "LOGISTICS": 40,
    "UNCATEGORIZED": 20
  },
  "byCategoryAndStatus": {
    "TECHNICAL": {
      "OPEN": 10,
      "IN_PROGRESS": 5,
      "RESOLVED": 45
    },
    "BILLING": {
      "OPEN": 5,
      "RESOLVED": 25
    }
  }
}
```

### 3. Search Tickets
List tickets with flexible filtering and pagination.

- **URL**: `GET /tickets`
- **Query Parameters**:
  - `status`: Filter by current status (e.g. `OPEN`).
  - `category`: Filter by category.
  - `outletCode`: Filter by outlet association.
  - `salesrepCode`: Filter by salesrep association.
  - `tags`: Filter by tags (matches if ticket contains ALL provided tags).
  - `q`: Search query (ILIKE on subject).
  - `limit`: Default 50, Max 1000.
  - `offset`: Pagination offset.

### 4. Get Ticket Details
Fetch a ticket and its complete conversation/audit history.

- **URL**: `GET /tickets/{id}`
- **Response** (`200 OK`):
```json
{
  "ticket": { ...Ticket object... },
  "updates": [ ...Updates... ],
  "documentDetails": [
    {
      "id": "DOC-UUID",
      "filename": "logs.txt",
      "contentType": "text/plain",
      "downloadUrl": "/documents/DOC-UUID"
    }
  ]
}
```

### 5. List Ticket Documents
Fetch full metadata and download URLs for all document IDs associated with a ticket (from both the header and all conversation history).

- **URL**: `GET /tickets/{id}/documents`
- **Response** (`200 OK`): `List<DocumentDTO>`

### 6. Add Update / Change Status / Change Fields
Add a new comment to the ticket or update its header fields.

- **URL**: `POST /tickets/{id}/updates`
- **Request Body**:
```json
{
  "content": "Problem resolved after server restart.",
  "subject": "App crash on sync (RESOLVED)",
  "description": "Updated description with more context.",
  "status": "RESOLVED",
  "tags": ["critical", "ios", "resolved_server_side"],
  "documents": ["https://storage.com/proof/fixed.png"]
}
```
- **Note**: Providing `subject`, `description`, `status`, `category`, `tags`, or `details` in this payload will automatically update the main Ticket header and record a `changes` log in the history.

### 7. Update Description Only
Dedicated endpoint for quickly updating just the description field.

- **URL**: `PUT /tickets/{id}/description`
- **Request Body**:
```json
{
  "description": "New description text"
}
```
- **Response**: `{ "status": "ok" }`

### 8. Update Details Only
Replace the entire custom structured data in the `details` JSON field (Overwrites existing data).

- **URL**: `PUT /tickets/{id}/details`
- **Request Body**:
```json
{
  "details": {
    "Contact": "988176",
    "verified": true
  }
}
```
- **Response**: `{ "status": "ok" }`

### 9. Delete Ticket
Permanently remove a ticket and its history.

- **URL**: `DELETE /tickets/{id}`
- **Response**: `{ "status": "ok" }`

---

## History & Audit Trail
Every update to a ticket fields via the `/updates` endpoint is recorded in the `app_ticket_update` table. This includes:
- **Author**: Who performed the change.
- **Content**: The message or comment provided.
- **Status Change**: The specific status the ticket was moved to.
- **Changes**: A JSON diff showing the old and new values for header fields (`subject`, `description`, `status`, `category`, `tags`, `details`).
- **Timestamps**: Exactly when each event occurred.
