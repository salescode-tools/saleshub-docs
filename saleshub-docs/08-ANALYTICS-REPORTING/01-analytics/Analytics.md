SELECT trending_products_json(
(now() - interval '5 months')::date,
(now() + interval '1 months')::date,
'+5:30',
50
);

SELECT trending_products_daily_json(
(now() - interval '7 days')::date,
(now() + interval '1 days')::date,
'+5:30',
50
);


# Monthly (last 6 months, -06:00)
curl -sS -H "X-Tenant-Id: bepensa" \
"http://localhost:8080/api/trending/monthly?from=2025-06-01&to=2025-12-01&tz=-06:00&limit=50"

# Daily (last 14 days, -06:00)
curl -sS -H "X-Tenant-Id: bepensa" \
"http://localhost:8080/api/trending/daily?from=2025-10-24&to=2025-11-08&tz=-06:00&limit=25"

# Range (last 30 days, -06:00)
curl -sS -H "X-Tenant-Id: bepensa" \
"http://localhost:8080/api/trending/range?from=2025-10-09&to=2025-11-08&tz=-06:00&limit=50"


# Today
GET /analytics/products/trending/quick/today

# Last 7 days
GET /analytics/products/trending/quick/last7

# Last Month
GET /analytics/products/trending/quick/lastMonth

# With different TZ
GET /analytics/products/trending/quick/last7?tz=Asia/Dubai

# Set max products
GET /analytics/products/trending/quick/today?limit=100

curl -sS -H "X-Tenant-Id: bepensa" \
"Authorization: Bearer $TOKEN" \
"http://localhost:8080//analytics/products/trending/quick/today"
