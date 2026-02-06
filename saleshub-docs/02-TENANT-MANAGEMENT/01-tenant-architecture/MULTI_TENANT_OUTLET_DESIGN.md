# Multi-Tenant Outlet Propagation - Design Document

## Overview

This document describes the design for allowing a parent tenant to register an outlet that gets replicated across multiple child tenants. This enables hierarchical distribution networks where a brand/HQ can manage outlets that operate under different regional distributors.

## Current Architecture Analysis

### Existing Components
1. **Tenant Hierarchy**: Parent tenants can have child tenants (stored in `tenant.child_tenants` array)
2. **RLS (Row-Level Security)**: All tables use `app.tenant_id` GUC for isolation
3. **DbPerTenant**: Provides `tx(tenantId, fn)` for explicit tenant context switching
4. **Outlet Table**: Has `tenant_id` column with RLS enabled

### Key Constraint
The current architecture uses **per-tenant isolation** where:
- Each tenant has its own data scope via RLS
- Outlets are uniquely identified by `(tenant_id, code)`
- Cross-tenant queries are not natively supported

## Proposed Solution

### Design Pattern: **Cross-Tenant Replication**

Instead of a single outlet existing in multiple tenants, we **replicate** the outlet data to each child tenant independently. This maintains data isolation while allowing centralized management.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Parent Tenant (HQ)                      │
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ POST /api/tenants/propagate-outlets                    │ │
│  │ {                                                       │ │
│  │   "outlet": { code, name, address, ... },             │ │
│  │   "targetTenantIds": ["child1", "child2"]             │ │
│  │ }                                                       │ │
│  └────────────────────────────────────────────────────────┘ │
│                           │                                  │
└───────────────────────────┼──────────────────────────────────┘
                            │
                            ▼
              ┌─────────────────────────────┐
              │   TenantDao.propagateOutlet │
              │   (Transaction Coordinator)  │
              └─────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        ▼                                       ▼
┌───────────────────┐                 ┌───────────────────┐
│  Child Tenant 1   │                 │  Child Tenant 2   │
│                   │                 │                   │
│  outlet table:    │                 │  outlet table:    │
│  - tenant_id: c1  │                 │  - tenant_id: c2  │
│  - code: OUT_001  │                 │  - code: OUT_001  │
│  - name: Store A  │                 │  - name: Store A  │
└───────────────────┘                 └───────────────────┘
```

### Implementation Strategy

#### 1. **API Layer** (`TenantResource`)
```java
@POST
@Path("/propagate-outlets")
public Response propagateOutlets(PropagateOutletRequest req)
```
- Validates parent is TENANT_ADMIN
- Validates target tenants are children of current tenant
- Delegates to `TenantDao.propagateOutlet()`

#### 2. **DAO Layer** (`TenantDao`)
```java
public void propagateOutlet(String parentId, List<String> targetTenantIds, CreateOutletRequest req)
```
- Iterates through each target tenant
- Uses `db.tx(childTenantId, conn -> {...})` for explicit tenant context
- Executes raw SQL INSERT for each child tenant
- Uses `ON CONFLICT DO NOTHING` for idempotency

#### 3. **Database Layer**
- No schema changes required
- Leverages existing RLS policies
- Each child tenant gets an independent copy of the outlet

### Data Flow

1. **Parent Request**: Parent tenant sends outlet data + list of child tenant IDs
2. **Validation**: System verifies children are valid and belong to parent
3. **Replication Loop**: For each child tenant:
   - Switch DB context to child tenant
   - Insert outlet with child's `tenant_id`
   - RLS ensures data isolation
4. **Response**: Return success/failure status

### Key Design Decisions

#### ✅ **Replication vs. Shared Reference**
- **Chosen**: Replication
- **Rationale**: 
  - Maintains existing RLS architecture
  - No cross-tenant foreign keys needed
  - Each child can modify their copy independently
  - Simpler query patterns (no joins across tenants)

#### ✅ **Raw SQL vs. DAO Reuse**
- **Chosen**: Raw SQL in `TenantDao.propagateOutlet()`
- **Rationale**:
  - OutletDao methods use `TenantContext` which is request-scoped
  - Explicit `db.tx(tenantId, ...)` bypasses context issues
  - Avoids circular dependencies
  - More explicit and debuggable

#### ✅ **Transaction Boundaries**
- **Chosen**: Separate transaction per child tenant
- **Rationale**:
  - Failure in one child doesn't rollback others
  - Better for large-scale propagation
  - Easier error reporting per tenant

### Current Implementation Status

#### ✅ Completed
1. `PropagateOutletRequest` DTO
2. `TenantDao.propagateOutlet()` method
3. `TenantResource.propagateOutlets()` endpoint
4. Integration test (`test_multi_tenant_outlet_propagation.py`)

#### ⚠️ Current Issue
The test is failing with **404 Not Found** when querying the outlet in child tenants, despite:
- No errors in propagation logs
- `db.tx(childId, ...)` being called
- SQL INSERT being executed

#### 🔍 Debugging Needed
Possible causes:
1. **RLS Policy Issue**: The `WITH CHECK` clause might be rejecting inserts
2. **Connection Pool Issue**: Child tenant pool might not be initialized
3. **Transaction Commit Issue**: Changes might not be committed
4. **Query Issue**: GET request might be using wrong tenant context

### Testing Strategy

```python
def test_propagate_outlet_to_children():
    # 1. Create 2 child tenants
    # 2. Propagate outlet to both
    # 3. Login as child1, verify outlet exists
    # 4. Login as child2, verify outlet exists
    # 5. Verify outlets are independent (different tenant_ids)
```

#### ✅ **Organic Tenant Switching**
- **Feature**: Use `X-Tenant-Child` header to act on behalf of a child tenant.
- **Rationale**: 
  - Allows parent to use standard APIs (e.g., `POST /outlets`) instead of special propagation endpoints for simple child-specific edits.
  - Maintains full security by validating the parent-child relationship in `JwtAuthFilter`.
  - Simplifies integration for parents managing complex hierarchies.

### Future Enhancements

1. **Bulk Propagation**: Support multiple outlets in one request
2. **Selective Sync**: Update existing outlets if they already exist
3. **Cascade Delete**: Option to delete from all children when deleted from parent
4. **Audit Trail**: Track which outlets were propagated to which tenants
5. **Conflict Resolution**: Handle cases where child already has outlet with same code

### Migration Path

**No breaking changes** - this is a purely additive feature:
- Existing outlet creation flows unchanged
- Existing RLS policies unchanged
- New endpoint is opt-in

### Security Considerations

1. **Authorization**: Only TENANT_ADMIN can propagate
2. **Validation**: Target tenants must be in parent's `child_tenants` array
3. **Isolation**: RLS ensures children can't see each other's data
4. **Audit**: All propagations should be logged

### Performance Considerations

1. **Batch Size**: Limit number of target tenants per request (e.g., 50)
2. **Async Option**: For large propagations, consider background job
3. **Connection Pooling**: Ensure child tenant pools are pre-warmed

---

## Next Steps

1. **Debug Current Issue**: Investigate why outlets aren't being found in child tenants
2. **Add Validation**: Verify target tenants are actually children
3. **Add Logging**: Comprehensive logging for debugging
4. **Documentation**: Update API docs with examples
5. **Error Handling**: Better error messages for common failure modes
