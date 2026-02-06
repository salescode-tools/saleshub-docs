Understood — you want ONE SINGLE COMPLETE CLEAN DDL that includes:

✅ task & points model
✅ frequency (daily/monthly)
✅ applicability (all / outlet / salesrep / distributor)
✅ thresholds & SKU filters
✅ point kinds (order value, order count, upsell, cross-sell, visits, must-sell, focus SKU, etc.)
✅ task_activity with stored eligible & points_earned
✅ auto-compute trigger
✅ month normalization trigger
✅ recompute utilities
✅ clean views

⚠️ You likely want this in one file so it can run once on a DB.

I will now produce a single clean DDL (no comments, no partial patches, no chatter — only final SQL).

Before I generate it, answer 2 quick clarifications so the final DDL is perfect:

❓ Clarification Questions (reply with numbers)

Tenant model:
Do you need tenant_id everywhere?

A → Yes, I want multi-tenant with RLS

B → No, single-tenant schema

Reference Tables:
Should outlet_code, salesrep_code, distributor_code reference master tables?

1 → Keep them as TEXT (loose coupling)

2 → Add foreign keys to outlet/salesrep/distributor master tables
(we will create stub master tables if needed)

Trigger behavior:
Points compute on: INSERT + UPDATE of data fields?

X → Yes, compute on status, units, value, SKU, etc.

Y → Only compute on DONE transition (more strict)

Scaling preference:

S → Keep simple indexes only (for MVP)

P → Add performance indexes (period_key, assignee, model kind, etc.)


✅ 1. Create / Update Points Model
➤ Create Order Value model
curl -X PUT http://localhost:8080/api/points-models \
-H "Content-Type: application/json" \
-d '{
"code": "ORD_VAL_1PCT_MIN20K",
"kind": "ORDER_VALUE",
"description": "1% of order value; min 20k",
"percentFactor": 0.01,
"minValueThreshold": 20000
}'

➤ Create Visit Count model
curl -X PUT http://localhost:8080/api/points-models \
-H "Content-Type: application/json" \
-d '{
"code": "VISIT_CNT_1PT_MIN20",
"kind": "VISIT_COUNT",
"description": "1 point per visit; min 20",
"perUnitPoints": 1,
"minUnitsThreshold": 20
}'

✅ 2. Add SKU Bonus to Points Model
curl -X PUT http://localhost:8080/api/points-models/1/sku-bonus \
-H "Content-Type: application/json" \
-d '{
"sku": "MILK500",
"perUnitBonus": 0.05
}'

✅ 3. Create Tasks Associated to Point Model
➤ Daily Order Value Task
curl -X PUT http://localhost:8080/api/tasks \
-H "Content-Type: application/json" \
-d '{
"code": "ORDER_VALUE_DAILY_T",
"name": "Daily Order Value",
"description": "Get 1% if >= ₹20k",
"frequency": "DAILY",
"pointsModelId": 1,
"appliesTo": "ALL"
}'

➤ Monthly Visits Task (Distributor)
curl -X PUT http://localhost:8080/api/tasks \
-H "Content-Type: application/json" \
-d '{
"code": "VISITS_D001_MIN20",
"name": "Monthly Visits D001",
"description": "20 visits minimum",
"frequency": "MONTHLY",
"pointsModelId": 2,
"appliesTo": "DISTRIBUTOR",
"distributorCode": "D001"
}'

✅ 4. Create Task Activity (Mark Done)
➤ Daily Order Value — Not Eligible (18k)
curl -X PUT http://localhost:8080/api/task-activities \
-H "Content-Type: application/json" \
-d '{
"taskId": 1,
"assignee": "rep.arun",
"periodKey": "2025-11-07",
"status": "DONE",
"valueDone": 18000,
"note": "Below threshold"
}'

➤ Daily Order Value — Eligible (25k)
curl -X PUT http://localhost:8080/api/task-activities \
-H "Content-Type: application/json" \
-d '{
"taskId": 1,
"assignee": "rep.arun",
"periodKey": "2025-11-08",
"status": "DONE",
"valueDone": 25000,
"note": "Eligible"
}'

✅ 5. Mark Existing Activity Done
curl -X POST http://localhost:8080/api/task-activities/10/done

✅ 6. List Tasks
curl http://localhost:8080/api/tasks?hierarchical=true

✅ 7. List Points Models
curl http://localhost:8080/api/points-models

✅ 8. Recompute Points

When business rules or task definitions change

➤ Recompute for One Task
curl -X POST http://localhost:8080/api/admin/recompute/task/ORDER_VALUE_DAILY_T

➤ Recompute All
curl -X POST http://localhost:8080/api/admin/recompute/all


BASE=http://localhost:8080
✅ 1. Total Points for a User
bash
Copy code
curl -X GET "$BASE/api/points/user/rep.arun"
Example Response

json
Copy code
{
"assignee": "rep.arun",
"total_points": 35.00,
"completions": 5
}
✅ 2. Task-wise Points Breakdown
bash
Copy code
curl -X GET "$BASE/api/points/user/rep.arun/by-task"
Example Response

json
Copy code
[
{
"taskCode": "ORDER_VALUE_DAILY_T",
"taskName": "Daily Order Value",
"points": 25.00,
"completions": 2
},
{
"taskCode": "VISITS_D001_MIN20",
"taskName": "Monthly Visits D001",
"points": 10.00,
"completions": 1
}
]
✅ 3. Daily Points Timeline
bash
Copy code
curl -X GET "$BASE/api/points/user/rep.arun/daily?limit=30"
With date filter

bash
Copy code
curl -X GET "$BASE/api/points/user/rep.arun/daily?from=2025-11-01&to=2025-11-30"
Sample Response

json
Copy code
[
{ "period": "2025-11-08", "points": 15 },
{ "period": "2025-11-07", "points": 20 }
]
✅ 4. Monthly Points Timeline
bash
Copy code
curl -X GET "$BASE/api/points/user/rep.arun/monthly"
With custom range

bash
Copy code
curl -X GET "$BASE/api/points/user/rep.arun/monthly?from=2025-01-01&to=2025-12-31"
Example Response

json
Copy code
[
{ "period": "2025-11-01", "points": 35 },
{ "period": "2025-10-01", "points": 10 }
]
✅ 5. Current Month Points
bash
Copy code
curl -X GET "$BASE/api/points/user/rep.arun/current-month"
Example Response

json
Copy code
{
"assignee": "rep.arun",
"month": "2025-11-01",
"points": 35
}