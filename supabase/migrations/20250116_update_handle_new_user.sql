-- Update handle_new_user function to include theme_preference
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, full_name, created_at, theme_preference)
    VALUES (
        NEW.id,
        NEW.email,
        NEW.raw_user_meta_data->>'full_name',
        NOW(),
        'system' -- Default theme preference
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
