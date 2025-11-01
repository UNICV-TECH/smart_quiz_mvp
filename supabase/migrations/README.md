# Supabase Database Migrations

This directory contains SQL migration files for the Smart Quiz application database schema.

## ⚠️ Important: Existing Tables

**Your tables already exist in Supabase.** These migrations are designed to be safe:

1. **Migration 1** - Uses `CREATE TABLE IF NOT EXISTS` (will skip if tables exist)
2. **Migration 2** - Uses `ALTER TABLE ADD COLUMN IF NOT EXISTS` (adds new columns only)
3. **Migrations 3-5** - Create new tables, indexes, and seed data

## Migration Files

Apply in this order:

1. **20240101000001_existing_schema_baseline.sql** - Baseline schema (matches your existing tables exactly)
2. **20240101000002_add_missing_columns.sql** - **Adds new columns** to existing tables
3. **20240101000003_create_new_tables.sql** - Creates `userresponse` and `supportingtext` tables
4. **20240101000004_create_indexes.sql** - Adds performance indexes
5. **20240101000005_seed_sample_data.sql** - Sample courses and questions
6. **20240101000006_create_user_exam_attempts.sql** - Adds `user_exam_attempts` table and aligns `user_responses`

## What Gets Modified

### Migration 2 adds these columns to existing tables:

**course table:**
- `description` (text)
- `is_active` (boolean, default TRUE)

**exam table:**
- `question_count` (integer)
- `total_score` (decimal 5,2)
- `percentage_score` (decimal 5,2)

**question table:**
- `difficulty_level` (text: 'easy', 'medium', 'hard')
- `points` (decimal 5,2, default 1.0)
- `is_active` (boolean, default TRUE)

**examquestion table:**
- `question_order` (integer)

### Migration 3 creates new tables:

- **userresponse** - Tracks user answers per exam
- **supportingtext** - Supplementary materials for questions

## Applying Migrations

### Using Supabase CLI

```bash
supabase db push
```

### Using Supabase Dashboard

1. Go to **SQL Editor**
2. Copy and paste each migration file in order
3. Execute each script

### Manual Execution

```bash
psql -h your-db-host -U postgres -d postgres -f supabase/migrations/20240101000001_existing_schema_baseline.sql
```

## Schema Overview

### Existing Tables (from your database)

- **user** - id, created_at, update_at, email, first_name, surname
- **course** - id, created_at, update_at, name, icon
- **exam** - id, created_at, update_at, date_start, date_end, is_completed, id_user, id_course
- **question** - id, created_at, update_at, enunciation, id_course
- **examquestion** - id, created_at, update_at, id_exam, id_question
- **answerchoice** - id, created_at, upload_at, letter, content, correctanswer, idquestion

### New Tables (will be created)

- **userresponse** - Individual answer tracking
- **supportingtext** - Question supplementary materials

## Table Relationships

```
user (1) ────── (M) exam (M) ────── (1) course
                     │                    │
                     │ (M)                │ (1)
                     │                    │
                     ▼ (1)                ▼ (M)
              examquestion ──────── question (1) ────── (M) answerchoice
                     │                    │
                     │                    │ (1)
                     ▼                    ▼ (M)
              userresponse          supportingtext
```

## Safety Notes

- All migrations use `IF NOT EXISTS` or `ADD COLUMN IF NOT EXISTS`
- Safe to run multiple times (idempotent)
- Won't drop or modify existing data
- Foreign key constraints preserved
- Seed data uses `ON CONFLICT DO NOTHING`

## Related Documentation

See [SCHEMA_DOCUMENTATION.md](../../SCHEMA_DOCUMENTATION.md) for complete data flow and entity relationships.
