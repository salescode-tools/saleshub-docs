# User Association & Relationship Guide

This guide explains the specific data structures and relationships that drive the Saleshub Lite ecosystem, categorized by functional association.

---

## 1. How Users are Associated with Outlets
When an outlet is created with associated users (like owners or managers), they are linked via the `user_org_map` table.

- **Table:** `user_org_map`
- **Logic:** Connects a `user_id` (username) to an `org_code` (outlet code) with `org_type = 'RETAILER'`.

```mermaid
graph LR
    U[App User] -- "owns/manages" --> UOM[User Org Map]
    UOM -- "org_type: RETAILER" --> O[Outlet]
    
    style UOM fill:#f9f,stroke:#333
    style O fill:#bbf,stroke:#333
```

---

## 2. How Outlets are Associated with SalesReps
This association defines the "Sales Beat" or territory assignment. It tells the system which SalesRep is responsible for taking orders from which outlet.

- **Table:** `retailer_map`
- **Logic:** Maps `outlet_code` to `salesrep_code`.

```mermaid
graph TD
    SR[SalesRep User]
    O1[Outlet A]
    O2[Outlet B]
    RM[Retailer Map]

    SR -- "assigned to" --> RM
    RM -- "serves" --> O1
    RM -- "serves" --> O2
    
    style RM fill:#ff9,stroke:#333,stroke-width:2px
```

---

## 3. How Outlets are Associated with Distributors
This defines the supply chain fulfillment. When an order is placed for an outlet, the system knows which distributor should fulfill it.

- **Table:** `retailer_map`
- **Logic:** Maps `outlet_code` to `distributor_code`.

```mermaid
graph LR
    O[Outlet] -- "purchases from" --> RM[Retailer Map]
    RM -- "fulfilled by" --> D[Distributor]
    
    style RM fill:#ff9,stroke:#333
    style D fill:#dfd,stroke:#333
```

---

## 4. The Business Triad (Combined View)
In practice, the `retailer_map` table acts as the nexus for the Outlet, SalesRep, and Distributor triad.

```mermaid
graph TD
    O[Outlet] <--> RM{Retailer Map}
    RM <--> SR[SalesRep]
    RM <--> D[Distributor]

    note[This single row defines the <br/> Route, Reach, and Fulfillment]
    RM --- note
    
    style RM fill:orange,color:white,stroke-width:4px
```

---

## 5. How Users are Associated with Parents (Hierarchy)
This is a purely administrative/management relationship. It defines the reporting structure (e.g., SalesRep reporting to a Supervisor).

- **Table:** `user_parent_map`
- **Logic:** A child `user_username` reports to a `parent_username`. This supports N-level deep hierarchies.

```mermaid
graph TD
    ZSM[Zonal Sales Manager]
    RSM[Regional Sales Manager]
    ASM[Area Sales Manager]
    SR[SalesRep]

    SR -- "reports to" --> ASM
    ASM -- "reports to" --> RSM
    RSM -- "reports to" --> ZSM

    subgraph "User Parent Map"
    UPM1[Mapping: SR -> ASM]
    UPM2[Mapping: ASM -> RSM]
    UPM3[Mapping: RSM -> ZSM]
    end
    
    style UPM1 fill:#eee,stroke-dasharray: 5 5
    style UPM2 fill:#eee,stroke-dasharray: 5 5
    style UPM3 fill:#eee,stroke-dasharray: 5 5
```

---

## Relationship Summary Table

| Relationship | Table Used | Key Joining Column 1 | Key Joining Column 2 | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **User ↔ Outlet** | `user_org_map` | `user_id` | `org_code` | Defines ownership/management access. |
| **Outlet ↔ SalesRep** | `retailer_map` | `outlet_code` | `salesrep_code` | Defines sales assignment (The Beat). |
| **Outlet ↔ Dist** | `retailer_map` | `outlet_code` | `distributor_code` | Defines stock fulfillment source. |
| **User ↔ Parent** | `user_parent_map`| `user_username` | `parent_username` | Defines management reporting (Hierarchy). |
| **Role ↔ User** | `user_role` | `user_id` | `role_id` | Defines system permissions (e.g. Admin). |
