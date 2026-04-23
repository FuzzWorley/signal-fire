jest.mock("../../services/api", () => ({
  api: {
    get: jest.fn(),
    delete: jest.fn(),
  },
  getToken: jest.fn(),
  clearToken: jest.fn(),
  setToken: jest.fn(),
}));

jest.mock("../../services/auth", () => ({
  signIn: jest.fn(),
  signUp: jest.fn(),
  signOut: jest.fn(),
  signInWithGoogle: jest.fn(),
}));

import { posthog } from "../../services/analytics";

import { renderHook, act, waitFor } from "@testing-library/react-native";
import { router } from "expo-router";
import { api, getToken, clearToken } from "../../services/api";
import { signIn, signUp, signOut, signInWithGoogle } from "../../services/auth";
import { useAuth } from "../../hooks/useAuth";

const mockApi = api as jest.Mocked<typeof api>;
const mockGetToken = getToken as jest.MockedFunction<typeof getToken>;
const mockClearToken = clearToken as jest.MockedFunction<typeof clearToken>;
const mockSignIn = signIn as jest.MockedFunction<typeof signIn>;
const mockSignUp = signUp as jest.MockedFunction<typeof signUp>;
const mockSignOut = signOut as jest.MockedFunction<typeof signOut>;
const mockSignInWithGoogle = signInWithGoogle as jest.MockedFunction<typeof signInWithGoogle>;
const mockRouter = router as jest.Mocked<typeof router>;

const fakeUser = {
  id: 1,
  email: "test@example.com",
  name: "Test User",
  auth_method: "email",
  push_token: null,
  notification_prefs: {},
};

beforeEach(() => {
  jest.clearAllMocks();
});

describe("on mount", () => {
  it("loads user when token exists", async () => {
    mockGetToken.mockResolvedValueOnce("valid-token");
    mockApi.get.mockResolvedValueOnce(fakeUser);
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));
    expect(result.current.user).toEqual(fakeUser);
    // app_opened fires once per module load; this is the first test to run so the flag is false
    expect(posthog.capture).toHaveBeenCalledWith("app_opened", { authenticated: true });
    expect(posthog.identify).toHaveBeenCalledWith(String(fakeUser.id), expect.objectContaining({
      email: fakeUser.email,
    }));
  });

  it("sets user null and loading false when no token", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));
    expect(result.current.user).toBeNull();
  });

  it("clears token and sets user null when /me request fails", async () => {
    mockGetToken.mockResolvedValueOnce("expired-token");
    mockApi.get.mockRejectedValueOnce({ status: 401 });
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));
    expect(result.current.user).toBeNull();
    expect(mockClearToken).toHaveBeenCalled();
  });
});

describe("signUp", () => {
  it("sets user and redirects to app home", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    mockSignUp.mockResolvedValueOnce({ token: "jwt", user: fakeUser });
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.signUp("test@example.com", "password");
    });

    expect(result.current.user).toEqual(fakeUser);
    expect(mockRouter.replace).toHaveBeenCalledWith("/(app)/");
  });
});

describe("signIn", () => {
  it("sets user and redirects to app home", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    mockSignIn.mockResolvedValueOnce({ token: "jwt", user: fakeUser });
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.signIn("test@example.com", "password");
    });

    expect(result.current.user).toEqual(fakeUser);
    expect(mockRouter.replace).toHaveBeenCalledWith("/(app)/");
  });
});

describe("signInWithGoogle", () => {
  it("sets user and redirects to app home", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    mockSignInWithGoogle.mockResolvedValueOnce({ token: "jwt", user: fakeUser });
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.signInWithGoogle("google-id-token");
    });

    expect(result.current.user).toEqual(fakeUser);
    expect(mockRouter.replace).toHaveBeenCalledWith("/(app)/");
  });
});

describe("signOut", () => {
  it("clears user and redirects to welcome", async () => {
    mockGetToken.mockResolvedValueOnce("token");
    mockApi.get.mockResolvedValueOnce(fakeUser);
    mockSignOut.mockResolvedValueOnce(undefined);
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.signOut();
    });

    expect(result.current.user).toBeNull();
    expect(mockRouter.replace).toHaveBeenCalledWith("/(auth)/welcome");
  });
});

describe("deleteAccount", () => {
  it("calls DELETE /me, clears token, redirects to welcome", async () => {
    mockGetToken.mockResolvedValueOnce("token");
    mockApi.get.mockResolvedValueOnce(fakeUser);
    mockApi.delete.mockResolvedValueOnce(undefined);
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.deleteAccount();
    });

    expect(mockApi.delete).toHaveBeenCalledWith("/api/v1/me");
    expect(mockClearToken).toHaveBeenCalled();
    expect(result.current.user).toBeNull();
    expect(mockRouter.replace).toHaveBeenCalledWith("/(auth)/welcome");
  });
});

describe("useAuth — analytics", () => {
  it("identifies user on signUp", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    mockSignUp.mockResolvedValueOnce({ token: "jwt", user: fakeUser });
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.signUp("test@example.com", "password");
    });

    expect(posthog.identify).toHaveBeenCalledWith(String(fakeUser.id), {
      email: fakeUser.email,
      auth_method: fakeUser.auth_method,
      is_host: fakeUser.is_host,
    });
  });

  it("identifies user on signIn", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    mockSignIn.mockResolvedValueOnce({ token: "jwt", user: fakeUser });
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.signIn("test@example.com", "password");
    });

    expect(posthog.identify).toHaveBeenCalledWith(String(fakeUser.id), {
      email: fakeUser.email,
      auth_method: fakeUser.auth_method,
      is_host: fakeUser.is_host,
    });
  });

  it("identifies user on signInWithGoogle", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    mockSignInWithGoogle.mockResolvedValueOnce({ token: "jwt", user: fakeUser });
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.signInWithGoogle("google-id-token");
    });

    expect(posthog.identify).toHaveBeenCalledWith(String(fakeUser.id), {
      email: fakeUser.email,
      auth_method: fakeUser.auth_method,
      is_host: fakeUser.is_host,
    });
  });

  it("calls posthog.reset on signOut", async () => {
    mockGetToken.mockResolvedValueOnce("token");
    mockApi.get.mockResolvedValueOnce(fakeUser);
    mockSignOut.mockResolvedValueOnce(undefined);
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.signOut();
    });

    expect(posthog.reset).toHaveBeenCalled();
  });

  it("calls posthog.reset on deleteAccount", async () => {
    mockGetToken.mockResolvedValueOnce("token");
    mockApi.get.mockResolvedValueOnce(fakeUser);
    mockApi.delete.mockResolvedValueOnce(undefined);
    const { result } = renderHook(() => useAuth());
    await waitFor(() => expect(result.current.loading).toBe(false));

    await act(async () => {
      await result.current.deleteAccount();
    });

    expect(posthog.reset).toHaveBeenCalled();
  });
});

