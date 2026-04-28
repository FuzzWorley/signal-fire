import { useState, useEffect, useCallback } from "react";
import { Platform } from "react-native";
import { router } from "expo-router";
import * as Notifications from "expo-notifications";
import Constants from "expo-constants";
import { api, clearToken, getToken } from "../services/api";
import { signIn, signUp, signOut, signInWithGoogle, CurrentUser } from "../services/auth";
import { posthog } from "../services/analytics";

async function syncPushToken(user: CurrentUser) {
  if (Platform.OS === "web") return;
  try {
    const { status } = await Notifications.getPermissionsAsync();
    if (status !== "granted") return;
    const token = await Notifications.getExpoPushTokenAsync({
      projectId: Constants.expoConfig?.extra?.eas?.projectId,
    });
    if (token.data !== user.push_token) {
      await api.post("/api/v1/me/push_token", { push_token: token.data });
    }
  } catch {}
}

const TOKEN_KEY = "signal_fire_jwt";

// Fired once per app session regardless of how many components call useAuth.
let _appOpenedFired = false;

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
      if (!_appOpenedFired) {
        _appOpenedFired = true;
        posthog.capture("app_opened", { authenticated: false });
      }
      return;
    }
    try {
      const user = await api.get<CurrentUser>("/api/v1/me");
      setState({ user, loading: false });
      syncPushToken(user);
      if (!_appOpenedFired) {
        _appOpenedFired = true;
        posthog.capture("app_opened", { authenticated: true });
        posthog.identify(String(user.id), {
          email: user.email,
          auth_method: user.auth_method,
          is_host: user.is_host,
        });
      }
    } catch {
      await clearToken();
      setState({ user: null, loading: false });
      if (!_appOpenedFired) {
        _appOpenedFired = true;
        posthog.capture("app_opened", { authenticated: false });
      }
    }
  }, []);

  useEffect(() => {
    loadUser();
  }, [loadUser]);

  const handleSignUp = useCallback(async (email: string, password: string) => {
    const res = await signUp(email, password);
    setState({ user: res.user, loading: false });
    posthog.identify(String(res.user.id), {
      email: res.user.email,
      auth_method: res.user.auth_method,
      is_host: res.user.is_host,
    });
    router.replace("/(app)/");
  }, []);

  const handleSignIn = useCallback(async (email: string, password: string) => {
    const res = await signIn(email, password);
    setState({ user: res.user, loading: false });
    posthog.identify(String(res.user.id), {
      email: res.user.email,
      auth_method: res.user.auth_method,
      is_host: res.user.is_host,
    });
    router.replace("/(app)/");
  }, []);

  const handleGoogleSignIn = useCallback(async (idToken: string) => {
    const res = await signInWithGoogle(idToken);
    setState({ user: res.user, loading: false });
    posthog.identify(String(res.user.id), {
      email: res.user.email,
      auth_method: res.user.auth_method,
      is_host: res.user.is_host,
    });
    router.replace("/(app)/");
  }, []);

  const handleSignOut = useCallback(async () => {
    await signOut();
    posthog.reset();
    setState({ user: null, loading: false });
    router.replace("/(auth)/welcome");
  }, []);

  const handleDeleteAccount = useCallback(async () => {
    await api.delete("/api/v1/me");
    await clearToken();
    posthog.reset();
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
