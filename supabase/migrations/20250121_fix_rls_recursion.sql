-- Break RLS Recursion and Fix Visibility Logic

-- 1. Drop the recursive policies
DROP POLICY IF EXISTS "Rooms are viewable by members or if public" ON public.rooms;
DROP POLICY IF EXISTS "Members are viewable by room participants" ON public.room_members;

-- 2. New Room visibility policy
-- We separate the "joined" check into its own simple policy to keep things clean
CREATE POLICY "View public rooms" 
    ON public.rooms FOR SELECT 
    USING (is_public = true);

CREATE POLICY "View owned rooms" 
    ON public.rooms FOR SELECT 
    USING (owner_id = auth.uid());

-- This policy checks room_members. 
-- It is safe as long as room_members SELECT policy doesn't check rooms back.
CREATE POLICY "View joined rooms" 
    ON public.rooms FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.room_members 
            WHERE room_id = public.rooms.id 
            AND profile_id = auth.uid()
        )
    );

-- 3. New Room Members visibility policy
-- This is the "base" side of the relationship to avoid recursion.
-- We allow users to see their own membership and memberships in rooms they are in.
CREATE POLICY "View own membership" 
    ON public.room_members FOR SELECT 
    USING (profile_id = auth.uid());

-- To see other members in the same room, we use a self-join that doesn't reference 'rooms'
CREATE POLICY "View fellow members" 
    ON public.room_members FOR SELECT 
    USING (
        room_id IN (
            SELECT rm.room_id 
            FROM public.room_members rm 
            WHERE rm.profile_id = auth.uid()
        )
    );

-- 4. Fix Room Messages policy (ensuring it uses the simplified room check)
DROP POLICY IF EXISTS "Room messages are viewable by participants" ON public.room_messages;
CREATE POLICY "Room messages are viewable by participants" 
    ON public.room_messages FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.room_members 
            WHERE room_id = room_messages.room_id 
            AND profile_id = auth.uid()
        )
    );

-- 5. Fix Post insertion policy (simplifying the collaboration check)
DROP POLICY IF EXISTS "Users can create posts or approve collaborative ones" ON public.posts;
CREATE POLICY "Users can create posts" 
    ON public.posts FOR INSERT 
    WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Collaborative posts from joined rooms" 
    ON public.posts FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.room_members 
            WHERE room_id = posts.room_id 
            AND profile_id = auth.uid()
        )
    );
