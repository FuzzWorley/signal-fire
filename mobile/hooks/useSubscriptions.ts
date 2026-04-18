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

export interface HostSubscription {
  id: number;
  host_user_id: number;
  host_name: string;
  notify_new_event: boolean;
  notify_reminder: boolean;
}

interface SubscriptionsResponse {
  totem_follows: TotemFollow[];
  host_subscriptions: HostSubscription[];
}

export function useSubscriptions() {
  const [follows, setFollows] = useState<TotemFollow[]>([]);
  const [subscriptions, setSubscriptions] = useState<HostSubscription[]>([]);
  const [loading, setLoading] = useState(true);

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const res = await api.get<SubscriptionsResponse>("/api/v1/me/subscriptions");
      setFollows(res.totem_follows);
      setSubscriptions(res.host_subscriptions);
    } catch {}
    finally {
      setLoading(false);
    }
  }, []);

  const unfollow = useCallback(async (totemId: number) => {
    await api.delete(`/api/v1/totem_follows/${totemId}`);
    setFollows((prev) => prev.filter((f) => f.totem_id !== totemId));
  }, []);

  const unsubscribe = useCallback(async (hostUserId: number) => {
    await api.delete(`/api/v1/host_subscriptions/${hostUserId}`);
    setSubscriptions((prev) => prev.filter((s) => s.host_user_id !== hostUserId));
  }, []);

  const updateFollow = useCallback(
    async (id: number, prefs: Partial<Pick<TotemFollow, "notify_new_event" | "notify_reminder">>) => {
      await api.patch(`/api/v1/totem_follows/${id}`, prefs);
      setFollows((prev) => prev.map((f) => (f.id === id ? { ...f, ...prefs } : f)));
    },
    []
  );

  const updateSubscription = useCallback(
    async (id: number, prefs: Partial<Pick<HostSubscription, "notify_new_event" | "notify_reminder">>) => {
      await api.patch(`/api/v1/host_subscriptions/${id}`, prefs);
      setSubscriptions((prev) => prev.map((s) => (s.id === id ? { ...s, ...prefs } : s)));
    },
    []
  );

  return {
    follows,
    subscriptions,
    loading,
    load,
    unfollow,
    unsubscribe,
    updateFollow,
    updateSubscription,
  };
}
