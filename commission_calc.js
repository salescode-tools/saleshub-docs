/**
 * Sample KPI Script: Sales Commission Calculator
 * 
 * This script demonstrates how to calculate commission based on:
 * 1. Request Attributes (salesAmount, targetAmount)
 * 2. Default Configuration (baseRate) which can be overridden
 * 3. Business Logic (Standard Rate vs Bonus Rate)
 * 
 * Usage Context:
 * - 'request': Passed by the KpiProcessor. Contains .kpiName, .cadence, .level, .attributes
 * - 'kpiResultClass': The Java class to instantiate for the return value
 */

// 1. Instantiate the Result Object
var result = new kpiResultClass();
result.kpiName = request.kpiName;
// Preserve the Java Enum references for cadence and level if needed
if (request.cadence) result.cadence = request.cadence;
if (request.level) result.level = request.level;

// 2. Extract Logic Inputs
// These attributes come from the merged map of (DB extended_attr + API request attributes)
var attributes = request.attributes;

// 'salesAmount' and 'targetAmount' come from the API Request payload
var sales = attributes.get("salesAmount") || 0.0;
var target = attributes.get("targetAmount") || 10000.0;

// 'baseRate' can be defined in 'extended_attr' as a default (e.g., 0.04)
// It can also be overridden by the API request
var rate = attributes.get("baseRate") || 0.05;

// 3. Perform Business Logic
var commission = sales * rate;
var note = "Standard Rate (" + (rate * 100).toFixed(1) + "%) applied.";

// Bonus Logic: 2% extra on amount exceeding target
if (sales > target) {
    var excess = sales - target;
    var bonus = excess * 0.02;
    commission += bonus;
    note += " Target Exceeded! 2% Bonus applied on excess " + excess.toFixed(2);
}

// 4. Populate Result Data
// We use Java Collections to ensure strict typing is passed back to the Java processor
var dataList = new java.util.ArrayList();
var dataMap = new java.util.HashMap();

dataMap.put("sales_amount", sales);
dataMap.put("target_amount", target);
dataMap.put("commission_earned", commission);
dataMap.put("rate_applied", rate);
dataMap.put("note", note);

// Add timestamp for reference
dataMap.put("calculated_at", new java.util.Date().toString());

dataList.add(dataMap);
result.data = dataList;

// 5. Return the result object explicitly
result;
