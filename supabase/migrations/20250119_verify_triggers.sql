-- Finalize and Verify Trigger for Profile Creation
-- This migration ensures the handle_new_user function and its corresponding trigger
-- on auth.users are correctly set up and synchronized with the current profiles schema.

-- 1. Update the function to handle all current columns (theme_preference, is_agent, etc.)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, created_at, theme_preference, is_agent)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'full_name',
        NOW(),
        'system',
        false
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Re-create the trigger to ensure it is active and points to the latest function body
-- We use a DO block to drop the trigger silently if it exists, avoiding the NOTICE
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.triggers WHERE trigger_name = 'on_auth_user_created' AND event_object_table = 'users' AND event_object_schema = 'auth') THEN
        DROP TRIGGER on_auth_user_created ON auth.users;
    END IF;
END $$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();
