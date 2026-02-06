# Multiple Hierarchy Paths - Matrix Reporting

## Overview
Support **multiple hierarchy paths** in a single field to represent complex matrix reporting structures.

## Format

**Single Path:**
```csv
hierarchy_path
SUP > ASM > CEO
```

**Multiple Paths (Comma-Separated):**
```csv
hierarchy_path
SUP1 > ASM1 > CEO, SUP2 > ASM2 > CEO
```

## Examples

### Example 1: Dual Reporting
```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP_SALES > MGR_SALES > VP_SALES, SUP_OPS > MGR_OPS > VP_OPS
```

**Creates:**
- TSR001 → SUP_SALES, SUP_OPS (two direct parents)
- SUP_SALES → MGR_SALES → VP_SALES
- SUP_OPS → MGR_OPS → VP_OPS

**Result:**
```
VP_SALES          VP_OPS
    ↓                ↓
MGR_SALES        MGR_OPS
    ↓                ↓
SUP_SALES        SUP_OPS
    ↘              ↙
      TSR001
```

### Example 2: Matrix Organization
```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP_FUNCTIONAL > MGR_FUNCTIONAL > CEO, SUP_PROJECT > MGR_PROJECT > CEO
```

**Creates:**
- TSR001 reports to SUP_FUNCTIONAL (functional manager)
- TSR001 reports to SUP_PROJECT (project manager)
- Both chains lead to CEO

### Example 3: Multiple Chains with Different Depths
```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP > ASM > RSM > CEO, TRAINER > TRAINING_MGR, MENTOR
```

**Creates:**
- Chain 1: TSR001 → SUP → ASM → RSM → CEO (4 levels)
- Chain 2: TSR001 → TRAINER → TRAINING_MGR (2 levels)
- Chain 3: TSR001 → MENTOR (1 level)

**Total parents for TSR001:** SUP, TRAINER, MENTOR

### Example 4: Complex Matrix
```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP_SALES > ASM_SALES > RSM_SALES > VP_SALES > CEO, SUP_OPS > ASM_OPS > RSM_OPS > VP_OPS > CEO, TRAINER > TRAINING_HEAD > CEO
```

**Creates 3 reporting chains:**
1. Sales hierarchy (5 levels)
2. Operations hierarchy (5 levels)
3. Training hierarchy (3 levels)

All converge at CEO.

## Syntax

### Delimiters

**Path Separator:** Comma `,`
```
path1, path2, path3
```

**Level Separator:** `>`, `/`, `\`, or `|`
```
SUP > ASM > CEO
SUP / ASM / CEO
SUP \ ASM \ CEO
SUP | ASM | CEO
```

### Whitespace
Automatically trimmed:
```
SUP > ASM > CEO, TRAINER > MGR
```
= 
```
SUP>ASM>CEO,TRAINER>MGR
```

## Complete Example

```csv
salesrep_code,salesrep_name,phone,email,hierarchy_path
TSR001,John Doe,9876543210,john@example.com,SUP_SALES > ASM_SALES > CEO, SUP_OPS > ASM_OPS > CEO
TSR002,Jane Smith,9876543211,jane@example.com,SUP_SALES > ASM_SALES > CEO
TSR003,Bob Johnson,9876543212,bob@example.com,SUP_OPS > ASM_OPS > CEO, TRAINER > TRAINING_MGR
```

**Result:**
```
                    CEO
          ┌──────────┼──────────┐
      ASM_SALES  ASM_OPS  TRAINING_MGR
          │          │          │
      SUP_SALES  SUP_OPS    TRAINER
       │    │       │          │
    TSR001 TSR002 TSR001    TSR003
                   TSR003
```

## Benefits

### 1. Matrix Reporting
Support complex organizational structures:
- Functional reporting
- Project reporting
- Dotted-line reporting

### 2. Single Field
No need for multiple columns:
```csv
# Instead of:
hierarchy_path_1,hierarchy_path_2,hierarchy_path_3

# Use:
hierarchy_path
path1, path2, path3
```

### 3. Flexible Depth
Each path can have different levels:
```csv
hierarchy_path
SUP > ASM > RSM > CEO, TRAINER, MENTOR > SENIOR_MENTOR
```

### 4. Auto-Stub Creation
All users in all paths are created as stubs if missing.

## Combining with parent_username

You can still use `parent_username` for additional parents:

```csv
salesrep_code,hierarchy_path,parent_username
TSR001,SUP_SALES > MGR_SALES, SUP_OPS > MGR_OPS,TRAINER
```

**Total parents:** SUP_SALES, SUP_OPS, TRAINER

## Use Cases

### Use Case 1: Sales & Operations
```csv
hierarchy_path
SUP_SALES > DIRECTOR_SALES > VP_SALES > CEO, SUP_OPS > DIRECTOR_OPS > VP_OPS > CEO
```

### Use Case 2: Functional & Project
```csv
hierarchy_path
FUNCTIONAL_MGR > DEPT_HEAD > CEO, PROJECT_MGR > PROGRAM_MGR > PMO_HEAD > CEO
```

### Use Case 3: Training & Mentorship
```csv
hierarchy_path
SUP > ASM > CEO, TRAINER > TRAINING_HEAD, MENTOR
```

## Validation

### Valid Formats
- ✅ `SUP > ASM, TRAINER`
- ✅ `SUP > ASM > CEO, TRAINER > MGR, MENTOR`
- ✅ `SUP1 > ASM1, SUP2 > ASM2, SUP3 > ASM3`

### Invalid Formats
- ❌ `SUP > ASM,` (trailing comma)
- ❌ `,TRAINER` (leading comma)
- ❌ `SUP >> ASM, TRAINER` (double delimiter)

## API Response

```bash
GET /user-parent-mappings/TSR001/parents
```

**Response:**
```json
["SUP_SALES", "SUP_OPS", "TRAINER"]
```

All parents from all paths are returned.

## Summary

- ✅ **Multiple paths** separated by comma
- ✅ **Different depths** per path
- ✅ **Matrix reporting** support
- ✅ **Auto-stub creation** for all chains
- ✅ **Flexible syntax** with multiple delimiters
- ✅ **Combines with parent_username** for even more flexibility

**Result:** Complete matrix organization support in single CSV field! 🎯
