-- Migration: Admin Update User Password
-- Allows admins to directly change another user's password via auth.users table
-- Uses pgcrypto (already enabled) for bcrypt password hashing

CREATE OR REPLACE FUNCTION admin_update_user_password(
  p_user_id uuid,
  p_new_password text
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

  -- Prevent changing own password through this function
  IF p_user_id = auth.uid() THEN
    RAISE EXCEPTION 'Use the regular password change for your own account';
  END IF;

  -- Validate password minimum length
  IF LENGTH(p_new_password) < 6 THEN
    RAISE EXCEPTION 'Password must be at least 6 characters';
  END IF;

  -- Validate target user exists
  IF NOT EXISTS (SELECT 1 FROM public."user" WHERE id = p_user_id) THEN
    RAISE EXCEPTION 'User not found';
  END IF;

  -- Update password in auth.users using bcrypt
  UPDATE auth.users
  SET
    encrypted_password = crypt(p_new_password, gen_salt('bf')),
    updated_at = NOW()
  WHERE id = p_user_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Failed to update password: auth user not found';
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION admin_update_user_password IS 'Allows admin to directly set a new password for any user. Uses bcrypt hashing via pgcrypto.';
