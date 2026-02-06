# Hierarchy Path Feature - Bottom-Up Format

## ✅ Format: SUP > ASM > RSM > CEO (Low to High)

Users provide input in **bottom-up order** (closest parent first).

## CSV Format

```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP001 > ASM001 > RSM001 > CEO001
```

**Meaning:**
- TSR001 reports to SUP001 (direct parent)
- SUP001 reports to ASM001
- ASM001 reports to RSM001
- RSM001 reports to CEO001 (top level)

## Why Bottom-Up?

✅ **Natural thinking:** "I report to my supervisor, who reports to area manager..."  
✅ **Direct parent first:** Most important relationship comes first  
✅ **Intuitive order:** Matches how people describe their reporting chain

## Complete Example

```csv
salesrep_code,salesrep_name,hierarchy_path
TSR001,John Doe,SUP001 > ASM001 > RSM001 > CEO001
TSR002,Jane Smith,SUP001 > ASM001 > RSM001 > CEO001
TSR003,Bob Johnson,SUP002 > ASM002 > RSM002 > CEO001
SUP001,Alice Supervisor,ASM001 > RSM001 > CEO001
SUP002,Charlie Supervisor,ASM002 > RSM002 > CEO001
ASM001,David Area Manager,RSM001 > CEO001
ASM002,Eve Area Manager,RSM002 > CEO001
RSM001,Frank Regional Manager,CEO001
RSM002,Grace Regional Manager,CEO001
CEO001,Henry CEO,
```

**Result:**
```
CEO001
├── RSM001
│   └── ASM001
│       └── SUP001
│           ├── TSR001
│           └── TSR002
└── RSM002
    └── ASM002
        └── SUP002
            └── TSR003
```

## How It Works

**Input (Bottom-Up):** `SUP001 > ASM001 > RSM001 > CEO001`

**Creates mappings:**
- TSR001 → SUP001
- SUP001 → ASM001
- ASM001 → RSM001
- RSM001 → CEO001

## Supported Delimiters

All work the same:
- `SUP > ASM > RSM > CEO` (recommended)
- `SUP / ASM / RSM / CEO`
- `SUP \ ASM \ RSM \ CEO`
- `SUP | ASM | ASM | CEO`

## Column Aliases

The following column names work:
- `hierarchy_path` ⭐
- `hierarchy`
- `reporting_chain`
- `org_path`
- `org_hierarchy`
- `chain`
- `path`
- `reporting_path`

## Combining with Additional Parents

```csv
salesrep_code,hierarchy_path,parent_username
TSR001,SUP > ASM > RSM > CEO,TRAINER001
```

Creates:
- Hierarchy: TSR001 → SUP → ASM → RSM → CEO
- Additional: TSR001 → TRAINER001
- **Total parents:** SUP, TRAINER001

## Benefits

✅ **Bottom-up format** - Closest parent first (natural)  
✅ **Single column** - Complete chain in one field  
✅ **Auto-stub creation** - Missing users created automatically  
✅ **Flexible delimiters** - Use >, /, \, or |  
✅ **Matrix support** - Combine with parent_username  
✅ **Zero failures** - Stub system ensures success

## Template Download

```bash
GET /mdm/template/salesrep
```

Downloads CSV with `hierarchy_path` column included.

## Summary

- **Format:** `SUP > ASM > RSM > CEO` (bottom-up, low to high)
- **Direct parent first:** Most intuitive for users
- **Result:** Complete organizational hierarchy in single CSV upload!
