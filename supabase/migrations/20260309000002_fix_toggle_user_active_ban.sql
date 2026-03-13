-- Migration: Fix admin_toggle_user_active to actually ban/unban users in Supabase Auth
-- When is_active = false, sets banned_until on auth.users so Supabase rejects login/token refresh
-- When is_active = true, clears the ban

CREATE OR REPLACE FUNCTION admin_toggle_user_active(
  p_user_id uuid,
  p_is_active boolean
)
RETURNS void AS $$
BEGIN
  -- Validate caller is admin
  IF NOT EXISTS (
    SELECT 1 FROM public."user"
    WHERE public."user".id = auth.uid() AND public."user".role = 'admin'
  ) THEN
    RAISE EXCEPTION 'Access denied: admin role required';
  END IF;

  -- Prevent self-deactivation
  IF p_user_id = auth.uid() AND p_is_active = false THEN
    RAISE EXCEPTION 'Cannot deactivate your own account';
  END IF;

  -- Update public.user table
  UPDATE public."user"
  SET is_active = p_is_active, updated_at = NOW()
  WHERE id = p_user_id;

  -- Ban or unban in Supabase Auth
  IF p_is_active = false THEN
    -- Ban user by setting banned_until to far future
    UPDATE auth.users
    SET banned_until = '2999-12-31 23:59:59+00'::timestamptz,
        updated_at = NOW()
    WHERE id = p_user_id;
  ELSE
    -- Unban user by clearing banned_until
    UPDATE auth.users
    SET banned_until = NULL,
        updated_at = NOW()
    WHERE id = p_user_id;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION admin_toggle_user_active IS 'Toggles user active status and bans/unbans in Supabase Auth. Admin only, prevents self-deactivation.';
