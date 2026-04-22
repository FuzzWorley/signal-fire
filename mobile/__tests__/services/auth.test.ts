jest.mock("../../services/api", () => ({
  api: {
    post: jest.fn(),
    delete: jest.fn(),
  },
  setToken: jest.fn(),
  clearToken: jest.fn(),
  getToken: jest.fn(),
}));

import { api, setToken, clearToken } from "../../services/api";
import { signUp, signIn, signInWithGoogle, signOut } from "../../services/auth";

const mockApi = api as jest.Mocked<typeof api>;
const mockSetToken = setToken as jest.MockedFunction<typeof setToken>;
const mockClearToken = clearToken as jest.MockedFunction<typeof clearToken>;

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

describe("signUp", () => {
  it("POSTs to /api/v1/auth/sign_up and stores token", async () => {
    mockApi.post.mockResolvedValueOnce({ token: "jwt-abc", user: fakeUser });
    const result = await signUp("test@example.com", "password");
    expect(mockApi.post).toHaveBeenCalledWith(
      "/api/v1/auth/sign_up",
      { email: "test@example.com", password: "password" },
      false
    );
    expect(mockSetToken).toHaveBeenCalledWith("jwt-abc");
    expect(result.user).toEqual(fakeUser);
  });
});

describe("signIn", () => {
  it("POSTs to /api/v1/auth/sign_in and stores token", async () => {
    mockApi.post.mockResolvedValueOnce({ token: "jwt-xyz", user: fakeUser });
    const result = await signIn("test@example.com", "password");
    expect(mockApi.post).toHaveBeenCalledWith(
      "/api/v1/auth/sign_in",
      { email: "test@example.com", password: "password" },
      false
    );
    expect(mockSetToken).toHaveBeenCalledWith("jwt-xyz");
    expect(result.token).toBe("jwt-xyz");
  });
});

describe("signInWithGoogle", () => {
  it("POSTs to /api/v1/auth/google with id_token and stores token", async () => {
    mockApi.post.mockResolvedValueOnce({ token: "google-jwt", user: fakeUser });
    await signInWithGoogle("google-id-token-123");
    expect(mockApi.post).toHaveBeenCalledWith(
      "/api/v1/auth/google",
      { id_token: "google-id-token-123" },
      false
    );
    expect(mockSetToken).toHaveBeenCalledWith("google-jwt");
  });
});

describe("signOut", () => {
  it("calls DELETE /api/v1/auth/sign_out and clears token", async () => {
    mockApi.delete.mockResolvedValueOnce(undefined);
    await signOut();
    expect(mockApi.delete).toHaveBeenCalledWith("/api/v1/auth/sign_out");
    expect(mockClearToken).toHaveBeenCalled();
  });

  it("still clears token even if DELETE request fails", async () => {
    mockApi.delete.mockRejectedValueOnce(new Error("Network error"));
    await signOut();
    expect(mockClearToken).toHaveBeenCalled();
  });
});
