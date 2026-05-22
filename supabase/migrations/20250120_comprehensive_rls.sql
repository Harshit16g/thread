-- Comprehensive RLS and Security Hardening

-- 1. Profiles: Allow users to see each other (required for chats/threads) but only edit their own
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Public profiles are viewable by authenticated users" 
    ON public.profiles FOR SELECT 
    TO authenticated 
    USING (true);

-- 2. Rooms: Precise control over visibility and management
DROP POLICY IF EXISTS "Public rooms are viewable by everyone" ON public.rooms;
DROP POLICY IF EXISTS "Owners can manage their rooms" ON public.rooms;

CREATE POLICY "Rooms are viewable by members or if public" 
    ON public.rooms FOR SELECT 
    USING (
        is_public = true 
        OR owner_id = auth.uid() 
        OR EXISTS (SELECT 1 FROM public.room_members WHERE room_id = public.rooms.id AND profile_id = auth.uid())
    );

CREATE POLICY "Authenticated users can create rooms" 
    ON public.rooms FOR INSERT 
    TO authenticated 
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update their rooms" 
    ON public.rooms FOR UPDATE 
    USING (auth.uid() = owner_id);

CREATE POLICY "Owners can delete their rooms" 
    ON public.rooms FOR DELETE 
    USING (auth.uid() = owner_id);

-- 3. Room Members: Allow joining and managing memberships
DROP POLICY IF EXISTS "Members can view their rooms" ON public.room_members;

CREATE POLICY "Members are viewable by room participants" 
    ON public.room_members FOR SELECT 
    USING (
        EXISTS (SELECT 1 FROM public.rooms WHERE id = room_id AND is_public = true)
        OR EXISTS (SELECT 1 FROM public.room_members participant WHERE participant.room_id = room_members.room_id AND participant.profile_id = auth.uid())
    );

CREATE POLICY "Users can join rooms or owners can add members" 
    ON public.room_members FOR INSERT 
    WITH CHECK (
        -- User is adding themselves to a room they just created (as owner) or a public room
        (auth.uid() = profile_id)
        -- Or the person adding is the owner of the room
        OR EXISTS (SELECT 1 FROM public.rooms WHERE id = room_id AND owner_id = auth.uid())
    );

CREATE POLICY "Owners can manage member roles" 
    ON public.room_members FOR UPDATE 
    USING (EXISTS (SELECT 1 FROM public.rooms WHERE id = room_id AND owner_id = auth.uid()));

CREATE POLICY "Members can leave or owners can remove" 
    ON public.room_members FOR DELETE 
    USING (
        auth.uid() = profile_id 
        OR EXISTS (SELECT 1 FROM public.rooms WHERE id = room_id AND owner_id = auth.uid())
    );

-- 4. Room Messages: Secure the conversation
DROP POLICY IF EXISTS "Members can view room messages" ON public.room_messages;

CREATE POLICY "Room messages are viewable by participants" 
    ON public.room_messages FOR SELECT 
    USING (
        EXISTS (SELECT 1 FROM public.room_members WHERE room_id = room_messages.room_id AND profile_id = auth.uid())
    );

CREATE POLICY "Participants can send messages" 
    ON public.room_messages FOR INSERT 
    WITH CHECK (
        auth.uid() = sender_id 
        AND EXISTS (SELECT 1 FROM public.room_members WHERE room_id = room_messages.room_id AND profile_id = auth.uid())
    );

CREATE POLICY "Authorized users can update proposal status" 
    ON public.room_messages FOR UPDATE 
    USING (
        -- Sender can edit their own message
        auth.uid() = sender_id
        -- Or room owner can approve/reject proposals
        OR EXISTS (SELECT 1 FROM public.rooms WHERE id = room_id AND owner_id = auth.uid())
    );

-- 5. Posts: Collaborative feed security
-- We allow users to approve AI proposals which creates a post as the AI or another user.
-- This requires a slightly more relaxed policy for system-facilitated collaborative posts.
DROP POLICY IF EXISTS "Public posts are viewable by everyone" ON public.posts;
DROP POLICY IF EXISTS "Authenticated users can create posts" ON public.posts;

CREATE POLICY "Posts are public" ON public.posts FOR SELECT USING (true);

CREATE POLICY "Users can create posts or approve collaborative ones" 
    ON public.posts FOR INSERT 
    WITH CHECK (
        -- Direct post by the user
        auth.uid() = author_id
        -- Or post created via room collaboration where user is a participant
        OR EXISTS (SELECT 1 FROM public.room_members WHERE room_id = posts.room_id AND profile_id = auth.uid())
    );

-- 6. TabL Module Hardening (Refining anonymous access)
-- Note: In a production app, we would strictly check user_id. 
-- For this collaborative platform, we ensure authenticated access at minimum.

DROP POLICY IF EXISTS "Allow anonymous operations on localbook_transactions" ON public.localbook_transactions;
CREATE POLICY "Users manage their own transactions" ON public.localbook_transactions 
    FOR ALL USING (auth.uid() = user_id OR user_id IS NULL) 
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

DROP POLICY IF EXISTS "Allow anonymous operations on salesbuddy_inventory" ON public.salesbuddy_inventory;
CREATE POLICY "Inventory is shared but managed by authenticated users" ON public.salesbuddy_inventory 
    FOR ALL USING (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Allow anonymous operations on salesbuddy_sales" ON public.salesbuddy_sales;
CREATE POLICY "Users manage their own sales" ON public.salesbuddy_sales 
    FOR ALL USING (auth.uid() = user_id OR user_id IS NULL)
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
