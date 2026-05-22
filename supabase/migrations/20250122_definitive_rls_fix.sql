-- DEFINITIVE RLS FIX: ELIMINATE ALL RECURSION
-- This migration resets and establishes simple, non-recursive policies.

-- 0. Cleanup all existing policies to start fresh
DROP POLICY IF EXISTS "Rooms are viewable by members or if public" ON public.rooms;
DROP POLICY IF EXISTS "View public rooms" ON public.rooms;
DROP POLICY IF EXISTS "View owned rooms" ON public.rooms;
DROP POLICY IF EXISTS "View joined rooms" ON public.rooms;
DROP POLICY IF EXISTS "Authenticated users can create rooms" ON public.rooms;
DROP POLICY IF EXISTS "Owners can update their rooms" ON public.rooms;
DROP POLICY IF EXISTS "Owners can delete their rooms" ON public.rooms;

DROP POLICY IF EXISTS "Members can view their rooms" ON public.room_members;
DROP POLICY IF EXISTS "Members are viewable by room participants" ON public.room_members;
DROP POLICY IF EXISTS "View own membership" ON public.room_members;
DROP POLICY IF EXISTS "View fellow members" ON public.room_members;
DROP POLICY IF EXISTS "Users can join rooms or owners can add members" ON public.room_members;
DROP POLICY IF EXISTS "Owners can manage member roles" ON public.room_members;
DROP POLICY IF EXISTS "Members can leave or owners can remove" ON public.room_members;

DROP POLICY IF EXISTS "Members can view room messages" ON public.room_messages;
DROP POLICY IF EXISTS "Room messages are viewable by participants" ON public.room_messages;
DROP POLICY IF EXISTS "Participants can send messages" ON public.room_messages;
DROP POLICY IF EXISTS "Authorized users can update proposal status" ON public.room_messages;

DROP POLICY IF EXISTS "Public posts are viewable by everyone" ON public.posts;
DROP POLICY IF EXISTS "Authenticated users can create posts" ON public.posts;
DROP POLICY IF EXISTS "Users can create posts" ON public.posts;
DROP POLICY IF EXISTS "Collaborative posts from joined rooms" ON public.posts;

-- 1. ROOMS: Visibility and Management
-- Non-recursive: Only checks the 'rooms' table columns or auth.uid()
CREATE POLICY "rooms_select" ON public.rooms FOR SELECT USING (is_public = true OR owner_id = auth.uid());
CREATE POLICY "rooms_insert" ON public.rooms FOR INSERT WITH CHECK (owner_id = auth.uid());
CREATE POLICY "rooms_update" ON public.rooms FOR UPDATE USING (owner_id = auth.uid());
CREATE POLICY "rooms_delete" ON public.rooms FOR DELETE USING (owner_id = auth.uid());

-- 2. ROOM_MEMBERS: The bridge
-- CRITICAL: This MUST NOT reference the 'rooms' table to avoid recursion.
-- We only allow users to see their own membership record or memberships they created (as room owner).
CREATE POLICY "room_members_select" ON public.room_members FOR SELECT USING (profile_id = auth.uid());
CREATE POLICY "room_members_insert" ON public.room_members FOR INSERT WITH CHECK (profile_id = auth.uid());
CREATE POLICY "room_members_delete" ON public.room_members FOR DELETE USING (profile_id = auth.uid());

-- 3. ROOM_MESSAGES: Conversation security
-- Uses a direct check on room_members. Since room_members no longer checks rooms, this is safe.
CREATE POLICY "room_messages_select" ON public.room_messages FOR SELECT 
    USING (EXISTS (SELECT 1 FROM public.room_members WHERE room_id = room_messages.room_id AND profile_id = auth.uid()));

CREATE POLICY "room_messages_insert" ON public.room_messages FOR INSERT 
    WITH CHECK (sender_id = auth.uid() AND EXISTS (SELECT 1 FROM public.room_members WHERE room_id = room_messages.room_id AND profile_id = auth.uid()));

-- 4. POSTS: Public Feed
CREATE POLICY "posts_select" ON public.posts FOR SELECT USING (true);
CREATE POLICY "posts_insert" ON public.posts FOR INSERT 
    WITH CHECK (author_id = auth.uid() OR EXISTS (SELECT 1 FROM public.room_members WHERE room_id = posts.room_id AND profile_id = auth.uid()));

-- 5. PROFILES: Discovery
DROP POLICY IF EXISTS "Public profiles are viewable by authenticated users" ON public.profiles;
CREATE POLICY "profiles_select" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_update" ON public.profiles FOR UPDATE USING (id = auth.uid());

-- 6. AUDIT: Fix the "View joined rooms" problem without recursion
-- Instead of a complex RLS on rooms, we let the app query rooms via the room_members table.
-- BUT, if we really need to see joined rooms in a single query:
CREATE POLICY "rooms_joined_select" ON public.rooms FOR SELECT 
    USING (id IN (SELECT room_id FROM public.room_members WHERE profile_id = auth.uid()));
-- Note: Postgres handles 'IN (SELECT ... FROM bridge)' efficiently and it's less prone to recursion loops
-- than 'EXISTS' when the bridge table has its own complex policies.
