# Cross-Tenant & Hierarchical Multi-Tenancy Design

This document outlines the architecture for supporting cross-tenant data access, allowing users in a "Parent" tenant to manage, view, and interact with data residing in multiple "Child" tenants.

## 1. Core Philosophy
The system transitions from a **Strict Isolation** model to a **Hierarchical Trust** model:
*   **Home Tenant**: Every `app_user` belongs to a single "Home" tenant (their identity provider).
*   **Target Tenant(s)**: Users can act upon data in other tenants if a trust relationship exists.
*   **Cross-Tenant Data**: Entities like Outlets, Products, and Banners reside in specific "Child" tenants, but are visible to authorized "Parent" users.

## 2. Database Schema Changes

### 2.1 Tenant Table
The `tenant` table is enhanced to store the hierarchy definition.
```sql
ALTER TABLE tenant ADD COLUMN child_tenants TEXT[] DEFAULT '{}';
```
*   `child_tenants`: An array containing IDs of all accounts that fall under this tenant's management umbrella.

### 2.2 Global User Identity
In a cross-tenant model, `app_user.id` becomes the global identifier. Foreign keys in data tables should point to `user.id` rather than the composite `(tenant_id, user_id)`.

## 3. Row-Level Security (RLS) Implementation

To allow fetching data across multiple tenants in a single query, the RLS policies must be updated to handle **Set-Based Visibility**.

### 3.1 Session Initialization
When the application connects to the database, it must communicate the authorized scope:
```sql
-- Set the user's home/identity tenant
SET app.user_home_tenant = 'parent_co';

-- Set the specific tenants the user wants to query right now
SET app.allowed_tenants = '{child_a, child_b, child_c}';
```

### 3.2 Dynamic RLS Policy
The RLS policies on data tables (e.g., `outlet`, `product`) are updated to use the `app.allowed_tenants` array.

```sql
-- Example for the 'outlet' table
DROP POLICY IF EXISTS outlet_isolation_policy ON outlet;

CREATE POLICY outlet_cross_tenant_policy ON outlet
FOR ALL
USING (
    -- Standard Isolation: Allow if the row belongs to the target context
    tenant_id = current_setting('app.tenant_id', true)
    OR
    -- Cross-Tenant Read/Write: Allow if the row's tenant is in the allowed set
    tenant_id = ANY(string_to_array(NULLIF(current_setting('app.allowed_tenants', true), ''), ','))
);
```

## 4. Application Layer Implementation

### 4.1 JWT Claims
The JWT issued during authentication should include the hierarchy info to reduce DB lookups:
```json
{
  "sub": "TSR001",
  "home_tenant": "parent_company",
  "managed_tenants": ["child_1", "child_2", "child_3"],
  "roles": ["REGIONAL_ADMIN"]
}
```

### 4.2 API Context Handling
The backend uses a `TenantContext` to manage cross-tenant logic:
1.  **Extraction**: Get the list of `managed_tenants` from the JWT.
2.  **Request Parameter**: Capture an optional `tenantIds` query parameter from the API request (e.g., `GET /outlets?tenantIds=child1,child2`).
3.  **Validation**: Intersect the requested `tenantIds` with the user's `managed_tenants`.
4.  **Injection**: Set the `app.allowed_tenants` variable in the SQL session before executing the query.

### 4.3 Aggregated Fetch Example
To fetch outlets across 5 tenants in "one go":
**Endpoint**: `GET /outlets?tenantIds=T1,T2,T3,T4,T5`

**SQL Executed**:
```sql
SELECT * FROM outlet WHERE ...; -- Returns items from all 5 tenants automatically via RLS
```

## 5. Security & Isolation
*   **Validation Gate**: The application MUST validate that every ID in `app.allowed_tenants` is actually a child of the authenticated user's `home_tenant`.
*   **Scoped Actions**: For "Write" operations (POST/PUT), the client should still provide a specific `X-Target-Tenant-Id` header to ensure the intent is explicit.
*   **Auditability**: Every record created cross-tenant will have its native `tenant_id` (the target) and can store the creator's global user ID for internal audit.
