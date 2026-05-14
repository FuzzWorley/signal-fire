import { useState, useCallback } from "react";
import { api } from "../services/api";

export interface TotemFollow {
  id: number;
  totem_id: number;
  totem_name: string;
  totem_slug: string;
  notify_new_event: boolean;
  notify_reminder: boolean;
}

export interface HostFollow {
  id: number;
  host_user_id: number;
  host_name: string;
  notify_new_event: boolean;
  notify_reminder: boolean;
}

interface SubscriptionsResponse {
  totem_favorites: TotemFollow[];
  host_follows: HostFollow[];
}

export function useSubscriptions() {
  const [follows, setFollows] = useState<TotemFollow[]>([]);
  const [hostFollows, setHostFollows] = useState<HostFollow[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await api.get<SubscriptionsResponse>("/api/v1/me/subscriptions");
      setFollows(res.totem_favorites ?? []);
      setHostFollows(res.host_follows ?? []);
    } catch {}
    finally {
      setLoading(false);
    }
  }, []);

  const unfollow = useCallback(async (favoriteId: number) => {
    await api.delete(`/api/v1/totem_favorites/${favoriteId}`);
    setFollows((prev) => prev.filter((f) => f.id !== favoriteId));
  }, []);

  const unfollowHost = useCallback(async (followId: number) => {
    await api.delete(`/api/v1/host_follows/${followId}`);
    setHostFollows((prev) => prev.filter((s) => s.id !== followId));
  }, []);

  const updateFollow = useCallback(
    async (id: number, prefs: Partial<Pick<TotemFollow, "notify_new_event" | "notify_reminder">>) => {
      await api.patch(`/api/v1/totem_favorites/${id}`, prefs);
      setFollows((prev) => prev.map((f) => (f.id === id ? { ...f, ...prefs } : f)));
    },
    []
  );

  const updateHostFollow = useCallback(
    async (id: number, prefs: Partial<Pick<HostFollow, "notify_new_event" | "notify_reminder">>) => {
      await api.patch(`/api/v1/host_follows/${id}`, prefs);
      setHostFollows((prev) => prev.map((s) => (s.id === id ? { ...s, ...prefs } : s)));
    },
    []
  );

  return {
    follows,
    hostFollows,
    loading,
    load,
    unfollow,
    unfollowHost,
    updateFollow,
    updateHostFollow,
  };
}
