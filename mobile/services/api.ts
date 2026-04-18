import * as SecureStore from "expo-secure-store";
import { Platform } from "react-native";

const BASE_URL = process.env.EXPO_PUBLIC_API_URL ?? "http://localhost:3000";
const TOKEN_KEY = "signal_fire_jwt";

export async function getToken(): Promise<string | null> {
  if (Platform.OS === "web") return localStorage.getItem(TOKEN_KEY);
  return SecureStore.getItemAsync(TOKEN_KEY);
}

export async function setToken(token: string): Promise<void> {
  if (Platform.OS === "web") { localStorage.setItem(TOKEN_KEY, token); return; }
  return SecureStore.setItemAsync(TOKEN_KEY, token);
}

export async function clearToken(): Promise<void> {
  if (Platform.OS === "web") { localStorage.removeItem(TOKEN_KEY); return; }
  return SecureStore.deleteItemAsync(TOKEN_KEY);
}

async function authHeaders(): Promise<Record<string, string>> {
  const token = await getToken();
  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function request<T>(
  path: string,
  options: RequestInit = {},
  authenticated = true
): Promise<T> {
  const headers: Record<string, string> = {
    "Content-Type": "application/json",
    Accept: "application/json",
    ...(options.headers as Record<string, string>),
  };

  if (authenticated) {
    const auth = await authHeaders();
    Object.assign(headers, auth);
  }

  const res = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers,
  });

  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw { status: res.status, body };
  }

  if (res.status === 204) return undefined as T;
  return res.json();
}

export const api = {
  get: <T>(path: string, authenticated = true) =>
    request<T>(path, { method: "GET" }, authenticated),

  post: <T>(path: string, body: unknown, authenticated = true) =>
    request<T>(path, { method: "POST", body: JSON.stringify(body) }, authenticated),

  patch: <T>(path: string, body: unknown, authenticated = true) =>
    request<T>(path, { method: "PATCH", body: JSON.stringify(body) }, authenticated),

  delete: <T>(path: string, authenticated = true) =>
    request<T>(path, { method: "DELETE" }, authenticated),
};
