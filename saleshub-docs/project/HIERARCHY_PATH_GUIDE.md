# Hierarchy Path - Complete Chain Update

## Overview
Update the entire user hierarchy chain in a **single CSV column** using a path format with **bottom-up order** (closest parent first).

## Feature: Hierarchy Path Column

### New Column: `hierarchy_path`
Represents the complete reporting chain from **bottom to top** (closest parent first).

**Format:** `DirectParent > NextLevel > ... > TopLevel`

**Example:**
```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP001 > ASM001 > RSM001 > CEO001
```

**Meaning:** TSR001 reports to SUP001, who reports to ASM001, who reports to RSM001, who reports to CEO001

This automatically creates the entire chain:
- TSR001 → SUP001 (direct parent)
- SUP001 → ASM001
- ASM001 → RSM001
- RSM001 → CEO001
- CEO001 → (no parent, top level)

## Why Bottom-Up Order?

**Bottom-up** (closest parent first) is more intuitive because:
- ✅ Reads naturally: "I report to SUP, who reports to ASM, who reports to RSM..."
- ✅ Direct parent is first (most important relationship)
- ✅ Matches organizational thinking (my manager, their manager, etc.)

**Format:** `SUP001 > ASM001 > RSM001 > CEO001`
- First: Direct supervisor (SUP001)
- Last: Top executive (CEO001)

## CSV Format Options

### Option 1: Hierarchy Path (Recommended)
```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP001 > ASM001 > RSM001 > CEO001
TSR002,Jane Smith,SUP001 > ASM001 > RSM001 > CEO001
TSR003,Bob Johnson,SUP002 > ASM002 > RSM002 > CEO001
```

**Benefits:**
- ✅ Complete chain in one column
- ✅ Easy to read and understand
- ✅ Automatically creates all levels
- ✅ Handles missing users (creates stubs)

### Option 2: Parent Username (Existing)
```csv
salesrep_code,salesrep_name,parent_username
TSR001,John Doe,SUP001
```

**Benefits:**
- ✅ Simple for direct parent only
- ✅ Supports multiple parents: `"SUP001,SUP002"`

### Option 3: Both (Most Flexible)
```csv
salesrep_code,salesrep_name,hierarchy_path,parent_username
TSR001,John Doe,SUP001 > ASM001 > RSM001 > CEO001,TRAINER001
```

**Result:**
- Hierarchy chain: SUP001 → ASM001 → RSM001 → CEO001
- Additional parent: TRAINER001
- **Total parents for TSR001:** SUP001, TRAINER001

## Supported Delimiters

### Arrow (Recommended)
```csv
hierarchy_path
SUP001 > ASM001 > RSM001 > CEO001
```

### Slash
```csv
hierarchy_path
SUP001 / ASM001 / RSM001 / CEO001
```

### Backslash
```csv
hierarchy_path
SUP001 \ ASM001 \ RSM001 \ CEO001
```

### Pipe
```csv
hierarchy_path
SUP001 | ASM001 | RSM001 | CEO001
```

## Examples

### Example 1: Simple Hierarchy
```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP001 > MGR001
```

**Creates:**
- TSR001 → SUP001
- SUP001 → MGR001
- MGR001 → (no parent)

### Example 2: Deep Hierarchy
```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP > ASM > RSM > DIRECTOR > VP_SALES > CEO
```

**Creates 6-level chain:**
- TSR001 → SUP
- SUP → ASM
- ASM → RSM
- RSM → DIRECTOR
- DIRECTOR → VP_SALES
- VP_SALES → CEO
- CEO → (no parent)

### Example 3: Multiple Users, Same Hierarchy
```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP_NORTH > ASM_NORTH > RSM_NORTH > CEO
TSR002,Jane Smith,SUP_NORTH > ASM_NORTH > RSM_NORTH > CEO
TSR003,Bob Johnson,SUP_SOUTH > ASM_SOUTH > RSM_SOUTH > CEO
```

**Creates:**
- North branch: TSR001/TSR002 → SUP_NORTH → ASM_NORTH → RSM_NORTH → CEO
- South branch: TSR003 → SUP_SOUTH → ASM_SOUTH → RSM_SOUTH → CEO

### Example 4: Hierarchy Path + Additional Parents
```csv
salesrep_code,salesrep_name,hierarchy_path,parent_username
TSR001,John Doe,SUP > ASM > RSM > CEO,TRAINER001
```

**Creates:**
- Hierarchy: TSR001 → SUP → ASM → RSM → CEO
- Additional: TSR001 → TRAINER001
- **TSR001 has 2 parents:** SUP (from hierarchy), TRAINER001 (additional)

### Example 5: Matrix Organization
```csv
salesrep_code,salesrep_name,hierarchy_path,parent_username
TSR001,John Doe,MGR_SALES > DIRECTOR_SALES > VP_SALES > CEO,"MGR_OPS,MGR_TRAINING"
```

**Creates:**
- Sales hierarchy: TSR001 → MGR_SALES → DIRECTOR_SALES → VP_SALES → CEO
- Additional reporting: TSR001 → MGR_OPS, TSR001 → MGR_TRAINING
- **TSR001 has 3 parents:** MGR_SALES, MGR_OPS, MGR_TRAINING

## Column Aliases

The following column names are recognized as `hierarchy_path`:
- `hierarchy_path` ⭐ (primary)
- `hierarchy`
- `reporting_chain`
- `org_path`
- `org_hierarchy`
- `chain`
- `path`
- `reporting_path`

## How It Works

### Parsing Logic
```
Input: "SUP001 > ASM001 > RSM001 > CEO001"

1. Split by delimiter (>)
   → ["SUP001", "ASM001", "RSM001", "CEO001"]

2. Create parent mappings:
   - Current user → SUP001
   - SUP001 → ASM001
   - ASM001 → RSM001
   - RSM001 → CEO001
   - CEO001 → (no parent)

3. Ensure all users exist (create stubs if needed)

4. Create all parent mappings
```

### Processing Order
1. **Parse hierarchy path** → Extract chain
2. **Combine with parent_username** → Merge if both provided
3. **Ensure all users exist** → Create stubs for missing
4. **Create parent mappings** → For entire chain

## Benefits

### 1. Single Column for Complete Chain
**Before:**
```csv
# Need multiple rows or complex setup
TSR001,SUP001
SUP001,ASM001
ASM001,RSM001
RSM001,CEO001
```

**After:**
```csv
# Single row, single column
TSR001,SUP001 > ASM001 > RSM001 > CEO001
```

### 2. Easy to Read and Maintain
```csv
hierarchy_path
SUP > ASM > RSM > DIRECTOR > VP > CEO
```
Clear visual representation of reporting structure.

### 3. Automatic Stub Creation
Missing users in the chain are automatically created as stubs:
```csv
TSR001,SUP > ASM > RSM > CEO
```
If SUP, ASM, RSM, CEO don't exist → All created as stubs!

### 4. Flexible Combinations
Mix hierarchy path with additional parents:
```csv
hierarchy_path,parent_username
SUP > ASM > RSM > CEO,"TRAINER,MENTOR"
```

## Excel/Google Sheets Usage

### Excel
1. Enter hierarchy in one cell: `SUP > ASM > RSM > CEO`
2. Excel preserves the format
3. Save as CSV

### Google Sheets
1. Enter: `SUP > ASM > RSM > CEO`
2. Download as CSV
3. Upload to system

### Formulas
Build hierarchy dynamically:
```excel
=A2&" > "&B2&" > "&C2&" > "&D2
# Where A2=SUP, B2=ASM, C2=RSM, D2=CEO
```

## API Alternative

For programmatic updates:

```bash
# Set hierarchy path via API
PUT /users/TSR001/hierarchy-path
{
  "hierarchyPath": "SUP001 > ASM001 > RSM001 > CEO001"
}
```

## Validation Rules

### Valid Formats
- ✅ `SUP > ASM > RSM > CEO`
- ✅ `SUP / ASM / RSM / CEO`
- ✅ `SUP | ASM | RSM | CEO`
- ✅ `SUP \ ASM \ RSM \ CEO`

### Invalid Formats
- ❌ `SUP >> ASM` (double delimiter)
- ❌ `SUP >` (trailing delimiter)
- ❌ `> ASM` (leading delimiter)
- ❌ Empty levels: `SUP > > RSM`

### Auto-Cleanup
System automatically:
- Trims whitespace: `SUP > ASM` = `SUP>ASM`
- Removes empty levels
- Validates usernames

## Troubleshooting

### Issue: Hierarchy Not Created
**Cause:** Invalid delimiter
**Solution:** Use supported delimiters: `>`, `/`, `\`, `|`

### Issue: Partial Hierarchy
**Cause:** Some users in chain don't exist
**Solution:** System creates stubs automatically (check `/admin/stub-users`)

### Issue: Circular Reference
**Cause:** User appears multiple times in chain
**Solution:** System detects and prevents circular references

## Advanced Scenarios

### Scenario 1: Reorganization
Update entire hierarchy in one upload:
```csv
salesrep_code,hierarchy_path
TSR001,NEW_SUP > NEW_ASM > NEW_RSM > NEW_CEO
TSR002,NEW_SUP > NEW_ASM > NEW_RSM > NEW_CEO
```

### Scenario 2: Merge Hierarchies
```csv
salesrep_code,hierarchy_path,parent_username
TSR001,PRIMARY_SUP > PRIMARY_RSM > PRIMARY_CEO,SECONDARY_SUP
```

Creates dual reporting: Primary hierarchy + Secondary parent

### Scenario 3: Flatten Hierarchy
```csv
salesrep_code,hierarchy_path
TSR001,CEO
```

Direct reporting to CEO (skips middle management)

## Complete Example

### CSV Upload
```csv
salesrep_code,salesrep_name,phone,email,hierarchy_path,parent_username
TSR001,John Doe,9876543210,john@example.com,SUP001 > ASM001 > RSM001 > CEO001,
TSR002,Jane Smith,9876543211,jane@example.com,SUP001 > ASM001 > RSM001 > CEO001,
TSR003,Bob Johnson,9876543212,bob@example.com,SUP002 > ASM002 > RSM002 > CEO001,TRAINER001
SUP001,Alice Supervisor,9876543213,alice@example.com,ASM001 > RSM001 > CEO001,
SUP002,Charlie Supervisor,9876543214,charlie@example.com,ASM002 > RSM002 > CEO001,
ASM001,David Area Manager,9876543215,david@example.com,RSM001 > CEO001,
ASM002,Eve Area Manager,9876543216,eve@example.com,RSM002 > CEO001,
RSM001,Frank Regional Manager,9876543217,frank@example.com,CEO001,
RSM002,Grace Regional Manager,9876543218,grace@example.com,CEO001,
CEO001,Henry CEO,9876543219,henry@example.com,,
TRAINER001,Ivy Trainer,9876543220,ivy@example.com,CEO001,
```

### Result
Complete organization hierarchy created in single upload:
```
CEO001
├── RSM001
│   └── ASM001
│       └── SUP001
│           ├── TSR001
│           └── TSR002
├── RSM002
│   └── ASM002
│       └── SUP002
│           └── TSR003 (also reports to TRAINER001)
└── TRAINER001
    └── TSR003
```

## Summary

The hierarchy path feature provides:
- ✅ **Single column** for complete reporting chain
- ✅ **Bottom-up format** (closest parent first)
- ✅ **Easy to read** visual format
- ✅ **Automatic stub creation** for missing users
- ✅ **Flexible delimiters** (>, /, \, |)
- ✅ **Combines with parent_username** for matrix reporting
- ✅ **Excel/Sheets friendly** format
- ✅ **Zero failures** with stub user system

**Result:** Update entire organizational hierarchy in one CSV upload! 🎯
