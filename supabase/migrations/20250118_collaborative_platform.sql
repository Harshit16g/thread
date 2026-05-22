-- Comprehensive Migration for Collaborative Human-AI Platform

-- 1. Enhance Profiles
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_agent BOOLEAN DEFAULT false;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS agent_metadata JSONB;

-- 2. Rooms (Discussions/Chats/Threads)
CREATE TABLE IF NOT EXISTS public.rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT,
    description TEXT,
    type TEXT CHECK (type IN ('private', 'ai', 'thread')) NOT NULL,
    status TEXT CHECK (status IN ('open', 'concluded')) DEFAULT 'open',
    is_public BOOLEAN DEFAULT false,
    owner_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- 3. Room Members
CREATE TABLE IF NOT EXISTS public.room_members (
    room_id UUID REFERENCES public.rooms(id) ON DELETE CASCADE,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT CHECK (role IN ('owner', 'member', 'ai')) DEFAULT 'member',
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (room_id, profile_id)
);

-- 4. Room Messages & Proposals
CREATE TABLE IF NOT EXISTS public.room_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID REFERENCES public.rooms(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    content TEXT NOT NULL,
    is_proposal BOOLEAN DEFAULT false,
    proposal_status TEXT CHECK (proposal_status IN ('pending', 'approved', 'rejected')),
    approved_by UUID REFERENCES public.profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Final Posts (Public Feed)
CREATE TABLE IF NOT EXISTS public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    room_id UUID REFERENCES public.rooms(id) ON DELETE SET NULL,
    author_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.room_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- Basic Policies (To be refined later for strict privacy)
CREATE POLICY "Public rooms are viewable by everyone" ON public.rooms FOR SELECT USING (is_public = true OR owner_id = auth.uid());
CREATE POLICY "Members can view their rooms" ON public.room_members FOR SELECT USING (profile_id = auth.uid());
CREATE POLICY "Members can view room messages" ON public.room_messages FOR SELECT USING (
    EXISTS (SELECT 1 FROM public.room_members WHERE room_id = room_messages.room_id AND profile_id = auth.uid())
);
CREATE POLICY "Public posts are viewable by everyone" ON public.posts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create posts" ON public.posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Owners can manage their rooms" ON public.rooms FOR ALL USING (owner_id = auth.uid());

-- Insert an AI agent profile if it doesn't exist
INSERT INTO auth.users (id, email) 
VALUES ('00000000-0000-0000-0000-000000000000', 'ai_assistant@tabl.ai')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, email, full_name, is_agent)
VALUES ('00000000-0000-0000-0000-000000000000', 'ai_assistant@tabl.ai', 'TabL AI', true)
ON CONFLICT (id) DO NOTHING;
