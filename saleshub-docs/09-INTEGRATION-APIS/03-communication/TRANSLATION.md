# Translation API Documentation

## Overview

The Translation API provides multi-language text management with optional categorization. It's designed for internationalization (i18n) and localization (l10n) of applications.

## Key Features

- **Text Keys**: Unique identifiers for translatable content
- **Multi-Language Support**: Store translations in multiple languages with ISO language codes
- **Categorization**: Optional category and subcategory for organizing translations
- **Translation Map**: Get key-value pairs for easy frontend integration
- **Multi-Tenant**: Full tenant isolation via RLS

## Base URL

```
/translations
```

## Endpoints

### 1. Create Translation

**POST** `/translations`

Create a new translation for a text key in a specific language.

**Request Body:**
```json
{
  "textKey": "welcome.message",
  "language": "en",
  "value": "Welcome to our application!",
  "category": "UI",
  "subcategory": "Messages",
  "description": "Welcome message shown on homepage"
}
```

**Required Fields:**
- `textKey` - Translation key (e.g., "welcome.message", "button.submit")
- `language` - ISO language code (e.g., "en", "es", "fr", "hi", "en-US")
- `value` - Translated text

**Optional Fields:**
- `category` - Grouping (e.g., "UI", "Email", "API")
- `subcategory` - Sub-grouping (e.g., "Buttons", "Messages")
- `description` - Context for translators
- `extendedAttr` - Additional metadata

**Response:**
```json
{
  "id": "welcome.message:en",
  "tenantId": "tenant123",
  "textKey": "welcome.message",
  "language": "en",
  "value": "Welcome to our application!",
  "category": "UI",
  "subcategory": "Messages",
  "description": "Welcome message shown on homepage",
  "createdByUserId": 10,
  "extendedAttr": {},
  "createdAt": "2025-12-15T20:00:00Z",
  "updatedAt": "2025-12-15T20:00:00Z"
}
```

---

### 2. Get Translation by ID

**GET** `/translations/{id}`

Retrieve a specific translation by composite ID (textKey:language).

**Path Parameters:**
- `id` - Composite ID (e.g., "welcome.message:en")

**Response:**
```json
{
  "id": "welcome.message:en",
  "textKey": "welcome.message",
  "language": "en",
  "value": "Welcome to our application!",
  ...
}
```

---

### 3. Get Translations by Language

**GET** `/translations/language/{language}`

Get all translations for a specific language.

**Path Parameters:**
- `language` - Language code (e.g., "en", "es", "fr")

**Response:**
```json
[
  {
    "id": "welcome.message:en",
    "textKey": "welcome.message",
    "language": "en",
    "value": "Welcome!",
    ...
  },
  {
    "id": "button.submit:en",
    "textKey": "button.submit",
    "language": "en",
    "value": "Submit",
    ...
  }
]
```

---

### 4. Get Translation Map

**GET** `/translations/map/{language}`

Get a simple key-value map for frontend i18n libraries.

**Path Parameters:**
- `language` - Language code

**Response:**
```json
{
  "welcome.message": "Welcome to our application!",
  "button.submit": "Submit",
  "button.cancel": "Cancel",
  "error.required": "This field is required"
}
```

**Usage with i18n libraries:**
```javascript
// React i18next
const translations = await fetch('/translations/map/en').then(r => r.json());
i18n.addResourceBundle('en', 'translation', translations);

// Vue i18n
const messages = await fetch('/translations/map/en').then(r => r.json());
createI18n({ messages: { en: messages } });
```

---

### 5. Update Translation

**PUT** `/translations/{id}`

Update an existing translation (partial update).

**Path Parameters:**
- `id` - Composite ID

**Request Body (all fields optional):**
```json
{
  "value": "Updated translation text",
  "category": "Updated Category",
  "description": "Updated description"
}
```

---

### 6. Delete Translation

**DELETE** `/translations/{id}`

Delete a translation.

**Response:** `204 No Content`

---

### 7. Bulk Upsert Translations (JSON)

**POST** `/translations/bulk`

Create or update multiple translations at once using JSON array.

**Request Body:**
```json
[
  {
    "textKey": "welcome.message",
    "language": "en",
    "value": "Welcome!",
    "category": "UI"
  },
  {
    "textKey": "welcome.message",
    "language": "es",
    "value": "¡Bienvenido!",
    "category": "UI"
  }
]
```

**Response:**
```json
{
  "created": 10,
  "updated": 5,
  "failed": 2,
  "total": 17,
  "errors": [
    "Item 3: textKey is required",
    "Item 8: language must be a valid ISO code"
  ]
}
```

---

### 8. Download CSV Template

**GET** `/translations/template`

Download a CSV template for bulk translation import.

**Response:** CSV file with sample data

---

### 9. Import Translations from CSV

**POST** `/translations/import`

Upload a CSV file to bulk import/update translations.

**Request:**
- Content-Type: `text/csv` or `application/octet-stream`
- Body: CSV file content

**CSV Format:**
```csv
textKey,language,value,category,subcategory,description
welcome.message,en,"Welcome!",UI,Messages,"Welcome message on homepage"
welcome.message,es,"¡Bienvenido!",UI,Messages,"Welcome message on homepage"
```

**Response:**
```json
{
  "created": 45,
  "updated": 23,
  "failed": 2,
  "total": 70,
  "errors": [
    "Line 5: language is required"
  ]
}
```

---

### 10. Import Translations from Excel

**POST** `/translations/import/excel`

Upload an Excel (.xlsx) file to bulk import/update translations.

**Request:**
- Content-Type: `application/vnd.openxmlformats-officedocument.spreadsheetml.sheet` or `application/octet-stream`
- Body: Excel file content

**Excel Format:**
- First row must be headers: `textKey`, `language`, `value`, `category`, `subcategory`, `description`
- Case-insensitive header matching
- Supports .xlsx format (Excel 2007+)

**Response:**
```json
{
  "created": 35,
  "updated": 18,
  "failed": 1,
  "total": 54,
  "errors": [
    "Row 7: language is required"
  ]
}
```

---

### 11. Get Unique Categories

**GET** `/translations/categories`

Get a list of all unique categories used in translations.

**Response:**
```json
[
  "UI",
  "Email",
  "API",
  "Errors"
]
```

---

### 12. Get Unique Subcategories

**GET** `/translations/subcategories`

Get a list of all unique subcategories. Optionally filter by category.

**Query Parameters:**
- `category` (optional): Filter subcategories belonging to this category

**Response:**
```json
[
  "Buttons",
  "Messages",
  "Validation"
]
```

---

## cURL Examples

### Create Translation

```bash
curl -X POST http://localhost:8080/translations \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -d '{
    "textKey": "welcome.message",
    "language": "en",
    "value": "Welcome!",
    "category": "UI",
    "subcategory": "Messages"
  }'
```

### Create Multiple Languages

```bash
# English
curl -X POST http://localhost:8080/translations \
  -H 'Content-Type: application/json' \
  -d '{"textKey":"button.submit","language":"en","value":"Submit"}'

# Spanish
curl -X POST http://localhost:8080/translations \
  -H 'Content-Type: application/json' \
  -d '{"textKey":"button.submit","language":"es","value":"Enviar"}'

# French
curl -X POST http://localhost:8080/translations \
  -H 'Content-Type: application/json' \
  -d '{"textKey":"button.submit","language":"fr","value":"Soumettre"}'
```

### Get All Translations for a Language

```bash
curl -X GET http://localhost:8080/translations/language/en \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Get Translation Map

```bash
curl -X GET http://localhost:8080/translations/map/en \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Bulk Upsert (JSON)

```bash
curl -X POST http://localhost:8080/translations/bulk \
  -H 'Content-Type: application/json' \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -d '[
    {"textKey":"welcome.message","language":"en","value":"Welcome!","category":"UI"},
    {"textKey":"welcome.message","language":"es","value":"¡Bienvenido!","category":"UI"},
    {"textKey":"button.submit","language":"en","value":"Submit","category":"UI"}
  ]'
```

### Download CSV Template

```bash
curl -X GET http://localhost:8080/translations/template \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -o translation_template.csv
```

### Import from CSV

```bash
curl -X POST http://localhost:8080/translations/import \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -H 'Content-Type: text/csv' \
  --data-binary '@translations.csv'
```

### Import from Excel

```bash
curl -X POST http://localhost:8080/translations/import/excel \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN' \
  -H 'Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' \
  --data-binary '@translations.xlsx'
```

### Get Categories

```bash
curl -X GET http://localhost:8080/translations/categories \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

### Get Subcategories

```bash
curl -X GET "http://localhost:8080/translations/subcategories?category=UI" \
  -H 'Authorization: Bearer YOUR_JWT_TOKEN'
```

---

## Data Model

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Auto | Composite: textKey:language |
| tenantId | String | Auto | Tenant identifier |
| textKey | String | Yes | Translation key |
| language | String | Yes | ISO language code |
| value | String | Yes | Translated text |
| category | String | No | Optional grouping |
| subcategory | String | No | Optional sub-grouping |
| description | String | No | Context for translators |
| createdByUserId | Long | Auto | Creator user ID |
| extendedAttr | Object | No | Additional metadata |
| createdAt | DateTime | Auto | Creation timestamp |
| updatedAt | DateTime | Auto | Last update timestamp |

---

## Best Practices

### 1. Text Key Naming Convention

Use hierarchical dot notation:
- `welcome.message`
- `button.submit`
- `error.validation.required`
- `email.subject.welcome`

### 2. Language Codes

Use ISO 639-1 codes:
- `en` - English
- `es` - Spanish
- `fr` - French
- `hi` - Hindi
- `en-US` - English (US)
- `pt-BR` - Portuguese (Brazil)

### 3. Categorization

Group related translations:
- **Category**: `UI`, `Email`, `API`, `SMS`
- **Subcategory**: `Buttons`, `Messages`, `Errors`, `Validation`

### 4. Description Field

Provide context for translators:
```json
{
  "textKey": "button.save",
  "description": "Save button in the user profile form"
}
```

---

## Common Use Cases

### Initialize App with Translations

```javascript
async function loadTranslations(language) {
  const translations = await fetch(`/translations/map/${language}`)
    .then(r => r.json());
  
  return translations;
}
```

### Add New Language Support

```bash
# Get all English translations
curl /translations/language/en > en_template.json

# Translate to Spanish and import
# ... translate values ...

# Create Spanish translations
curl -X POST /translations/bulk \
  -d @es_translations.json
```

### Update Translation Value

```bash
curl -X PUT http://localhost:8080/translations/welcome.message:en \
  -H 'Content-Type: application/json' \
  -d '{"value":"Welcome to our awesome app!"}'
```

---

## Multi-Tenant Support

- All translations are tenant-scoped
- `tenant_id` is automatically set from JWT token
- Users can only access their tenant's translations

---

## Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 OK | Successful GET request |
| 201 Created | Translation created |
| 204 No Content | Successful DELETE |
| 400 Bad Request | Validation error |
| 404 Not Found | Translation not found |
| 500 Internal Server Error | Server error |
