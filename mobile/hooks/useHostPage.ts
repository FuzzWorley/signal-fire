import { useState, useCallback } from "react";
import { api, getToken } from "../services/api";

export interface HostTotem {
  name: string;
  slug: string;
  neighborhood: string | null;
}

export interface HostEvent {
  id: number;
  title: string;
  slug: string;
  start_time: string;
  end_time: string;
  next_occurrence: string;
  recurrence_label: string | null;
  host: {
    id: number;
    slug: string | null;
    name: string;
    blurb: string | null;
  };
}

export interface HostPage {
  slug: string;
  host_user_id: number;
  display_name: string;
  host_story: string | null;
  following: boolean;
  host_follow_id: number | null;
  upcoming_events: HostEvent[];
  totems: HostTotem[];
}

export function useHostPage(slug: string) {
  const [host, setHost] = useState<HostPage | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const load = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const token = await getToken();
      const res = await api.get<{ host: HostPage }>(
        `/api/v1/hosts/${slug}`,
        !!token
      );
      setHost(res.host);
    } catch (e: any) {
      setError(e?.body?.error ?? "Failed to load host page");
    } finally {
      setLoading(false);
    }
  }, [slug]);

  const toggleFollow = useCallback(async (following: boolean, hostFollowId: number | null) => {
    if (!host) return;
    try {
      if (following) {
        const res = await api.post<{ id: number }>("/api/v1/host_follows", {
          host_user_id: host.host_user_id,
        });
        setHost((h) => h && { ...h, following: true, host_follow_id: res.id });
      } else if (hostFollowId) {
        await api.delete(`/api/v1/host_follows/${hostFollowId}`);
        setHost((h) => h && { ...h, following: false, host_follow_id: null });
      }
    } catch {}
  }, [host]);

  return { host, loading, error, load, toggleFollow, setHost };
}
