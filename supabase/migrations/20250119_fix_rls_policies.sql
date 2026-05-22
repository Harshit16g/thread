-- ============================================================================
-- Fix RLS Policies for Realtime Chat
-- The original migration only had SELECT policies on room_messages and 
-- room_members, causing all INSERT operations to silently fail via RLS.
-- ============================================================================

-- 1. Room Members: Allow authenticated users to insert themselves (join rooms)
CREATE POLICY "Authenticated users can join rooms"
  ON public.room_members FOR INSERT
  WITH CHECK (auth.uid() = profile_id);

-- 2. Room Messages: Allow room members to insert messages
CREATE POLICY "Room members can send messages"
  ON public.room_messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM public.room_members
      WHERE room_id = room_messages.room_id
      AND profile_id = auth.uid()
    )
  );

-- 3. Room Messages: Allow the AI agent to insert messages into any room
--    (The AI agent UUID is 00000000-0000-0000-0000-000000000000)
CREATE POLICY "AI agent can send messages"
  ON public.room_messages FOR INSERT
  WITH CHECK (sender_id = '00000000-0000-0000-0000-000000000000');

-- 4. Room Messages: Allow room members to update proposal status (approve/reject)
CREATE POLICY "Room members can update proposals"
  ON public.room_messages FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.room_members
      WHERE room_id = room_messages.room_id
      AND profile_id = auth.uid()
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.room_members
      WHERE room_id = room_messages.room_id
      AND profile_id = auth.uid()
    )
  );

-- 5. Fix Rooms SELECT: Also show rooms where user is a member (not just owner/public)
DROP POLICY IF EXISTS "Public rooms are viewable by everyone" ON public.rooms;
CREATE POLICY "Users can view their rooms"
  ON public.rooms FOR SELECT
  USING (
    is_public = true
    OR owner_id = auth.uid()
    OR EXISTS (
      SELECT 1 FROM public.room_members
      WHERE room_id = rooms.id
      AND profile_id = auth.uid()
    )
  );

-- 6. Enable realtime for room_messages so Supabase streams work
ALTER PUBLICATION supabase_realtime ADD TABLE public.room_messages;
