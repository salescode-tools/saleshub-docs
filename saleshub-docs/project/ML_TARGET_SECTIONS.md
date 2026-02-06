# ML Recommendations & Target Management - INSERT CONTENT

## 🤖 8. ML Recommendations (AI-Powered Product Suggestions)

### Current Status: ✅ **PRODUCTION READY**

### Features Implemented

#### 8.1 Recommendation Types
- ✅ **REGULAR** - Repeat purchases (SKUs already sold to this outlet)
- ✅ **UPSELL** - Higher quantities of existing products
- ✅ **CROSS_SELL** - New SKUs based on similar outlets
- ✅ **NEARBY_SELLERS** - Products from geographically close outlets

#### 8.2 ML Engine Capabilities
- ✅ **Historical Analysis** - Sales pattern recognition
- ✅ **Confidence Scoring** - ML confidence levels (0-100%)
- ✅ **Quantity Forecasting** - Linear regression on sales trends
- ✅ **Entity-Based** - Per (loginId + outletCode) combination
- ✅ **Exclusion Analysis** - Purchase consistency tracking
- ✅ **Geo-location Based** - Nearby seller recommendations

#### 8.3 Advanced Features
- ✅ **Multi-Factor Scoring** - Net amount, quantity, frequency, consistency
- ✅ **Time Series Analysis** - Trend-based quantity prediction
- ✅ **Median-Based Normalization** - Robust against outliers
- ✅ **Consecutive Purchase Tracking** - Last 5 purchase days analysis
- ✅ **Radius-Based Similarity** - Configurable geo-radius (default: 10km)
- ✅ **Bulk Generation** - Process thousands of entities in batch

### Database Schema
```sql
-- Recommendations table
recommendation_item (
  id BIGSERIAL PRIMARY KEY,
  tenant_id TEXT,
  entity_type TEXT,  -- USER_OUTLET
  login_id TEXT,
  outlet_code TEXT,
  rec_type TEXT,  -- REGULAR, UPSELL, CROSS_SELL, NEARBY_SELLERS
  sku TEXT,
  forecast_qty NUMERIC(10,2),
  confidence_score NUMERIC(5,2),  -- 0-100
  metadata JSONB,  -- Contains ML details
  from_date DATE,
  to_date DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(tenant_id, entity_type, login_id, outlet_code, rec_type, sku, from_date)
)

-- Indexes for performance
CREATE INDEX idx_rec_outlet ON recommendation_item(tenant_id, outlet_code, from_date, to_date);
CREATE INDEX idx_rec_login ON recommendation_item(tenant_id, login_id, from_date, to_date);
CREATE INDEX idx_rec_type ON recommendation_item(rec_type);
```

### API Endpoints

| Method | Endpoint | Description | Status |
|--------|----------|-------------|--------|
| `GET` | `/recommendations?outlet={code}` | Get recommendations for outlet | ✅ |
| `GET` | `/recommendations?outlet={code}&types=REGULAR,UPSELL` | Filter by types | ✅ |
| `GET` | `/recommendations?outlet={code}&fromDate=2026-01-01` | Date range filter | ✅ |
| `POST` | `/recommendations/bulk` | Bulk save recommendations | ✅ |

### Recommendation Engine Logic

**1. REGULAR Recommendations:**
```
For each SKU already sold to (loginId + outlet):
 - Calculate: txCount, totalNetAmount, totalQty, lastPurchaseDate
 - Compute confidence score based on:
   * Net Amount (30% weight)
   * Quantity (20% weight)
   * Frequency/Tx Count (30% weight)
   * Consistency/Days (20% weight)
 - Forecast next quantity using linear regression on daily series
 - If slope > 0 → growing trend → forecast at x=n
 - If slope <= 0 → flat/declining → use last daily qty
 - Track exclusion stats: % of purchase days SKU was bought
 - Track consecutive purchase streak (last 5 days)
```

**2. UPSELL Recommendations:**
```
Same as REGULAR, but only include SKUs where:
 - excludedPercent < 30% (bought in 70%+ of purchase days)
 - consecutiveIncludedLast5 >= 3 (bought in 3+ of last 5 days)
→ Strong purchase pattern = upsell opportunity
```

**3. CROSS_SELL Recommendations:**
```
For SKUs NOT yet sold to this (loginId + outlet):
 - Use global SKU rankings (across all entities)
 - Filter out already owned SKUs
 - Compute confidence based on:
   * Global popularity (median metrics)
   * Entity purchase frequency
 - Suggest top-ranked new products
```

**4. NEARBY_SELLERS Recommendations:**
```
For each recommendation:
 - Find outlets within radius (default 10km) using Haversine
 - Check which nearby outlets also sell this SKU
 - Add metadata: nearby sellers list with distances
 - Boosts confidence if many nearby outlets sell it
```

### Confidence Scoring Formula

```java
// Weights: NetAmount(30%), Quantity(20%), Frequency(30%), Consistency(20%)
double computeConfidenceScore(SkuStats s, double medianNet, double medianQty, 
                               double medianTx, double medianDays) {
    double normNet  = Math.min(s.totalNetAmount / medianNet, 2.0);   // cap at 2x
    double normQty  = Math.min(s.totalQty / medianQty, 2.0);
    double normTx   = Math.min(s.txCount / medianTx, 2.0);
    double normDays = Math.min(s.dailyQty.size() / medianDays, 2.0);
    
    return (normNet * 0.30 + normQty * 0.20 + normTx * 0.30 + normDays * 0.20) * 50.0;
    // Result: 0-100 confidence score
}
```

### Usage Examples

**1. Get All Recommendations for Outlet:**
```bash
GET /recommendations?outlet=OUT9001
```

**Response:**
```json
[
  {
    "id": 123,
    "entityType": "USER_OUTLET",
    "loginId": "john.doe@example.com",
    "outletCode": "OUT9001",
    "recType": "REGULAR",
    "sku": "PROD-001",
    "forecastQty": 150.5,
    "confidenceScore": 85.2,
    "metadata": {
      "txCount": 12,
      "totalNetAmount": 15000,
      "lastPurchaseDate": "2025-12-25",
      "excludedPercent": 15.5,
      "consecutiveIncludedLast5": 4
    },
    "fromDate": "2026-01-01",
    "toDate": "2026-01-31"
  },
  {
    "entityType": "USER_OUTLET",
    "loginId": "john.doe@example.com",
    "outletCode": "OUT9001",
    "recType": "CROSS_SELL",
    "sku": "PROD-099",
    "forecastQty": 50.0,
    "confidenceScore": 65.8,
    "metadata": {
      "globalRank": 5,
      "nearbySellers": ["OUT9002", "OUT9005"]
    }
  }
]
```

**2. Generate Recommendations (Batch Job):**
```java
// Generate for all entities
RecType = enum { REGULAR, UPSELL, CROSS_SELL, NEARBY_SELLERS }

RecommendationService service = new RecommendationService();
List<SalesEvent> events = loadSalesHistory();  // Last 6 months
Map<String, OutletLocation> outletLocs = loadOutletLocations();

List<RecommendationItem> recs = service.generateRecommendations(
    events, 
    outletLocs, 
    ZoneId.of("Asia/Kolkata")
);

// Bulk save to database
recommendationDao.upsertBatch(recs);
```

### Mobile/Web Integration

**Display Recommendations in Order Screen:**
```javascript
// Fetch recommendations when opening outlet's order screen
async function loadRecommendations(outletCode) {
  const response = await api.get(`/recommendations?outlet=${outletCode}&types=REGULAR,UPSELL`);
  
  // Group by type
  const regular = response.filter(r => r.recType === 'REGULAR');
  const upsell = response.filter(r => r.recType === 'UPSELL');
  
  // Display with confidence indicators
  return {
    suggested: regular.filter(r => r.confidenceScore > 70),
    upsell: upsell.filter(r => r.confidenceScore > 60)
  };
}

// Add recommended item to order
function addRecommendedItem(rec) {
  addOrderLine({
    sku: rec.sku,
    recommendedQty: Math.round(rec.forecastQty),
    recommendationId: rec.id,
    recommendedValue: rec.forecastQty,
    recommendationType: rec.recType,
    mlConfidence: rec.confidenceScore
  });
}
```

### Testing Completed
- ✅ Regular recommendation generation
- ✅ Upsell filtering logic
- ✅ Cross-sell with global rankings
- ✅ Nearby sellers geo-calculation
- ✅ Confidence score computation
- ✅ Time series forecasting
- ✅ Exclusion stats tracking
- ✅ Bulk recommendation save

### Production Readiness
- ✅ Performance: Batch processing optimized
- ✅ Accuracy: Multi-factor ML scoring
- ✅ Scalability: Handles millions of sales events
- ✅ Flexibility: Configurable radius and thresholds
- ✅ Integration: Links to orders, products, outlets

---

## 🎯 9. Target Management (Sales Goals & KPIs)

### Current Status: ✅ **PRODUCTION READY**

### Features Implemented

#### 9.1 Target Types & Levels
- ✅ **User-Level Targets** - Individual salesrep goals
- ✅ **Outlet-Level Targets** - Per-outlet quotas
- ✅ **Distributor-Level Targets** - Distributor performance goals
- ✅ **Metric Types** - SALES_AMOUNT, SALES_UNITS, ORDER_COUNT, VISIT_COUNT

#### 9.2 Period Granularity
- ✅ **DAILY** - Day-by-day targets
- ✅ **WEEKLY** - Week-based goals
- ✅ **MONTHLY** - Monthly quotas
- ✅ **QUARTERLY** - Quarter-level targets
- ✅ **YEARLY** - Annual goals

#### 9.3 Target Selection Modes
- ✅ **STATIC** - Manually set targets
- ✅ **ML** - AI-generated targets
- ✅ **HYBRID** - ML with manual override

#### 9.4 Advanced Features
- ✅ **Bulk Operations** - Mass upsert, patch, delete
- ✅ **Complex Search** - Multi-field filtering
- ✅ **ML Integration** - Automated target generation
- ✅ **Status Management** - ACTIVE, INACTIVE, DRAFT
- ✅ **Tagging System** - Flexible categorization
- ✅ **Achievement Tracking** - Real-time progress monitoring

### Database Schema
```sql
-- Targets table
target (
  id BIGSERIAL PRIMARY KEY,
  tenant_id TEXT,
  
  -- Metric & Level
  metric TEXT,  -- SALES_AMOUNT, SALES_UNITS, ORDER_COUNT, VISIT_COUNT
  level TEXT,   -- USER, OUTLET, DISTRIBUTOR
  
  -- Entity identification
  username TEXT,  -- For USER level
  outlet_code TEXT,  -- For OUTLET level
  distributor TEXT,  -- For DISTRIBUTOR level
  
  -- Time period
  period_kind TEXT,  -- DAILY, WEEKLY, MONTHLY, QUARTERLY, YEARLY
  period_date DATE,  -- Start date of period
  
  -- Target values
  static_value NUMERIC(12,2),  -- Manually set target
  ml_value NUMERIC(12,2),      -- ML-predicted target
  ml_confidence NUMERIC(5,2),  -- ML confidence (0-100)
  selection TEXT DEFAULT 'STATIC',  -- STATIC, ML, HYBRID
  
  -- Metadata
  code TEXT,
  name TEXT,
  status TEXT DEFAULT 'ACTIVE',  -- ACTIVE, INACTIVE, DRAFT
  tags TEXT[],
  extended_attr JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  
  -- Composite unique constraint
  UNIQUE(tenant_id, metric, level, username, outlet_code, distributor, period_kind, period_date)
)

-- Indexes for performance
CREATE INDEX idx_target_search ON target(tenant_id, level, metric, period_kind, period_date);
CREATE INDEX idx_target_user ON target(tenant_id, username, period_date) WHERE level = 'USER';
CREATE INDEX idx_target_outlet ON target(tenant_id, outlet_code, period_date) WHERE level = 'OUTLET';
CREATE INDEX idx_target_status ON target(status);
```

### API Endpoints

| Method | Endpoint | Description | Status |
|--------|----------|-------------|--------|
| `POST` | `/targets` | Upsert single target | ✅ |
| `PATCH` | `/targets/{id}` | Partial update target | ✅ |
| `DELETE` | `/targets/{id}` | Delete target by ID | ✅ |
| `POST` | `/targets/search` | Complex search with filters | ✅ |
| `POST` | `/targets/bulk/upsert` | Bulk upsert targets | ✅ |
| `POST` | `/targets/bulk/patch` | Bulk patch targets | ✅ |
| `POST` | `/targets/bulk/delete` | Bulk delete targets | ✅ |

### Usage Examples

**1. Set Daily Sales Target for User:**
```bash
POST /targets
{
  "metric": "SALES_AMOUNT",
  "level": "USER",
  "username": "john.doe@example.com",
  "periodKind": "DAILY",
  "periodDate": "2026-01-02",
  "staticValue": 50000,
  "selection": "STATIC",
  "status": "ACTIVE",
  "code": "JAN_D2",
  "name": "Jan 2 Daily Target",
  "tags": ["JAN", "DAILY"]
}
```

**Response:**
```json
{
  "id": 12345
}
```

**2. Set Monthly Outlet Target with ML:**
```bash
POST /targets
{
  "metric": "SALES_UNITS",
  "level": "OUTLET",
  "outletCode": "OUT9001",
  "periodKind": "MONTHLY",
  "periodDate": "2026-01-01",
  "mlValue": 15000,
  "mlConfidence": 85.5,
  "selection": "ML",
  "status": "ACTIVE"
}
```

**3. Search Targets (Complex Filter):**
```bash
POST /targets/search
{
  "level": "USER",
  "metric": "SALES_AMOUNT",
  "periodKind": "DAILY",
  "fromDate": "2026-01-01",
  "toDate": "2026-01-31",
  "status": "ACTIVE",
  "page": 1,
  "pageSize": 100
}
```

**Response:**
```json
[
  {
    "id": 123,
    "metric": "SALES_AMOUNT",
    "level": "USER",
    "username": "john.doe@example.com",
    "periodKind": "DAILY",
    "periodDate": "2026-01-02",
    "staticValue": 50000,
    "selection": "STATIC",
    "status": "ACTIVE",
    "code": "JAN_D2",
    "tags": ["JAN", "DAILY"]
  }
]
```

**4. Bulk Upsert Targets:**
```bash
POST /targets/bulk/upsert
{
  "items": [
    {
      "metric": "SALES_UNITS",
      "level": "OUTLET",
      "outletCode": "OUT001",
      "periodKind": "MONTHLY",
      "periodDate": "2026-01-01",
      "mlValue": 15000,
      "mlConfidence": 90,
      "selection": "ML"
    },
    {
      "metric": "SALES_AMOUNT",
      "level": "USER",
      "username": "jane.smith@example.com",
      "periodKind": "DAILY",
      "periodDate": "2026-01-10",
      "staticValue": 8000,
      "selection": "STATIC"
    }
  ]
}
```

**Response:**
```json
{
  "count": 2
}
```

**5. Bulk Patch Targets (Change Selection Mode):**
```bash
POST /targets/bulk/patch
{
  "where": [
    {
      "metric": "SALES_UNITS",
      "level": "OUTLET",
      "outletCode": "OUT001",
      "periodKind": "MONTHLY",
      "periodDate": "2026-01-01"
    }
  ],
  "patch": {
    "selection": "ML",
    "status": "ACTIVE"
  }
}
```

**6. Bulk Delete Targets:**
```bash
POST /targets/bulk/delete
{
  "metric": "SALES_AMOUNT",
  "level": "USER",
  "fromDate": "2025-12-01",
  "toDate": "2025-12-31",
  "periodKind": "DAILY"
}
```

### Target Achievement Tracking

**Calculate Achievement:**
```sql
-- Daily user achievement
SELECT 
  t.username,
  t.period_date,
  t.static_value AS target,
  COALESCE(SUM(oh.net_amount), 0) AS actual,
  ROUND(
    (COALESCE(SUM(oh.net_amount), 0) / NULLIF(t.static_value, 0)) * 100, 
    2
  ) AS achievement_pct
FROM target t
LEFT JOIN order_header oh ON oh.salesrep = t.username
  AND DATE(oh.ordered_at AT TIME ZONE 'Asia/Kolkata') = t.period_date
WHERE t.level = 'USER'
  AND t.metric = 'SALES_AMOUNT'
  AND t.period_kind = 'DAILY'
  AND t.period_date = CURRENT_DATE
GROUP BY t.username, t.period_date, t.static_value;
```

### ML Target Generation

**Generate Monthly Targets Using Historical Data:**
```java
// Use Holt-Winters or simple linear regression
TargetGenerator generator = new TargetGenerator();
TargetGeneratorLite lite = new TargetGeneratorLite();

// Generate for all users for next month
List<Target> mlTargets = lite.generateForAllUsers(
    tenantId,
    LocalDate.of(2026, 2, 1),  // February 2026
    "MONTHLY",
    "SALES_AMOUNT"
);

// Bulk save
targetDao.bulkUpsert(mlTargets);
```

### Dashboard Integration

**Display Target vs Actual:**
```javascript
async function loadTargetVsActual(username, date) {
  const targets = await api.post('/targets/search', {
    level: 'USER',
    username: username,
    periodDate: date,
    periodKind: 'DAILY'
  });
  
  const kpis = await api.get(`/kpi/salesrep/daily?username=${username}&date=${date}`);
  
  return targets.map(target => ({
    metric: target.metric,
    target: target.selection === 'ML' ? target.mlValue : target.staticValue,
    actual: kpis.metrics[target.metric.toLowerCase()],
    achievement: (actual / target) * 100,
    status: achievement >= 100 ? 'MET' : 'PENDING'
  }));
}
```

### Testing Completed
- ✅ Single target CRUD operations
- ✅ Bulk upsert (100+ targets)
- ✅ Bulk patch with complex filters
- ✅ Bulk delete operations
- ✅ Complex search queries
- ✅ ML target generation
- ✅ Achievement calculation
- ✅ Multi-level targets (USER, OUTLET, DISTRIBUTOR)

### Production Readiness
- ✅ Performance: Efficient bulk operations
- ✅ Flexibility: Multi-level, multi-metric support
- ✅ ML Integration: Automated target generation
- ✅ Scalability: Handles 100K+ targets
- ✅ Tracking: Real-time achievement monitoring
- ✅ Documentation: Complete API reference

---
