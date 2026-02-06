# Developer Architecture & Implementation Guide
**Project:** SalesCodeAI Saleshub Lite  
**Version:** 1.0  
**Tech Stack:** Java 17, Quarkus 3.x, PostgreSQL 16 (PostGIS), AWS

---

## 1. System Architecture
Saleshub Lite is designed as a **Multi-Tenant SaaS Platform** optimized for high-volume B2B commerce.

### 1.1 Core Components
* **Runtime:** Quarkus (Native & JVM mode support) for low-memory footprint and fast startup.
* **Database:** PostgreSQL 16 using **Row-Level Security (RLS)** for tenant isolation.
    * *Rule:* Every query MUST inject `tenant_id` into the session context.
* **Auth:** JWT-based stateless authentication.
    * *Token:* Contains `sub` (username), `tenant_id`, and `roles`.
* **API Pattern:** RESTful services following the Controller-Service-DAO pattern.

### 1.2 Data Isolation Strategy (Critical)
* **Tenant Isolation:** Enforced at the database level using RLS policies.
* **User Isolation:** Data visibility is controlled by the Hierarchy (Reporting Manager) logic. A user can only access data belonging to them or their subordinates.

---

## 2. Key Modules & Implementation Logic

### 2.1 User & Hierarchy Management
The system supports complex organizational structures using a **Bottom-Up** definition strategy.

* **Hierarchy Path:** Users are defined by their path: `Sales Rep > Manager > Regional Head > CEO`.
* **Parsing Logic:** The backend parses the `hierarchy_path` string to dynamically construct the DAG (Directed Acyclic Graph) of relationships.
* **The "Stub User" Mechanism (Fault Tolerance):**
    * *Problem:* Bulk uploads often fail due to out-of-order records (e.g., uploading a child before the parent).
    * *Solution (`UserStubService`):* The system intercepts missing `parent_usernames`.
    * *Logic:* It creates an **inactive** placeholder user (`is_stub=true`, `is_active=false`).
    * *Auto-Merge:* When the real parent record is eventually uploaded, the `UserStubService` detects the collision, updates the metadata, activates the user, and preserves the child relationships.

### 2.2 Product & Pricing Engine
Pricing is resolved dynamically at runtime (Read-Heavy operation).

* **Price Resolution Priority:**
    1.  **Outlet Mapping:** Specific price for a specific store.
    2.  **Distributor Mapping:** Price list assigned to the distributor servicing the store.
    3.  **Global Standard:** Base MRP/Selling Price.
* **Performance Note:** Use Redis caching for Price Lists as they are high-read/low-write.

### 2.3 ML Recommendations Engine
The module generates `Target` and `Recommendation` entities based on historical order data.

* **Prediction Model:** Linear regression on sales trends per `(loginId + outletCode)` tuple.
* **Recommendation Types:**
    * `REGULAR`: Replenishment based on frequency.
    * `CROSS_SELL`: Collaborative filtering based on similar outlet profiles.
    * `UPSELL`: Quantity boosting logic.

---

## 3. Automation & Workflow (PJP)
**PJP (Permanent Journey Plan)** is the scheduling engine.

* **Entity Relationship:** `User` -> `PJP_Header` (The Plan) -> `PJP_Detail` (The Day) -> `Outlet` (The Stop).
* **Geofencing:** Backend validates coordinates (`lat`, `long`) against `outlet_location` within a configurable radius (default 50m) before allowing "Check-In".

---

## 4. Testing Strategy
We follow the **Test Pyramid** approach.

* **Unit Tests (60%):** Mocking DAOs using Mockito.
* **Integration Tests (30%):** `@QuarkusTest` using H2 or TestContainers (Postgres).
    * *Requirement:* Must test `X-Tenant-Id` header injection.
    * *Requirement:* Must test HTTP 403 scenarios for Cross-Tenant access.
* **E2E (10%):** Critical flows (Order Lifecycle, User Onboarding).

---

## 5. API Guidelines
* **Response Format:** Standard Envelope `Result<T>`.
* **Error Handling:** Global Exception Mapper maps specific exceptions (e.g., `UserNotFoundException`) to standard HTTP codes (404).
* **Date Formats:** ISO-8601 (`yyyy-MM-dd'T'HH:mm:ss.SSSZ`) for all timestamps.