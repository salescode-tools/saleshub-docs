# Stub User System - Automatic Parent User Creation

## Overview
The system automatically creates **placeholder/stub users** for non-existent parent usernames during bulk uploads. This ensures **zero failures** when uploading user hierarchies, even if parent users don't exist yet.

## How It Works

### Problem
When uploading users with parent mappings, the parent username might not exist:
```csv
salesrep_code,salesrep_name,parent_username
TSR001,John Doe,SUP001
```

If `SUP001` doesn't exist, the parent mapping would fail.

### Solution
The system automatically creates a **stub user** for `SUP001`:
- Username: `SUP001`
- First Name: `SUP001` (or derived from username)
- Last Name: `(Placeholder)`
- Status: **Inactive** (`is_active = false`)
- Marked as stub: `extended_attr.is_stub = true`

### Auto-Merge
When the real `SUP001` user is created later, the stub is automatically merged:
1. Stub markers removed from `extended_attr`
2. User activated (`is_active = true`)
3. All existing parent mappings preserved
4. User data updated with real information

## Features

### 1. Automatic Stub Creation
- ✅ Creates placeholder users for missing parent usernames
- ✅ Prevents bulk upload failures
- ✅ Marks users as inactive stubs
- ✅ Stores metadata in `extended_attr`

### 2. Automatic Merging
- ✅ Detects when real user is created
- ✅ Removes stub markers
- ✅ Activates the user
- ✅ Preserves all relationships

### 3. Admin Monitoring
- ✅ View all stub users
- ✅ Get stub user statistics
- ✅ Manually trigger merge if needed

## Stub User Structure

### Database Fields
```sql
{
  "id": 123,
  "username": "SUP001",
  "first_name": "SUP001",
  "last_name": "(Placeholder)",
  "password": NULL,
  "is_active": false,
  "extended_attr": {
    "is_stub": true,
    "created_reason": "parent_mapping_placeholder",
    "created_at": "2025-12-29T13:45:00Z"
  }
}
```

### Stub Markers
- `extended_attr.is_stub = true` - Identifies as stub user
- `extended_attr.created_reason = "parent_mapping_placeholder"` - Why it was created
- `extended_attr.created_at` - When stub was created
- `is_active = false` - Inactive until merged

## Usage Examples

### Example 1: Upload with Non-Existent Parents

**CSV Upload:**
```csv
salesrep_code,salesrep_name,parent_username
TSR001,John Doe,SUP001
TSR002,Jane Smith,SUP001
TSR003,Bob Johnson,SUP002
```

**What Happens:**
1. System checks if `SUP001` and `SUP002` exist
2. They don't exist → Creates stub users:
   - `SUP001` (inactive, marked as stub)
   - `SUP002` (inactive, marked as stub)
3. Creates users `TSR001`, `TSR002`, `TSR003`
4. Creates parent mappings:
   - `TSR001` → `SUP001`
   - `TSR002` → `SUP001`
   - `TSR003` → `SUP002`
5. **Upload succeeds with 0 failures!**

**Console Output:**
```
Created 2 stub user(s) for parent mappings
Successfully created 3 users
```

### Example 2: Later Upload of Real Parent

**CSV Upload (later):**
```csv
salesrep_code,salesrep_name,phone,email
SUP001,Alice Supervisor,9876543210,alice@example.com
```

**What Happens:**
1. System detects `SUP001` already exists as stub
2. Updates stub user with real data:
   - `first_name` = "Alice"
   - `last_name` = "Supervisor"
   - `phone` = "9876543210"
   - `email` = "alice@example.com"
3. Removes stub markers from `extended_attr`
4. Activates user (`is_active = true`)
5. All existing parent mappings (`TSR001` → `SUP001`, `TSR002` → `SUP001`) remain intact

**Console Output:**
```
Merged stub user: SUP001 (id: 123)
```

## API Endpoints

### View All Stub Users
```bash
GET /admin/stub-users
```

**Response:**
```json
[
  {
    "id": 123,
    "username": "SUP001",
    "firstName": "SUP001",
    "lastName": "(Placeholder)",
    "createdAt": "2025-12-29T13:45:00Z"
  },
  {
    "id": 124,
    "username": "SUP002",
    "firstName": "SUP002",
    "lastName": "(Placeholder)",
    "createdAt": "2025-12-29T13:46:00Z"
  }
]
```

### Get Stub User Statistics
```bash
GET /admin/stub-users/stats
```

**Response:**
```json
{
  "total_stub_users": 2,
  "message": "2 stub user(s) waiting to be merged"
}
```

### Manually Merge Stub User
```bash
POST /admin/stub-users/SUP001/merge
```

**Response (Success):**
```json
{
  "message": "Stub user merged successfully",
  "username": "SUP001",
  "merged": true
}
```

**Response (Not Found):**
```json
{
  "message": "No stub user found with username: SUP001",
  "username": "SUP001",
  "merged": false
}
```

## Database Queries

### Find All Stub Users
```sql
SELECT * FROM app_user
WHERE tenant_id = current_setting('app.tenant_id', true)
  AND extended_attr->>'is_stub' = 'true';
```

### Check if User is Stub
```sql
SELECT 
  username,
  is_active,
  extended_attr->>'is_stub' as is_stub,
  extended_attr->>'created_reason' as created_reason
FROM app_user
WHERE username = 'SUP001'
  AND tenant_id = current_setting('app.tenant_id', true);
```

### Manually Merge Stub
```sql
UPDATE app_user
SET extended_attr = extended_attr - 'is_stub' - 'created_reason',
    is_active = true
WHERE username = 'SUP001'
  AND tenant_id = current_setting('app.tenant_id', true)
  AND extended_attr->>'is_stub' = 'true';
```

## Benefits

### 1. Zero Upload Failures
- No need to upload in specific order
- Parent users can be uploaded later
- Bulk uploads never fail due to missing parents

### 2. Flexible Upload Order
```csv
# Can upload children first
TSR001,John Doe,SUP001

# Then parents later
SUP001,Alice Supervisor,MGR001

# Then grandparents
MGR001,David Manager,
```

### 3. Automatic Cleanup
- Stubs automatically merge when real users created
- No manual intervention needed
- Preserves all relationships

### 4. Easy Monitoring
- View all stub users via API
- Track which users are placeholders
- Manually merge if needed

## Best Practices

### 1. Regular Monitoring
Check stub users periodically:
```bash
GET /admin/stub-users/stats
```

### 2. Upload Real Users
Upload actual parent users to replace stubs:
```csv
SUP001,Alice Supervisor,9876543210,alice@example.com
```

### 3. Verify Merges
After uploading real users, verify stubs were merged:
```bash
GET /admin/stub-users
# Should show fewer stubs
```

### 4. Handle Inactive Stubs
Stub users are inactive by default, so they:
- ❌ Cannot login
- ❌ Don't appear in active user lists
- ✅ Can be parent in hierarchy
- ✅ Automatically activate when merged

## Troubleshooting

### Issue: Stub User Not Merging
**Cause:** Username mismatch (case-sensitive)
**Solution:** Ensure exact username match:
```csv
# Stub created: SUP001
# Upload: sup001  ❌ Won't merge (different case)
# Upload: SUP001  ✅ Will merge
```

### Issue: Too Many Stub Users
**Cause:** Uploading children before parents
**Solution:** Upload in hierarchical order (top-down) or accept stubs

### Issue: Stub User Showing in User List
**Cause:** Filtering not excluding inactive users
**Solution:** Filter by `is_active = true` in queries

## Advanced Scenarios

### Scenario 1: Complex Hierarchy
```csv
# Upload entire hierarchy at once
salesrep_code,salesrep_name,parent_username
CEO001,CEO Name,
RSM001,Regional Manager,CEO001
ASM001,Area Manager,RSM001
SUP001,Supervisor,ASM001
TSR001,Sales Rep,SUP001
```

Even if uploaded in random order, system creates stubs as needed.

### Scenario 2: Multiple Parents with Stubs
```csv
salesrep_code,salesrep_name,parent_username
TSR001,John Doe,"SUP001,SUP002,MGR001"
```

Creates 3 stub users if they don't exist: `SUP001`, `SUP002`, `MGR001`

### Scenario 3: Partial Existence
```csv
# SUP001 exists, SUP002 doesn't
salesrep_code,salesrep_name,parent_username
TSR001,John Doe,"SUP001,SUP002"
```

- Uses existing `SUP001`
- Creates stub for `SUP002`
- Both parent mappings created successfully

## Implementation Details

### UserStubService Methods

#### `ensureUsersExist(List<String> parentUsernames)`
- Checks which usernames exist
- Creates stubs for missing ones
- Returns map of username → isStub

#### `mergeStubIfExists(String username)`
- Checks if username is a stub
- Removes stub markers
- Activates user
- Returns true if merged

#### `getStubUsers()`
- Returns all stub users
- For admin monitoring

### Stub User Generation
```java
// Username: "john.doe"
// Generated: firstName = "John", lastName = "(Placeholder)"

// Username: "SUP001"
// Generated: firstName = "SUP001", lastName = "(Placeholder)"

// Username: "sales_rep_001"
// Generated: firstName = "Sales", lastName = "(Placeholder)"
```

## Security Considerations

- ✅ Stub users are **inactive** by default
- ✅ Cannot login (no password set)
- ✅ Tenant-isolated (RLS enforced)
- ✅ Marked clearly in `extended_attr`
- ✅ Admin-only endpoints for management

## Summary

The stub user system ensures **100% success rate** for bulk uploads with parent hierarchies by:
1. Automatically creating placeholder users for missing parents
2. Marking them as inactive stubs
3. Auto-merging when real users are created
4. Providing admin tools for monitoring and management

**Result:** Upload users in any order, zero failures, automatic cleanup! 🎉
