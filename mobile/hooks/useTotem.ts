import { useState, useCallback } from "react";
import { api } from "../services/api";
import { getToken } from "../services/api";

export interface EventHost {
  id: number;
  name: string;
  blurb: string | null;
}

export interface Event {
  id: number;
  title: string;
  slug: string;
  recurrence_type: string;
  start_time: string;
  end_time: string;
  next_occurrence: string;
  chat_url: string;
  chat_platform: string;
  status: string;
  description: string | null;
  community_norms: string | null;
  window_state: string;
  host: EventHost;
  user_checked_in: boolean | null;
  checked_in_at: string | null;
  subscribed_to_host: boolean | null;
}

export interface TotemBoard {
  id: number;
  name: string;
  slug: string;
  location: string | null;
  sublocation: string | null;
  active: boolean;
  empty: boolean;
  following: boolean | null;
  active_now: Event[];
  upcoming: Event[];
}

export function useTotem(slug: string) {
  const [totem, setTotem] = useState<TotemBoard | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const token = await getToken();
      const res = await api.get<{ totem: TotemBoard }>(
        `/api/v1/totems/${slug}`,
        !!token
      );
      setTotem(res.totem);
    } catch (e: any) {
      setError(e?.body?.error ?? "Failed to load totem");
    } finally {
      setLoading(false);
    }
  }, [slug]);

  const toggleFollow = useCallback(async () => {
    if (!totem) return;
    try {
      if (totem.following) {
        await api.delete(`/api/v1/totem_follows/${totem.id}`);
        setTotem((t) => t && { ...t, following: false });
      } else {
        await api.post("/api/v1/totem_follows", { totem_id: totem.id });
        setTotem((t) => t && { ...t, following: true });
      }
    } catch {}
  }, [totem]);

  return { totem, loading, error, load, toggleFollow, setTotem };
}
