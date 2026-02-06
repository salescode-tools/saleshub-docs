
# 🌟 Salescodeai Saleshub: Meta Feature Reference

> **A Comprehensive Guide to Platform Capabilities by Domain**

This document serves as a detailed reference for the functional capabilities of the Saleshub platform, categorized by business domain. It is designed to explain *what* the system does and *how* it handles complex scenarios like multi-tenancy, hierarchy, and automated routing.

---

## 👥 1. User & Organization Management

### **User Types**
*   **System Users**: Admins with access to the console.
*   **Field Users (Sales Reps)**: Mobile users with route plans and order-taking capabilities.
*   **Retailer Users**: Direct customers who can log in via PWA/App to place self-service orders.
*   **Distributor Users**: Partners who manage inventory and fulfillment.

### **Organization Hierarchy**
The platform supports a flexible, N-level hierarchy to model any sales organization structure (e.g., `Country` -> `Zone` -> `Region` -> `Territory`).
*   **Inheritance**: Data and policies (like price lists) can cascade down the hierarchy.
*   **Visibility**: Users at a `Zone` level automatically see data for all child `Territories`.

### **Location Mapping**
*   **Geo-Fencing**: Every entity (Outlet, User, Distributor) can have Lat/Lon coordinates and polygon boundaries.
*   **Distance Calculation**: Built-in geospatial engine allows for "Near Me" searches (e.g., finding outlets within 500m of a Sales Rep).

---

## 🏪 2. Outlet Management & Unification

### **Master Data**
*   **Rich Profile**: Stores generic details (Name, Address) and simplified/extended attributes (Channel, Segment, Credit Limit).
*   **Classification**: Outlets are tagged with `Channel` (e.g., Grocery, Pharma) and `Class` (A, B, C) for targeted promotions.

### **Unification (De-Duplication)**
A powerful feature to prevent data silos when Retailers self-onboard.
*   **Identity Resolution**: When a new user registers, the system attempts to match them to an existing Outlet Master.
*   **Matching Logic**:
    1.  **Exact Match**: Phone number match (100% confidence) -> Auto-Link.
    2.  **Fuzzy Match**: Name + Proximity (within 5km) -> Suggest Candidates.
*   **Benefit**: Ensures historical sales data is preserved even if the retailer registers a new digital account.

---

## 🚚 3. Distributor & Network

### **Distributor Master**
*   **Inventory & Warehousing**: Real-time stock visibility per distributor.
*   **Coverage Mapping**: Defines which outlets a distributor serves (Static Map) or which territories they cover (Geo Map).

### **Auto-Distributor Mapping (Zero-Touch)**
For unmapped retailers (new self-service users), the system intelligently routes them:
1.  **Pincode Match**: User's postal code is matched against Distributor service areas.
2.  **Geo-Spatial Fallback**: If no pincode match, system finds the **nearest active distributor** within a configurable radius (default 5km).
*   **Result**: A new retailer can start ordering *immediately* without manual admin approval.

---

## 🛒 4. Catalog & Product Discovery

### **Context-Aware Catalog**
The catalog API is not static; it transforms based on **who** is looking.
*   **Pricing Scopes**: Resolves prices in order: `Outlet Specific` > `Distributor Specific` > `Sales Rep Specific` > `Global List Price`.
*   **Entitlements**: automatically hides products that a specific distributor doesn't carry or an outlet isn't allowed to buy.

### **Multi-Principal Support**
*   **Unified Shelf**: A single app can display products from multiple manufacturers (Principles) if the tenant hierarchy is configured as a Marketplace/Aggregator.
*   **Source Tracking**: Each product retains its `TenantId` (Source of Truth), ensuring that orders are routed back to the correct principal's system.

---

## 📦 5. Order Management

### **Order Processing**
*   **Full Lifecycle**: `Draft` -> `Confirmed` -> `Invoiced` -> `Shipped` -> `Delivered` -> `Paid`.
*   **Validation**: Real-time checks for Credit Limit, Stock Availability, and MOQ (Minimum Order Quantity).

### **Splitted Orders (Multi-Distributor Routing)**
When a retailer adds items from different suppliers into one cart:
*   **Split Logic**: The system detects that SKU A is served by Distributor X and SKU B by Distributor Y.
*   **Execution**: On checkout, the single "Basket" is split into **two distinct Child Orders**, each routed to the respective distributor's dashboard. The Retailer sees a unified receipt, but fulfillment is decoupled.

---

## 🎁 6. Promotions & Schemes

### **Promotion Engine**
A rules-based engine that applies discounts dynamically.
*   **Types**:
    *   **QPS (Quantity Purchase Scheme)**: "Buy 10 cases, get 5% off".
    *   **Free Goods**: "Buy 10 SKU A, get 1 SKU B Free".
    *   **Value Off**: "Buy $500 worth, get $50 off".
*   **Targeting**: Promotions can be targeted at specific `Channels`, `Segments` (Gold/Silver), or `Geo-Locations`.

### **Banners & Baskets**
*   **Smart Banners**: Dashboard visuals targeted to specific user segments to drive engagement (e.g., "Monsoon Sale" banner only for Coastal regions).
*   **Curated Baskets**: One-click "Quick Order" baskets (e.g., "Starter Pack", "Top Sellers") to speed up ordering for new shops.

---

## ✅ 7. Field Force Excellence

### **Task Management**
*   **Smart Tasks**: Auto-generated activities for Sales Reps (e.g., "Collect Outstanding Payment", "Audit New Product Placement").
*   **Verification**: Tasks can require Photo Proof, Geo-Checkin, or Form Submission to be marked complete.

### **Target Groups & Performance**
*   **Goals**: Set Monthly/Quarterly targets for Sales Reps (Revenue, Coverage, New Outlets).
*   **Tracking**: Real-time vs Target visualization on the mobile app to drive performance.

---

## 🔒 8. Audit & Compliance

### **Comprehensive Audit Trail**
Every critical action within the platform is recorded in an immutable audit log.
*   **Technical Traceability**: Captures `IP Address`, `User Agent`, and `Timestamps` for every event.
*   **Business Transparency**: Logs changes to `Orders`, `Settings`, and `User Profiles`, including "Before" and "After" states in the details payload.
*   **Searchable Logs**: Administrators can filter logs by `Operation Type`, `User`, or `Date` for rapid incident response.

For technical details, see the [Audit Log API Documentation](./AUDIT_LOG_API.md).
