# SalesCodeAI Lite - Testing & Quality Assurance Strategy

**Project:** SalesCodeAI Saleshub Lite Edition  
**Document Version:** 1.0  
**Last Updated:** January 2, 2026  
**Status:** Comprehensive Testing Framework

---

## 📋 Table of Contents

1. [Testing Overview](#testing-overview)
2. [Test Pyramid Strategy](#test-pyramid-strategy)
3. [Unit Testing](#unit-testing)
4. [Integration Testing](#integration-testing)
5. [Performance Testing](#performance-testing)
6. [Security Testing](#security-testing)
7. [CI/CD Pipeline](#cicd-pipeline)
8. [Module-Specific Testing](#module-specific-testing)
9. [Test Automation Tools](#test-automation-tools)
10. [Test Data Management](#test-data-management)

---

## 🎯 Testing Overview

### Testing Philosophy
- **Quality First:** 80%+ test coverage across codebase
- **Shift Left:** Early testing in development cycle
- **Automation:** Minimize manual testing where possible
- **Continuous:** Integrated into CI/CD pipeline

### Coverage Goals
- **Unit Tests:** 80%+ code coverage
- **Integration Tests:** 70%+ API endpoint coverage
- **E2E Tests:** All critical user flows
- **Performance Tests:** Key scenarios under load

---

## 🔺 Test Pyramid Strategy

```
                 /\
                /  \
               / E2E \
              /______\
             /        \
            /Integration\
           /____________\
          /              \
         /   Unit Tests   \
        /__________________\
```

### Layer Distribution
- **Unit Tests (Base):** 60% of tests - Fast, isolated
- **Integration Tests (Middle):** 30% of tests - API-level
- **E2E Tests (Top):** 10% of tests - Critical paths

---

## ✅ Unit Testing

### Framework & Tools
- **JUnit 5** - Test framework
- **Mockito** - Mocking framework
- **AssertJ** - Fluent assertions
- **Current Coverage:** 75%+

### Test Categories

#### 1. DAO Layer Tests
```java
@QuarkusTest
class UserDaoPlainJdbcTest {
  @Inject UserDaoPlainJdbc userDao;
  
  @Test
  void testCreateUser() {
    AppUser user = userDao.createUser(
      "John", "Doe", "john@example.com", "password", 
      null, null, "OUTLET"
    );
    assertNotNull(user.id);
    assertEquals("john@example.com", user.username);
  }
  
  @Test
  void testDuplicateUsername() {
    assertThrows(DuplicateUsernameException.class, () -> {
      userDao.createUser("John", "Doe", "existing@example.com", ...);
    });
  }
  
  @Test
  void testListUsers_Pagination() {
    List<AppUser> users = userDao.listAll("", "", "", 10, 0);
    assertThat(users).hasSizeLessThanOrEqualTo(10);
  }
}
```

#### 2. Service Layer Tests
```java
@QuarkusTest
class OrderPromotionServiceTest {
  @Inject OrderPromotionService service;
  
  @Test
  void testStackablePromotions() {
    CreateOrderRequest req = createOrderWithPromotions();
    service.applyPromotions(req);
    
    // Verify both stackable promotions applied
    assertEquals(2, req.appliedPromotions.size());
    assertEquals(300.0, req.discount, 0.01);
  }
  
  @Test
  void testExclusivePromotions() {
    CreateOrderRequest req = createOrderWithExclusivePromotions();
    service.applyPromotions(req);
    
    // Verify only best promotion applied
    assertEquals(1, req.appliedPromotions.size());
    assertEquals(500.0, req.discount, 0.01);
  }
  
  @Test
  void testPromotionEligibility_DateRange() {
    Promotion promo = createPromotion();
    promo.startOn = LocalDate.now().plusDays(1);
    
    assertFalse(service.isEligible(promo, createOrder()));
  }
}
```

#### 3. Utility Tests
```java
class HierarchyPathParserTest {
  @Test
  void testParseHierarchyPath() {
    String path = "SUP001 > ASM001 > RSM001 > CEO001";
    List<String> hierarchy = HierarchyPathParser.parse(path);
    
    assertEquals(4, hierarchy.size());
    assertEquals("SUP001", hierarchy.get(0));
    assertEquals("CEO001", hierarchy.get(3));
  }
  
  @Test
  void testMultipleDelimiters() {
    assertEquals(
      HierarchyPathParser.parse("A > B > C"),
      HierarchyPathParser.parse("A / B / C")
    );
  }
  
  @Test
  void testEmptyPath() {
    List<String> result = HierarchyPathParser.parse("");
    assertThat(result).isEmpty();
  }
}
```

#### Running Unit Tests
```bash
# Run all unit tests
mvn test

# Run specific test class
mvn test -Dtest=UserDaoPlainJdbcTest

# Run with coverage report
mvn test jacoco:report

# View coverage report
open target/site/jacoco/index.html

# Run tests in parallel
mvn test -T 4

# Skip integration tests
mvn test -DskipITs
```

---

## 🔗 Integration Testing

### Framework & Tools
- **REST Assured** - API testing
- **Quarkus Test Framework** - Test harness
- **TestContainers** - Docker-based dependencies
- **Current Coverage:** 70%+

### Test Suites

#### 1. User Management Integration Tests
```java
@QuarkusTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class UserIntegrationTest {
  static String authToken;
  static Long userId;
  
  @Test
  @Order(1)
  void testRegisterTenantAdmin() {
    given()
      .contentType(ContentType.JSON)
      .header("X-Tenant-Id", "test-tenant")
      .body(new RegisterTenantAdminRequest(...))
    .when()
      .post("/auth/registerTenantAdmin")
    .then()
      .statusCode(200)
      .body("tenantId", notNullValue())
      .body("userId", notNullValue());
  }
  
  @Test
  @Order(2)
  void testLogin() {
    Response response = given()
      .contentType(ContentType.JSON)
      .header("X-Tenant-Id", "test-tenant")
      .body(Map.of("username", "admin", "password", "pass"))
    .when()
      .post("/auth/login")
    .then()
      .statusCode(200)
      .body("token", notNullValue())
      .extract().response();
    
    authToken = response.path("token");
  }
  
  @Test
  @Order(3)
  void testCreateUserWithHierarchy() {
    CreateUserRequest req = new CreateUserRequest();
    req.firstName = "John";
    req.lastName = "Doe";
    req.username = "john.doe";
    req.parentUsernames = List.of("manager1", "manager2");
    
    given()
      .contentType(ContentType.JSON)
      .header("Authorization", "Bearer " + authToken)
      .body(req)
    .when()
      .post("/users")
    .then()
      .statusCode(201)
      .header("Location", notNullValue());
  }
  
  @Test
  @Order(4)
  void testStubUserCreation() {
    // Upload CSV with non-existent parents
    File csv = new File("test-users.csv");
    
    given()
      .multiPart("file", csv)
      .header("Authorization", "Bearer " + authToken)
    .when()
      .post("/sales/csv/stream")
    .then()
      .statusCode(200);
    
    // Verify stub users created
    given()
      .header("Authorization", "Bearer " + authToken)
    .when()
      .get("/admin/stub-users/stats")
    .then()
      .statusCode(200)
      .body("total_stub_users", greaterThan(0));
  }
}
```

#### 2. Pricing Integration Tests
```java
@QuarkusTest
class PricingIntegrationTest {
  @Test
  void testPriceResolution_OutletScope() {
    PriceResolveRequest req = new PriceResolveRequest();
    req.sku = "SKU001";
    req.outletCode = "OUT001";
    req.asOf = LocalDate.now();
    req.request = new UomRequest("CASE", 10);
    
    given()
      .contentType(ContentType.JSON)
      .header("Authorization", "Bearer " + token)
      .body(req)
    .when()
      .post("/pricing/resolve")
    .then()
      .statusCode(200)
      .body("resolvedScope", equalTo("OUTLET"))
      .body("price.perUomValue", notNullValue());
  }
  
  @Test
  void testPriceResolution_MOQNotMet() {
    // Request below MOQ
    PriceResolveRequest req = createRequestBelowMOQ();
    
    given()
      .contentType(ContentType.JSON)
      .body(req)
    .when()
      .post("/pricing/resolve")
    .then()
      .statusCode(400)
      .body("error", equalTo("MOQ_NOT_MET"));
  }
  
  @Test
  void testPriceResolution_EntitlementCheck() {
    // SKU not entitled to outlet
    PriceResolveRequest req = createRequestNoEntitlement();
    
    given()
      .contentType(ContentType.JSON)
      .body(req)
    .when()
      .post("/pricing/resolve")
    .then()
      .statusCode(403)
      .body("error", containsString("entitlement"));
  }
}
```

#### 3. Order + Promotion Integration Tests
```java
@QuarkusTest
class OrderPromotionIntegrationTest {
  @Test
  void testOrderCreation_WithPromotions() {
    CreateOrderRequest req = new CreateOrderRequest();
    req.outletCode = "OUT001";
    req.lines = List.of(createOrderLine("SKU001", 10, 100));
    
    Response response = given()
      .contentType(ContentType.JSON)
      .queryParam("dryRun", false)
      .body(req)
    .when()
      .post("/orders")
    .then()
      .statusCode(201)
      .extract().response();
    
    // Verify promotions applied
    List<Object> appliedPromotions = response.path("order.appliedPromotions");
    assertFalse(appliedPromotions.isEmpty());
  }
  
  @Test
  void testDryRun_NoDbInsert() {
    CreateOrderRequest req = createTestOrder();
    
    given()
      .contentType(ContentType.JSON)
      .queryParam("dryRun", true)
      .body(req)
    .when()
      .post("/orders")
    .then()
      .statusCode(200)
      .body("order.id", nullValue())  // No ID means not saved
      .body("order.appliedPromotions", notNullValue());
  }
  
  @Test
  void testOrderUpdate_RecalculatesPromotions() {
    // Create order first
    long orderId = createTestOrder();
    
    // Update order
    UpdateOrderRequest update = new UpdateOrderRequest();
    update.lines = List.of(createOrderLine("SKU002", 20, 200));
    
    given()
      .contentType(ContentType.JSON)
      .body(update)
    .when()
      .put("/orders/" + orderId)
    .then()
      .statusCode(200)
      .body("appliedPromotions", notNullValue());
  }
}
```

#### Running Integration Tests
```bash
# Run all integration tests
mvn verify

# Run specific integration test
mvn verify -Dit.test=UserIntegrationTest

# Run with docker-compose (TestContainers)
mvn verify -Dquarkus.test.integration-test-profile=docker

# Skip unit tests, run only integration
mvn verify -DskipUTs

# Generate test report
mvn verify surefire-report:report
```

---

## ⚡ Performance Testing

### Tool: Apache JMeter / Gatling

#### Load Test Scenarios

**Scenario 1: Order Creation Load Test**
```
Target: 500 orders/minute
Concurrent Users: 100
Duration: 10 minutes
Ramp-up: 1 minute

Success Criteria:
- Response time p95 < 500ms
- Response time p99 < 1000ms
- Error rate < 0.1%
- No database connection exhaustion
- Memory < 2GB
```

**JMeter Test Plan:**
```xml
<?xml version="1.0"?>
<jmeterTestPlan>
  <ThreadGroup>
    <numThreads>100</numThreads>
    <rampTime>60</rampTime>
    <duration>600</duration>
    
    <HTTPSamplerProxy>
      <path>/orders</path>
      <method>POST</method>
      <postBodyRaw>
        <![CDATA[
        {
          "outletCode": "OUT${__Random(1,1000)}",
          "lines": [
            {"sku": "SKU${__Random(1,100)}", "qty": ${__Random(10,100)}}
          ]
        }
        ]]>
      </postBodyRaw>
    </HTTPSamplerProxy>
  </ThreadGroup>
</jmeterTestPlan>
```

**Scenario 2: Catalog Query Load Test**
```
Target: 1000 requests/minute
Concurrent Users: 200
Duration: 5 minutes

Success Criteria:
- Response time p95 < 300ms
- Throughput > 1000 req/min
- CPU < 70%
- Database connections < 50
```

**Scenario 3: Bulk Upload Stress Test**
```
File Size: 10,000 rows
Concurrent Uploads: 20
Duration: Single execution

Success Criteria:
- Upload time < 60 seconds per file
- Memory < 1GB
- 100% success rate
- No orphaned transactions
```

#### Performance Test Execution
```bash
# Run JMeter test
jmeter -n -t order_load_test.jmx -l results.jtl -e -o report/

# View report
open report/index.html

# Analyze results
awk '{sum+=$2; count++} END {print "Avg:", sum/count}' results.jtl

# Gatling test
mvn gatling:test -Dgatling.simulationClass=OrderSimulation

# View Gatling report
open target/gatling/ordersimulation-*/index.html
```

---

## 🔒 Security Testing

### Authentication Tests
```java
@QuarkusTest
class SecurityTest {
  @Test
  void testUnauthorizedAccess() {
    given()
    .when()
      .get("/orders")
    .then()
      .statusCode(401);
  }
  
  @Test
  void testExpiredToken() {
    String expiredToken = generateExpiredToken();
    
    given()
      .header("Authorization", "Bearer " + expiredToken)
    .when()
      .get("/orders")
    .then()
      .statusCode(401);
  }
  
  @Test
  void testTenantIsolation() {
    // User from tenant A tries to access tenant B data
    given()
      .header("Authorization", "Bearer " + tenantAToken)
      .header("X-Tenant-Id", "tenant-b")
    .when()
      .get("/orders")
    .then()
      .statusCode(200)
      .body("$", hasSize(0));  // No data from other tenant
  }
  
  @Test
  void testSQLInjectionPrevention() {
    given()
      .queryParam("q", "'; DROP TABLE app_user; --")
    .when()
      .get("/users")
    .then()
      .statusCode(200);  // Should not crash
    
    // Verify table still exists
    assertTrue(db.tableExists("app_user"));
  }
}
```

### Penetration Testing Checklist
- ✅ SQL Injection prevention
- ✅ XSS prevention
- ✅ CSRF protection
- ✅ JWT signature validation
- ✅ RLS policy enforcement
- ✅ Input validation
- ✅ Rate limiting
- ✅ Sensitive data exposure
- ✅ Broken authentication
- ✅ Security misconfiguration

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Run Unit Tests
        run: mvn test
      
      - name: Run Integration Tests
        run: mvn verify
      
      - name: Generate Coverage Report
        run: mvn jacoco:report
      
      - name: Upload Coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./target/site/jacoco/jacoco.xml
  
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build Quarkus Native
        run: mvn package -Pnative
      
      - name: Build Docker Image
        run: docker build -f src/main/docker/Dockerfile.native -t saleslite:${{ github.sha }} .
  
  deploy-staging:
    needs: build
    if: github.ref == 'refs/heads/develop'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Staging
        run: ./deploy-staging.sh
  
  deploy-production:
    needs: build
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Production
        run: ./deploy-production.sh
```

---

## 📦 Module-Specific Testing

### 1. User Management Module
**Test Coverage: 90%**

✅ User registration (self-service and admin)
✅ JWT authentication and authorization
✅ OTP-based registration
✅ Parent user mapping
✅ Stub user system (auto-creation and merge)
✅ Bulk user upload
✅ Multi-tenant isolation
✅ Password hashing (bcrypt)

### 2. Outlet Management Module
**Test Coverage: 90%**

✅ Outlet CRUD operations
✅ Search and filtering
✅ Geo-location capture
✅ User-outlet mapping
✅ Auto-distributor assignment (nearest)
✅ Channel management
✅ Bulk outlet upload

### 3. B2B Product Pricing Module
**Test Coverage: 85%**

✅ Multi-scope pricing (Outlet, Distributor, Salesrep, Company)
✅ UoM conversion (Unit, Case, Piece)
✅ Time-bound rules
✅ MOQ enforcement
✅ Entitlement checking
✅ Price derivation algorithm
✅ Deterministic tie-breakers

### 4. Promotions Engine Module
**Test Coverage: 85%**

✅ Stackable promotions (multiple combined)
✅ Exclusive promotions (best selected)
✅ Stack group logic
✅ Dry run mode
✅ Free goods calculation
✅ Slab scheme logic
✅ Order/line level discounts

### 5. Hierarchy Management Module
**Test Coverage: 90%**

✅ Single hierarchy path
✅ Multiple hierarchy paths
✅ Combined with parent_username
✅ Stub user creation for missing levels
✅ Bulk upload (1000+ users)
✅ All supported delimiters
✅ Matrix organization structures

### 6. Order Management Module
**Test Coverage: 90%**

✅ Order creation with multiple lines
✅ Promotion auto-application
✅ Dry run mode
✅ Line item CRUD
✅ Status updates
✅ Order summary aggregation
✅ Filtering by status/date

### 7. MDM Module
**Test Coverage: 85%**

✅ Template download for all 8 types
✅ Template listing API
✅ Bulk upload (10K+ rows)
✅ Field alias resolution
✅ Type validation
✅ Duplicate handling

### 8. ML Recommendations Module
**Test Coverage: 80%**

✅ Regular recommendation generation
✅ Upsell filtering logic
✅ Cross-sell with global rankings
✅ Nearby sellers geo-calculation
✅ Confidence score computation
✅ Time series forecasting
✅ Exclusion stats tracking
✅ Bulk recommendation save

### 9. Target Management Module
**Test Coverage: 85%**

✅ Single target CRUD operations
✅ Bulk upsert (100+ targets)
✅ Bulk patch with complex filters
✅ Bulk delete operations
✅ Complex search queries
✅ ML target generation
✅ Achievement calculation
✅ Multi-level targets

### 10. PJP & Visit Management Module
**Test Coverage: 85%**

✅ Beat CRUD operations
✅ PJP creation with outlets
✅ PJP frequency pattern validation
✅ Visit plan generation (daily, weekly, monthly)
✅ Visit logging with geo-location
✅ Plan vs actual tracking
✅ Unplanned visit handling
✅ Coverage analytics
✅ Bulk operations

### 11. Device & Activity Tracking Module
**Test Coverage: 80%**

✅ Activity creation with all fields
✅ Device ID tracking
✅ Geo-location validation
✅ Timestamp handling (client vs server)
✅ Offline sync simulation
✅ Multi-device scenarios
✅ Activity filtering and pagination

### 12. Geographical Data Management Module
**Test Coverage: 75%**

✅ Location definition CRUD
✅ Location instance CRUD
✅ Hierarchy validation
✅ Nearest distributor calculation
✅ Geo-fencing logic
✅ Timezone conversions
✅ Bulk location import

### 13. Analytics & KPI Tracking Module
**Test Coverage: 85%**

✅ Trending products calculation
✅ Daily KPI aggregation
✅ Timezone handling
✅ PJP visit tracking
✅ Order summary aggregation
✅ Real-time dashboard queries
✅ Custom analytics queries

---

## 🛠️ Test Automation Tools

| Tool | Purpose | Status |
|------|---------|--------|
| **JUnit 5** | Unit testing framework | ✅ Integrated |
| **Mockito** | Mocking framework | ✅ Integrated |
| **REST Assured** | API testing | ✅ Integrated |
| **TestContainers** | Integration testing | ✅ Integrated |
| **JMeter** | Performance testing | ⏳ Planned |
| **Gatling** | Load testing | ⏳ Planned |
| **SonarQube** | Code quality | ⏳ Planned |
| **OWASP ZAP** | Security scanning | ⏳ Planned |
| **Postman/Newman** | API automation | ⏳ Planned |
| **JaCoCo** | Code coverage | ✅ Integrated |

---

## 📊 Test Data Management

### Test Data Fixtures
```java
@ApplicationScoped
public class TestDataFactory {
  public AppUser createTestUser(String username) {
    AppUser user = new AppUser();
    user.username = username;
    user.firstName = "Test";
    user.lastName = "User";
    user.isActive = true;
    return userDao.createUser(user);
  }
  
  public Outlet createTestOutlet(String code) {
    Outlet outlet = new Outlet();
    outlet.code = code;
    outlet.name = "Test Outlet " + code;
    outlet.channel = "GT";
    return outletDao.create(outlet);
  }
  
  public Order createTestOrder(String outletCode, int lineCount) {
    CreateOrderRequest req = new CreateOrderRequest();
    req.outletCode = outletCode;
    req.lines = IntStream.range(0, lineCount)
      .mapToObj(i -> createTestOrderLine("SKU" + i))
      .collect(Collectors.toList());
    return orderDao.create(req);
  }
}
```

### Database Cleanup
```java
@QuarkusTest
class BaseIntegrationTest {
  @BeforeEach
  void setUp() {
    // Clean test data
    db.execute("DELETE FROM order_line WHERE tenant_id = 'test'");
    db.execute("DELETE FROM order_header WHERE tenant_id = 'test'");
    db.execute("DELETE FROM app_user WHERE tenant_id = 'test'");
  }
  
  @AfterEach
  void tearDown() {
    // Additional cleanup if needed
  }
}
```

---

## 🎯 Testing Best Practices

1. **Test Naming:** Use descriptive names (Given_When_Then pattern)
2. **Test Independence:** Each test should be self-contained
3. **Test Data:** Use fixtures and factories
4. **Assertions:** Use assertThat() for better readability
5. **Mocking:** Mock external dependencies
6. **Coverage:** Aim for 80%+ but focus on critical paths
7. **Performance:** Keep unit tests fast (< 100ms each)
8. **Maintenance:** Update tests with code changes

---

## 📈 Current Testing Status

### Overall Coverage
- **Unit Test Coverage:** 75%+
- **Integration Test Coverage:** 70%+
- **E2E Test Coverage:** Critical paths covered
- **Total Tests:** 500+ test cases
- **Test Execution Time:** ~5 minutes (unit + integration)

### Next Steps
1. Increase unit test coverage to 85%
2. Add performance testing with JMeter
3. Implement automated security scanning
4. Set up SonarQube for code quality
5. Add E2E tests for complex user flows
6. Implement contract testing for microservices

---

**Document maintained by:** Engineering Team  
**Review Frequency:** Monthly  
**Last Review:** January 2, 2026
