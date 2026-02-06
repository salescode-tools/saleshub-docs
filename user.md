# Saleshub Lite - User Guide & Feature Reference
**Product:** SalesCodeAI Saleshub Lite  
**Audience:** Administrators & Sales Operations

---

## 1. Introduction
Saleshub Lite is your central command center for managing your field sales team, distributors, and retail outlets. This guide explains how to use the system's core features to drive efficiency and sales.

---

## 2. Managing Your Team (Hierarchy)
The system allows you to model your exact organizational structure, ensuring reports roll up to the right managers.

### 2.1 The "Bottom-Up" Setup
When setting up your team via Excel/CSV upload, you only need to define the reporting chain for the staff member.
* **Format:** `Staff > Supervisor > Area Manager > Regional Manager`
* **Benefit:** You don't need to upload the CEO first. You can upload files in any order.

### 2.2 The "Smart Upload" (Stub Users)
**Feature:** Zero-Failure Data Imports.
* **How it works:** If you upload a Sales Rep whose manager is not yet in the system, the upload will **not fail**.
* **What happens:** The system automatically creates a "Placeholder" (Stub) for the missing manager.
* **Action Required:** None. When you eventually upload the manager's real details later, the system automatically "fills in" the placeholder and activates them.

---

## 3. Product & Pricing
Ensure your customers always get the right price.

### 3.1 Pricing Logic
The system automatically calculates the price for a shopkeeper based on three checks:
1.  **Is there a special price for this specific shop?** (Highest Priority)
2.  **Is there a price list for this region/distributor?**
3.  **If neither, use the standard company price.**

### 3.2 Promotions
* **Stackable Schemes:** Multiple offers can apply (e.g., "5% Discount" + "Free Gift").
* **Exclusive Schemes:** The system will automatically pick the **best single offer** for the customer if multiple exclusive schemes apply.

---

## 4. Intelligent Recommendations (ML)
The system uses AI to guide your sales reps on what to sell to each store.

### 4.1 Recommendation Types
When a Rep visits a store, the app suggests:
* **Regulars:** "This shop is running low on stock based on their buying history."
* **Upsell:** "Try to sell 5 cases instead of 3 for a better discount."
* **Cross-Sell:** "Similar shops in this area are buying this new product."

### 4.2 Targets
* Targets can be set Manually (by you) or Generated Automatically (by AI trends).
* Targets are visible on the dashboard as "Target vs. Achievement".

---

## 5. Field Operations (Automation)
### 5.1 Journey Plans (PJP)
* **Beats:** Assign specific shops to specific days (Monday Beat, Tuesday Beat).
* **Compliance:** The system tracks if a Rep actually visited the shop using GPS. They cannot "Check-In" unless they are physically at the store location.

### 5.2 Order Processing
* **Dry Run:** Reps can see the final invoice value (including all taxes and discounts) *before* confirming the order.
* **Stock Check:** The system verifies distributor inventory in real-time to prevent ordering out-of-stock items.