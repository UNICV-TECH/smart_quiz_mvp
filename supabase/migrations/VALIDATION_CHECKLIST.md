# Migration Validation Checklist

## ✅ All Checks Passed

### 1. Baseline Schema (20240101000001_existing_schema_baseline.sql)
- ✅ Uses `CREATE EXTENSION IF NOT EXISTS` for pgcrypto
- ✅ Uses `CREATE TABLE IF NOT EXISTS` for all tables
- ✅ Matches exact naming from existing schema
- ✅ Column names: `idquestion`, `correctanswer`, `update_at` (as per existing)
- ✅ User table: `first_name`, `surname` (not `full_name`)
- ✅ Foreign keys reference correct tables
- ✅ All constraints have proper names

### 2. Add Columns (20240101000002_add_missing_columns.sql)
- ✅ Uses `ALTER TABLE ADD COLUMN IF NOT EXISTS` 
- ✅ CHECK constraint added separately with existence check
- ✅ Won't error if columns already exist
- ✅ Default values specified where needed
- ✅ Proper decimal precision (5,2)

### 3. New Tables (20240101000003_create_new_tables.sql)
- ✅ Uses `CREATE TABLE IF NOT EXISTS`
- ✅ Foreign keys reference existing tables
- ✅ Proper CASCADE/SET NULL on delete
- ✅ CHECK constraints inline (safe for new tables)
- ✅ Timestamp defaults use NOW()

### 4. Indexes (20240101000004_create_indexes.sql)
- ✅ Uses `CREATE INDEX IF NOT EXISTS`
- ✅ Conditional index creation for new columns using `DO $$ BEGIN`
- ✅ Checks column existence before creating indexes
- ✅ Won't error if columns don't exist yet
- ✅ Unique indexes where appropriate

### 5. Seed Data (20240101000005_seed_sample_data.sql)
- ✅ Uses `ON CONFLICT DO NOTHING` for courses
- ✅ Conditional logic checks if new columns exist
- ✅ Falls back to original column set if new columns missing
- ✅ NULL checks before proceeding with inserts
- ✅ Proper variable declarations in DO blocks

## Potential Issues Addressed

### Issue 1: CHECK Constraint with IF NOT EXISTS
**Problem:** PostgreSQL doesn't support `ADD COLUMN IF NOT EXISTS` with inline CHECK constraint  
**Solution:** Added check constraint separately with existence check in DO block

### Issue 2: Index on Non-Existent Columns
**Problem:** Migration 004 could fail if migration 002 skipped (columns already exist)  
**Solution:** Added conditional checks in DO blocks before creating indexes on new columns

### Issue 3: Seed Data with Missing Columns
**Problem:** INSERT would fail if new columns don't exist  
**Solution:** Dynamic column detection and conditional INSERT statements

## Migration Order

These migrations MUST be run in order:
1. Baseline schema → Creates/verifies base tables
2. Add columns → Extends existing tables
3. New tables → Creates userresponse and supportingtext
4. Indexes → Performance optimization
5. Seed data → Sample data for testing

## Safe to Run Multiple Times

All migrations are **idempotent**:
- ✅ `IF NOT EXISTS` clauses prevent duplication
- ✅ Conditional logic checks before modifications
- ✅ `ON CONFLICT DO NOTHING` in seed data
- ✅ No DROP statements

## Testing Commands

```sql
-- Test migration 1
\i 20240101000001_existing_schema_baseline.sql

-- Verify tables created
SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;

-- Test migration 2
\i 20240101000002_add_missing_columns.sql

-- Verify new columns
SELECT column_name FROM information_schema.columns 
WHERE table_schema = 'public' AND table_name = 'course';

-- Test migration 3
\i 20240101000003_create_new_tables.sql

-- Verify new tables
SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename IN ('userresponse', 'supportingtext');

-- Test migration 4
\i 20240101000004_create_indexes.sql

-- Verify indexes
SELECT indexname FROM pg_indexes WHERE schemaname = 'public' ORDER BY indexname;

-- Test migration 5
\i 20240101000005_seed_sample_data.sql

-- Verify data
SELECT name FROM course;
SELECT COUNT(*) FROM question;
```

## Final Verification

```sql
-- Check all foreign key constraints are valid
SELECT 
  tc.table_name, 
  tc.constraint_name, 
  kcu.column_name, 
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name 
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
  AND tc.table_schema = 'public';

-- Check all indexes
SELECT 
  schemaname,
  tablename,
  indexname,
  indexdef
FROM pg_indexes 
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
```
