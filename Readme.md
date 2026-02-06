# SalesHub Platform Documentation

Welcome to the comprehensive technical documentation for the **SalesHub Platform** - a world-class B2B sales and distribution management system. This documentation is organized to help you quickly find the information you need, whether you're a new user, developer, administrator, or business analyst.

## 📚 Quick Navigation


### **For Developers** → Start with **[Developer-Quick-Review](developer.md)**
### **For Users** → Start with **[User-quick-review](user.md)**

---

## 📖 **FOUNDATION: START HERE**
*For complete beginners to understand the platform*

### **01-overview**
- **[PROJECT_ABSTRACT.md](saleshub-docs/00-FOUNDATION/01-overview/PROJECT_ABSTRACT.md)** - What is SalesHub?
- **[CUSTOMER_FEATURE_GUIDE.md](saleshub-docs/00-FOUNDATION/01-overview/CUSTOMER_FEATURE_GUIDE.md)** - What can you do with it? 
- **[WORLD_CLASS_B2B_PLATFORM_ROADMAP.md](saleshub-docs/00-FOUNDATION/01-overview/WORLD_CLASS_B2B_PLATFORM_ROADMAP.md)** - Where is it going?

### **02-architecture**
- **[META_FEATURE_REFERENCE.md](saleshub-docs/00-FOUNDATION/02-architecture/META_FEATURE_REFERENCE.md)** - All features explained 
- **[COMPARISON_MATRIX.md](saleshub-docs/00-FOUNDATION/02-architecture/COMPARISON_MATRIX.md)** - How it compares to competitors 

### **03-getting-started**
- **[DIGIVYAPAR_WORKFLOW.md](saleshub-docs/00-FOUNDATION/03-getting-started/DIGIVYAPAR_WORKFLOW.md)** - Multi-brand onboarding 
- **[SALESHUB_VS_ODOO.md](saleshub-docs/00-FOUNDATION/03-getting-started/SALESHUB_VS_ODOO.md)** - Detailed feature comparison

---

## 🔐 **AUTHENTICATION & SECURITY**
*How to access the platform*

### **01-core-auth**
- **[API_DOCUMENTATION.md](saleshub-docs/01-AUTHENTICATION/01-core-auth/API_DOCUMENTATION.md)** - Main auth guide 
- **[USER_REGISTRATION_API.md](saleshub-docs/01-AUTHENTICATION/01-core-auth/USER_REGISTRATION_API.md)** - User account creation 
- **[OTP_REGISTRATION.md](saleshub-docs/01-AUTHENTICATION/01-core-auth/OTP_REGISTRATION.md)** - Phone verification 

### **02-external-auth**
- **[OAUTH_API.md](saleshub-docs/01-AUTHENTICATION/02-external-auth/OAUTH_API.md)** - External app authentication 
- **[PLUGIN_SUBSCRIPTION_API.md](saleshub-docs/01-AUTHENTICATION/02-external-auth/PLUGIN_SUBSCRIPTION_API.md)** - Third-party app auth 

### **03-security**
- **[user_permission.sql](saleshub-docs/01-AUTHENTICATION/03-security/user_permission.sql)** - Database security setup 
- **[REGISTRATIONS.md](saleshub-docs/01-AUTHENTICATION/03-security/REGISTRATIONS.md)** - User registration overview 

### **04-examples**
- **[otp_registration_flow.sh](saleshub-docs/01-AUTHENTICATION/04-examples/otp_registration_flow.sh)** - OTP example script 

---

## 🏢 **TENANT & ORGANIZATION MANAGEMENT**
*How companies are structured in SalesHub*

### **01-tenant-architecture**
- **[CROSS_TENANT_DESIGN.md](saleshub-docs/02-TENANT-MANAGEMENT/01-tenant-architecture/CROSS_TENANT_DESIGN.md)** - Technical design 
- **[MULTI_TENANT_OUTLET_DESIGN.md](saleshub-docs/02-TENANT-MANAGEMENT/01-tenant-architecture/MULTI_TENANT_OUTLET_DESIGN.md)** - Outlet propagation

### **02-tenant-api**
- **[TENANT_API.md](saleshub-docs/02-TENANT-MANAGEMENT/02-tenant-api/TENANT_API.md)** - Managing companies

### **03-location-hierarchy**
- **[Location.md](saleshub-docs/02-TENANT-MANAGEMENT/03-location-hierarchy/Location.md)** - Geographic hierarchy
- **[USER_ASSOCIATION_GRAPH.md](saleshub-docs/02-TENANT-MANAGEMENT/03-location-hierarchy/USER_ASSOCIATION_GRAPH.md)** - User relationships 

### **04-configuration**
- **[SETTINGS_API.md](saleshub-docs/02-TENANT-MANAGEMENT/04-configuration/SETTINGS_API.md)** - Configuration management
- **[settings.md](saleshub-docs/02-TENANT-MANAGEMENT/04-configuration/settings.md)** - System settings 
- **[SYSTEM_SETTINGS_GUIDE.md](saleshub-docs/02-TENANT-MANAGEMENT/04-configuration/SYSTEM_SETTINGS_GUIDE.md)** - Settings reference 

---

## 🏪 **OUTLETS & RETAILERS**
*Managing stores and shop owners*

### **01-outlet-management**
- **[OUTLET_API.md](saleshub-docs/06-RETAILER-MANAGEMENT/01-outlet-management/OUTLET_API.md)** - Store operations
- **[UNIFICATION_API.md](saleshub-docs/06-RETAILER-MANAGEMENT/01-outlet-management/UNIFICATION_API.md)** - Preventing duplicate outlets 

### **02-mapping-relationships**
- **[RETAILER_MAP_API.md](saleshub-docs/06-RETAILER-MANAGEMENT/02-mapping-relationships/RETAILER_MAP_API.md)** - Store-distributor mapping 
- **[RetailerMapping.md](saleshub-docs/06-RETAILER-MANAGEMENT/02-mapping-relationships/RetailerMapping.md)** - Relationship overview 
- **[OUTLET_MAPPING_API.md](saleshub-docs/06-RETAILER-MANAGEMENT/02-mapping-relationships/OUTLET_MAPPING_API.md)** - Mapping operations 

### **03-service-coverage**
- **[SERVICEABILITY_API.md](saleshub-docs/06-RETAILER-MANAGEMENT/03-service-coverage/SERVICEABILITY_API.md)** - Coverage areas 

---

## 🛍️ **PRODUCTS & CATALOG**
*Managing what you sell*

### **01-catalog-api**
- **[CATALOG_API.md](saleshub-docs/03-CATALOG-MANAGEMENT/01-catalog-api/CATALOG_API.md)** - Product listing and search
- **[CATALOG_META_API.md](saleshub-docs/03-CATALOG-MANAGEMENT/01-catalog-api/CATALOG_META_API.md)** - Brands, categories 

### **02-products**
- **[PRODUCT_API.md](saleshub-docs/03-CATALOG-MANAGEMENT/02-products/PRODUCT_API.md)** - SKU management 
- **[PRODUCT_PRICING_ENTITLEMENT_GRAPH.md](saleshub-docs/03-CATALOG-MANAGEMENT/02-products/PRODUCT_PRICING_ENTITLEMENT_GRAPH.md)** - Pricing structure 

### **03-units-measurement**
- **[UOM_SUPPORT.md](saleshub-docs/03-CATALOG-MANAGEMENT/03-units-measurement/UOM_SUPPORT.md)** - Units of measure 

### **04-banners-baskets**
- **[BANNER_BASKET_API.md](saleshub-docs/03-CATALOG-MANAGEMENT/04-banners-baskets/BANNER_BASKET_API.md)** - Ads and collections 
- **[BANNERS.md](saleshub-docs/03-CATALOG-MANAGEMENT/04-banners-baskets/BANNERS.md)** - Advertising features 

---

## 📦 **ORDERS & TRANSACTIONS**
*The buying process*

### **01-order-apis**
- **[ORDER_API.md](saleshub-docs/04-ORDER-MANAGEMENT/01-order-apis/ORDER_API.md)** - Complete order system 
- **[TAX_API.md](saleshub-docs/04-ORDER-MANAGEMENT/01-order-apis/TAX_API.md)** - Tax calculations 

### **02-order-workflows**
- **[COMPLETE_ORDER_LIFECYCLE_GUIDE.md](saleshub-docs/04-ORDER-MANAGEMENT/02-order-workflows/COMPLETE_ORDER_LIFECYCLE_GUIDE.md)** - Step-by-step workflow 
- **[DELIVERY_CONFIG_API.md](saleshub-docs/04-ORDER-MANAGEMENT/02-order-workflows/DELIVERY_CONFIG_API.md)** - Delivery schedules 

### **03-inventory**
- **[STOCK_API.md](saleshub-docs/04-ORDER-MANAGEMENT/03-inventory/STOCK_API.md)** - Stock management 

---

## 🎯 **PRICING & PROMOTIONS**
*Offers and discounts*

### **01-pricing-engine**
- **[Pricing.md](saleshub-docs/05-PRICING-PROMOTIONS/01-pricing-engine/Pricing.md)** - Price rule engine 

### **02-promotion-engine**
- **[PROMOTION_API.md](saleshub-docs/05-PRICING-PROMOTIONS/02-promotion-engine/PROMOTION_API.md)** - Campaign management 
- **[PROMOTION_ENGINE_GUIDE.md](saleshub-docs/05-PRICING-PROMOTIONS/02-promotion-engine/PROMOTION_ENGINE_GUIDE.md)** - How promotions work 
- **[PROMOTION_TARGETING_GUIDE.md](saleshub-docs/05-PRICING-PROMOTIONS/02-promotion-engine/PROMOTION_TARGETING_GUIDE.md)** - Audience targeting 

### **03-retailer-promotions**
- **[PROMOTIONS_RETAILER_API.md](saleshub-docs/05-PRICING-PROMOTIONS/03-retailer-promotions/PROMOTIONS_RETAILER_API.md)** - Store-specific offers 
- **[PROMOTIONS_RETAILER_IMPLEMENTATION.md](saleshub-docs/05-PRICING-PROMOTIONS/03-retailer-promotions/PROMOTIONS_RETAILER_IMPLEMENTATION.md)** - Integration guide 

### **04-schemes**
- **[SCHEMES.md](saleshub-docs/05-PRICING-PROMOTIONS/04-schemes/SCHEMES.md)** - Discount programs 

### **05-audit-analytics**
- **[ORDER_PROMO_AUDIT_ANALYTICS.md](saleshub-docs/05-PRICING-PROMOTIONS/05-audit-analytics/ORDER_PROMO_AUDIT_ANALYTICS.md)** - Promotion performance 
- **[ORDER_PROMO_AUDIT_FREE_SKU.md](saleshub-docs/05-PRICING-PROMOTIONS/05-audit-analytics/ORDER_PROMO_AUDIT_FREE_SKU.md)** - Free item tracking 

---

## 🚶 **FIELD FORCE MANAGEMENT**
*Managing sales representatives*

### **01-attendance-pjp**
- **[ATTENDANCE_PJP_FLOW.md](saleshub-docs/07-FIELD-FORCE-MANAGEMENT/01-attendance-pjp/ATTENDANCE_PJP_FLOW.md)** - Daily workflow 
- **[PJP_API_REFERENCE.md](saleshub-docs/07-FIELD-FORCE-MANAGEMENT/01-attendance-pjp/PJP_API_REFERENCE.md)** - Route planning 
- **[PJP_VISIT_API.md](saleshub-docs/07-FIELD-FORCE-MANAGEMENT/01-attendance-pjp/PJP_VISIT_API.md)** - Visit management 

### **02-tasks-targets**
- **[TASK_ENGINE.md](saleshub-docs/07-FIELD-FORCE-MANAGEMENT/02-tasks-targets/TASK_ENGINE.md)** - Automated tasks 
- **[Task.md](saleshub-docs/07-FIELD-FORCE-MANAGEMENT/02-tasks-targets/Task.md)** - Task management 
- **[Target.md](saleshub-docs/07-FIELD-FORCE-MANAGEMENT/02-tasks-targets/Target.md)** - Sales targets 

### **03-references**
- **[PJP.md](saleshub-docs/07-FIELD-FORCE-MANAGEMENT/03-references/PJP.md)** - Journey planning overview 

---

## 📊 **ANALYTICS & REPORTING**
*Data and insights*

### **01-analytics**
- **[Analytics.md](saleshub-docs/08-ANALYTICS-REPORTING/01-analytics/Analytics.md)** - Trend analysis
- **[Sales.md](saleshub-docs/08-ANALYTICS-REPORTING/01-analytics/Sales.md)** - Sales reporting 

### **02-audit-logs**
- **[AUDIT_LOG_API.md](saleshub-docs/08-ANALYTICS-REPORTING/02-audit-logs/AUDIT_LOG_API.md)** - Activity tracking 

### **03-knowledge-base**
- **[FAQ.md](saleshub-docs/08-ANALYTICS-REPORTING/03-knowledge-base/FAQ.md)** - Frequently asked questions 
- **[FAQ_BULK_IMPORT.md](saleshub-docs/08-ANALYTICS-REPORTING/03-knowledge-base/FAQ_BULK_IMPORT.md)** - Mass FAQ upload 

---

## 🔄 **INTEGRATION & APIs**
*Connecting with other systems*

### **01-data-management**
- **[MDM_TEMPLATES_API.md](saleshub-docs/09-INTEGRATION-APIS/01-data-management/MDM_TEMPLATES_API.md)** - Data templates
- **[MDM_UPLOAD_API.md](saleshub-docs/09-INTEGRATION-APIS/01-data-management/MDM_UPLOAD_API.md)** - Bulk data upload 

### **02-file-management**
- **[FILE_UPLOAD.md](saleshub-docs/09-INTEGRATION-APIS/02-file-management/FILE_UPLOAD.md)** - Document upload 
- **[Upload.md](saleshub-docs/09-INTEGRATION-APIS/02-file-management/Upload.md)** - File handling 

### **03-communication**
- **[NOTIFICATION_API.md](saleshub-docs/09-INTEGRATION-APIS/03-communication/NOTIFICATION_API.md)** - Push notifications 
- **[TRANSLATION.md](saleshub-docs/09-INTEGRATION-APIS/03-communication/TRANSLATION.md)** - Multi-language support

### **04-ticket-management**
- **[TICKET_MANAGEMENT_API.md](saleshub-docs/09-INTEGRATION-APIS/04-ticket-management/TICKET_MANAGEMENT_API.md)** - Support tickets

---

## 🧪 **EXAMPLES & SAMPLES**
*For testing and learning*

- **[Data_Bepensa.md](saleshub-docs/10-EXAMPLES-SAMPLES/Data_Bepensa.md)** - Bepensa tenant examples 
- **[Data.md](saleshub-docs/10-EXAMPLES-SAMPLES/Data.md)** - General examples 

---

## 📚 **REFERENCE**
*Comprehensive technical references*

- **[PLATFORM_API_DOCUMENTATION.md](saleshub-docs/11-REFERENCE/PLATFORM_API_DOCUMENTATION.md)** - Full platform API reference 

---



