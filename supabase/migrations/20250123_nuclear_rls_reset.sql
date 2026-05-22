-- ============================================================================
-- NUCLEAR RLS RESET: Drop EVERY policy on EVERY table. Rebuild from scratch.
-- Uses SECURITY DEFINER helper functions to break ALL recursion permanently.
-- ============================================================================

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 1: DROP EVERY EXISTING POLICY ON EVERY TABLE                    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

DO $$
DECLARE
    r RECORD;
BEGIN
    -- Drop ALL policies on ALL tables in the public schema, no exceptions.
    FOR r IN (
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'public'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- Also drop any storage policies we may have layered
DO $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (
        SELECT schemaname, tablename, policyname
        FROM pg_policies
        WHERE schemaname = 'storage'
    ) LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', r.policyname, r.schemaname, r.tablename);
    END LOOP;
END $$;

-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 2: CREATE SECURITY DEFINER HELPER FUNCTIONS                     ║
-- ║  These bypass RLS on the inner lookup → no recursion possible.         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Helper: Get all room_ids a user is a member of (bypasses room_members RLS)
CREATE OR REPLACE FUNCTION public.get_my_room_ids()
RETURNS SETOF UUID
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT room_id FROM public.room_members WHERE profile_id = auth.uid();
$$;

-- Helper: Check if the current user is a member of a specific room (bypasses room_members RLS)
CREATE OR REPLACE FUNCTION public.is_room_member(p_room_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.room_members
        WHERE room_id = p_room_id AND profile_id = auth.uid()
    );
$$;

-- Helper: Check if the current user owns a specific room (bypasses rooms RLS)
CREATE OR REPLACE FUNCTION public.is_room_owner(p_room_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.rooms
        WHERE id = p_room_id AND owner_id = auth.uid()
    );
$$;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 3: ENSURE RLS IS ENABLED ON ALL TABLES                         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

ALTER TABLE public.profiles              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_members          ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_messages         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.localbook_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.krishibot_advice      ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.medguide_conditions   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tutorbot_qa           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.salesbuddy_inventory  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.salesbuddy_sales      ENABLE ROW LEVEL SECURITY;


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 4: PROFILES                                                     ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Anyone authenticated can see profiles (needed for chat participant names)
CREATE POLICY "profiles_select"
    ON public.profiles FOR SELECT
    TO authenticated
    USING (true);

-- Users can only insert their own profile
CREATE POLICY "profiles_insert"
    ON public.profiles FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = id);

-- Users can only update their own profile
CREATE POLICY "profiles_update"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 5: ROOMS                                                        ║
-- ║  Uses get_my_room_ids() to avoid touching room_members RLS.            ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- SELECT: public rooms, rooms I own, or rooms I'm a member of
CREATE POLICY "rooms_select"
    ON public.rooms FOR SELECT
    TO authenticated
    USING (
        is_public = true
        OR owner_id = auth.uid()
        OR id IN (SELECT public.get_my_room_ids())
    );

-- INSERT: I must be the owner
CREATE POLICY "rooms_insert"
    ON public.rooms FOR INSERT
    TO authenticated
    WITH CHECK (owner_id = auth.uid());

-- UPDATE: Only the owner
CREATE POLICY "rooms_update"
    ON public.rooms FOR UPDATE
    TO authenticated
    USING (owner_id = auth.uid());

-- DELETE: Only the owner
CREATE POLICY "rooms_delete"
    ON public.rooms FOR DELETE
    TO authenticated
    USING (owner_id = auth.uid());


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 6: ROOM_MEMBERS                                                ║
-- ║  NEVER references rooms or itself via subquery. Pure column checks.    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- SELECT: I can see my own membership row.
-- To see other members in the same room, the app queries via get_my_room_ids().
CREATE POLICY "room_members_select_own"
    ON public.room_members FOR SELECT
    TO authenticated
    USING (profile_id = auth.uid());

-- SELECT: I can also see other members in rooms I belong to.
-- Uses the SECURITY DEFINER helper so no RLS re-evaluation on room_members.
CREATE POLICY "room_members_select_peers"
    ON public.room_members FOR SELECT
    TO authenticated
    USING (room_id IN (SELECT public.get_my_room_ids()));

-- INSERT: I can add myself, OR I'm the room owner adding someone else
CREATE POLICY "room_members_insert"
    ON public.room_members FOR INSERT
    TO authenticated
    WITH CHECK (
        profile_id = auth.uid()
        OR public.is_room_owner(room_id)
    );

-- UPDATE: Only room owners can change roles
CREATE POLICY "room_members_update"
    ON public.room_members FOR UPDATE
    TO authenticated
    USING (public.is_room_owner(room_id));

-- DELETE: I can remove myself, or the room owner can remove me
CREATE POLICY "room_members_delete"
    ON public.room_members FOR DELETE
    TO authenticated
    USING (
        profile_id = auth.uid()
        OR public.is_room_owner(room_id)
    );


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 7: ROOM_MESSAGES                                               ║
-- ║  Uses is_room_member() helper → no room_members RLS re-entry.         ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- SELECT: Only room participants can read messages
CREATE POLICY "room_messages_select"
    ON public.room_messages FOR SELECT
    TO authenticated
    USING (public.is_room_member(room_id));

-- INSERT: Must be sender AND a room participant
CREATE POLICY "room_messages_insert"
    ON public.room_messages FOR INSERT
    TO authenticated
    WITH CHECK (
        sender_id = auth.uid()
        AND public.is_room_member(room_id)
    );

-- UPDATE: Sender can edit, or room owner can approve/reject proposals
CREATE POLICY "room_messages_update"
    ON public.room_messages FOR UPDATE
    TO authenticated
    USING (
        sender_id = auth.uid()
        OR public.is_room_owner(room_id)
    );


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 8: POSTS (PUBLIC FEED)                                          ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- SELECT: All posts are public
CREATE POLICY "posts_select"
    ON public.posts FOR SELECT
    USING (true);

-- INSERT: Author is current user, or user is a member of the source room
CREATE POLICY "posts_insert"
    ON public.posts FOR INSERT
    TO authenticated
    WITH CHECK (
        author_id = auth.uid()
        OR (room_id IS NOT NULL AND public.is_room_member(room_id))
    );

-- UPDATE: Only the author can edit
CREATE POLICY "posts_update"
    ON public.posts FOR UPDATE
    TO authenticated
    USING (author_id = auth.uid());

-- DELETE: Only the author can delete
CREATE POLICY "posts_delete"
    ON public.posts FOR DELETE
    TO authenticated
    USING (author_id = auth.uid());


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 9: AUTOLOCAL MODULE TABLES (Simple open access)                 ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- LocalBook: Authenticated users manage their own transactions
CREATE POLICY "localbook_all"
    ON public.localbook_transactions FOR ALL
    TO authenticated
    USING (user_id = auth.uid() OR user_id IS NULL)
    WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

-- Also allow anon reads for the AI tools when user isn't logged in
CREATE POLICY "localbook_anon_read"
    ON public.localbook_transactions FOR SELECT
    TO anon
    USING (true);

-- KrishiBot: Read-only reference data, open to everyone
CREATE POLICY "krishibot_select"
    ON public.krishibot_advice FOR SELECT
    USING (true);

-- MedGuide: Read-only reference data, open to everyone
CREATE POLICY "medguide_select"
    ON public.medguide_conditions FOR SELECT
    USING (true);

-- TutorBot: Read-only reference data, open to everyone
CREATE POLICY "tutorbot_select"
    ON public.tutorbot_qa FOR SELECT
    USING (true);

-- SalesBuddy Inventory: Authenticated users can read and modify
CREATE POLICY "inventory_all"
    ON public.salesbuddy_inventory FOR ALL
    TO authenticated
    USING (true)
    WITH CHECK (true);

CREATE POLICY "inventory_anon_read"
    ON public.salesbuddy_inventory FOR SELECT
    TO anon
    USING (true);

-- SalesBuddy Sales: Authenticated users manage their own sales
CREATE POLICY "sales_all"
    ON public.salesbuddy_sales FOR ALL
    TO authenticated
    USING (user_id = auth.uid() OR user_id IS NULL)
    WITH CHECK (user_id = auth.uid() OR user_id IS NULL);

CREATE POLICY "sales_anon_read"
    ON public.salesbuddy_sales FOR SELECT
    TO anon
    USING (true);


-- ╔══════════════════════════════════════════════════════════════════════════╗
-- ║  PHASE 10: STORAGE (avatars bucket)                                    ║
-- ╚══════════════════════════════════════════════════════════════════════════╝

-- Recreate storage policies cleanly
CREATE POLICY "avatars_public_read"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');

CREATE POLICY "avatars_owner_insert"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "avatars_owner_update"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "avatars_owner_delete"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'avatars'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );
