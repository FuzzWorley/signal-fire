import { useState, useEffect, useCallback } from "react";
import { router } from "expo-router";
import * as SecureStore from "expo-secure-store";
import { api, clearToken, getToken, setToken } from "../services/api";
import { signIn, signUp, signOut, signInWithGoogle, CurrentUser } from "../services/auth";

const TOKEN_KEY = "signal_fire_jwt";

interface AuthState {
  user: CurrentUser | null;
  loading: boolean;
}

export function useAuth() {
  const [state, setState] = useState<AuthState>({ user: null, loading: true });

  const loadUser = useCallback(async () => {
    const token = await getToken();
    if (!token) {
      setState({ user: null, loading: false });
      return;
    }
    try {
      const user = await api.get<CurrentUser>("/api/v1/me");
      setState({ user, loading: false });
    } catch {
      await clearToken();
      setState({ user: null, loading: false });
    }
  }, []);

  useEffect(() => {
    loadUser();
  }, [loadUser]);

  const handleSignUp = useCallback(async (email: string, password: string) => {
    const res = await signUp(email, password);
    setState({ user: res.user, loading: false });
    router.replace("/(app)/");
  }, []);

  const handleSignIn = useCallback(async (email: string, password: string) => {
    const res = await signIn(email, password);
    setState({ user: res.user, loading: false });
    router.replace("/(app)/");
  }, []);

  const handleGoogleSignIn = useCallback(async (idToken: string) => {
    const res = await signInWithGoogle(idToken);
    setState({ user: res.user, loading: false });
    router.replace("/(app)/");
  }, []);

  const handleSignOut = useCallback(async () => {
    await signOut();
    setState({ user: null, loading: false });
    router.replace("/(auth)/welcome");
  }, []);

  const handleDeleteAccount = useCallback(async () => {
    await api.delete("/api/v1/me");
    await clearToken();
    setState({ user: null, loading: false });
    router.replace("/(auth)/welcome");
  }, []);

  const refreshUser = useCallback(async () => {
    try {
      const user = await api.get<CurrentUser>("/api/v1/me");
      setState((prev) => ({ ...prev, user }));
    } catch {}
  }, []);

  return {
    user: state.user,
    loading: state.loading,
    signUp: handleSignUp,
    signIn: handleSignIn,
    signInWithGoogle: handleGoogleSignIn,
    signOut: handleSignOut,
    deleteAccount: handleDeleteAccount,
    refreshUser,
  };
}
