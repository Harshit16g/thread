# Database Setup Guide

This guide explains how to set up the database schema for the TabL application using Supabase.

## Prerequisites

- Supabase account and project
- Supabase CLI installed (optional but recommended)
- Access to your project's SQL Editor in Supabase dashboard

## Setup Methods

### Method 1: Using Supabase CLI (Recommended)

1. Install Supabase CLI:
```bash
npm install -g supabase
```

2. Link your project:
```bash
supabase link --project-ref YOUR_PROJECT_REF
```

3. Apply migrations:
```bash
supabase db push
```

### Method 2: Using Supabase Dashboard

1. Log in to your Supabase dashboard
2. Navigate to the SQL Editor
3. Open the migration file: `supabase/migrations/20250114_create_profiles.sql`
4. Copy the SQL content
5. Paste it into the SQL Editor
6. Click "Run" to execute the migration

## What Gets Created

### Tables

**profiles**
- Stores user profile information
- Linked to `auth.users` via foreign key
- Fields: id, email, full_name, avatar_url, bio, phone_number, created_at, updated_at

### Row Level Security (RLS)

All tables have RLS enabled with policies:
- Users can only view their own profile
- Users can only insert their own profile
- Users can only update their own profile

### Storage Buckets

**avatars**
- Public bucket for user profile pictures
- Policies allow users to upload/update/delete only their own avatars

### Database Triggers

**handle_new_user()**
- Automatically creates a profile when a new user signs up
- Extracts email and name from auth metadata
- Ensures every user has a profile record

## Verification

After running the migration, verify the setup:

1. Check if the profiles table exists:
```sql
SELECT * FROM information_schema.tables WHERE table_name = 'profiles';
```

2. Check if RLS is enabled:
```sql
SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'profiles';
```

3. Check if the trigger exists:
```sql
SELECT * FROM information_schema.triggers WHERE trigger_name = 'on_auth_user_created';
```

4. Check if the avatars bucket exists:
```sql
SELECT * FROM storage.buckets WHERE name = 'avatars';
```

## Testing Profile Creation

1. Sign up a new user through the app
2. Check if a profile was automatically created:
```sql
SELECT * FROM public.profiles WHERE email = 'test@example.com';
```

## Troubleshooting

### Profile not created on signup
- Check if the trigger is properly installed
- Check Supabase logs for errors
- Verify RLS policies are not blocking inserts

### Cannot upload avatar
- Verify the avatars storage bucket exists
- Check storage policies are properly configured
- Ensure file size is within limits

### Permission denied errors
- Verify RLS policies are correctly configured
- Check user is authenticated before accessing profiles
- Confirm auth.uid() matches the profile id

## Manual Profile Creation

If you need to manually create a profile:

```sql
INSERT INTO public.profiles (id, email, full_name, created_at)
VALUES (
    'USER_UUID_HERE',
    'user@example.com',
    'User Name',
    NOW()
);
```

## Schema Updates

To modify the schema in the future:

1. Create a new migration file in `supabase/migrations/`
2. Name it with timestamp prefix: `YYYYMMDD_description.sql`
3. Apply it using CLI: `supabase db push`
4. Or run manually through the SQL Editor

## Security Best Practices

✅ RLS is enabled on all public tables
✅ Users can only access their own data
✅ Storage policies prevent unauthorized uploads
✅ Database triggers ensure data integrity
✅ Sensitive data is never exposed through public APIs

## Support

For issues or questions:
- Check Supabase documentation: https://supabase.com/docs
- Review application logs
- Consult the profile feature documentation in `docs/dev/profile/feature.md`
