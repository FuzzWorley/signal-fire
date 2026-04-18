import { useState, useCallback } from "react";
import { api } from "../services/api";

interface CheckInResult {
  checked_in: boolean;
  checked_in_at: string;
}

export function useCheckin(eventId: number) {
  const [checkedIn, setCheckedIn] = useState(false);
  const [checkedInAt, setCheckedInAt] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const checkIn = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await api.post<CheckInResult>(
        `/api/v1/events/${eventId}/check_ins`,
        {}
      );
      setCheckedIn(true);
      setCheckedInAt(res.checked_in_at);
    } catch (e: any) {
      setError(e?.body?.error ?? "Check-in failed");
    } finally {
      setLoading(false);
    }
  }, [eventId]);

  return { checkedIn, checkedInAt, loading, error, checkIn, setCheckedIn, setCheckedInAt };
}
