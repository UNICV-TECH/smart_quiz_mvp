-- SQL function to fetch random questions for an exam
-- This is optional - the repository can work without it
-- If you want to use true random sampling, create this function in Supabase SQL Editor

CREATE OR REPLACE FUNCTION get_random_questions(
  p_exam_id UUID,
  p_limit INTEGER
)
RETURNS TABLE (
  id UUID,
  enunciation TEXT,
  difficulty_level TEXT,
  points DECIMAL(5,2)
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    q.id,
    q.enunciation,
    q.difficulty_level,
    q.points
  FROM questions q
  WHERE q.exam_id = p_exam_id
    AND q.is_active = TRUE
  ORDER BY RANDOM()
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION get_random_questions TO authenticated;

-- NOTE: The repository implementation uses direct queries without this function
-- This function is provided for future optimization if needed
