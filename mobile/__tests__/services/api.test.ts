import * as SecureStore from "expo-secure-store";
import { getToken, setToken, clearToken, api } from "../../services/api";

const mockSecureStore = SecureStore as jest.Mocked<typeof SecureStore>;

function mockFetch(status: number, body: unknown) {
  (global.fetch as jest.Mock).mockResolvedValueOnce({
    ok: status >= 200 && status < 300,
    status,
    json: () => Promise.resolve(body),
  });
}

beforeEach(() => {
  mockSecureStore.getItemAsync.mockReset();
  mockSecureStore.setItemAsync.mockReset();
  mockSecureStore.deleteItemAsync.mockReset();
});

describe("getToken", () => {
  it("reads from SecureStore on native", async () => {
    mockSecureStore.getItemAsync.mockResolvedValueOnce("my-jwt");
    expect(await getToken()).toBe("my-jwt");
    expect(mockSecureStore.getItemAsync).toHaveBeenCalledWith("signal_fire_jwt");
  });

  it("returns null when no token stored", async () => {
    mockSecureStore.getItemAsync.mockResolvedValueOnce(null);
    expect(await getToken()).toBeNull();
  });
});

describe("setToken", () => {
  it("writes to SecureStore", async () => {
    mockSecureStore.setItemAsync.mockResolvedValueOnce(undefined);
    await setToken("abc123");
    expect(mockSecureStore.setItemAsync).toHaveBeenCalledWith("signal_fire_jwt", "abc123");
  });
});

describe("clearToken", () => {
  it("deletes from SecureStore", async () => {
    mockSecureStore.deleteItemAsync.mockResolvedValueOnce(undefined);
    await clearToken();
    expect(mockSecureStore.deleteItemAsync).toHaveBeenCalledWith("signal_fire_jwt");
  });
});

describe("api.get", () => {
  it("makes a GET request with auth headers", async () => {
    mockSecureStore.getItemAsync.mockResolvedValueOnce("my-token");
    mockFetch(200, { hello: "world" });
    const result = await api.get("/api/v1/test");
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining("/api/v1/test"),
      expect.objectContaining({
        method: "GET",
        headers: expect.objectContaining({ Authorization: "Bearer my-token" }),
      })
    );
    expect(result).toEqual({ hello: "world" });
  });

  it("omits auth header when authenticated=false", async () => {
    mockFetch(200, {});
    await api.get("/api/v1/public", false);
    const call = (global.fetch as jest.Mock).mock.calls[0];
    expect(call[1].headers.Authorization).toBeUndefined();
  });
});

describe("api.post", () => {
  it("makes a POST request with JSON body", async () => {
    mockSecureStore.getItemAsync.mockResolvedValueOnce("tok");
    mockFetch(201, { id: 1 });
    const result = await api.post("/api/v1/things", { name: "test" });
    expect(global.fetch).toHaveBeenCalledWith(
      expect.stringContaining("/api/v1/things"),
      expect.objectContaining({
        method: "POST",
        body: JSON.stringify({ name: "test" }),
      })
    );
    expect(result).toEqual({ id: 1 });
  });
});

describe("api.patch", () => {
  it("makes a PATCH request with JSON body", async () => {
    mockSecureStore.getItemAsync.mockResolvedValueOnce("tok");
    mockFetch(200, { updated: true });
    await api.patch("/api/v1/things/1", { name: "new" });
    const call = (global.fetch as jest.Mock).mock.calls[0];
    expect(call[1].method).toBe("PATCH");
    expect(call[1].body).toBe(JSON.stringify({ name: "new" }));
  });
});

describe("api.delete", () => {
  it("makes a DELETE request", async () => {
    mockSecureStore.getItemAsync.mockResolvedValueOnce("tok");
    (global.fetch as jest.Mock).mockResolvedValueOnce({ ok: true, status: 204 });
    await api.delete("/api/v1/things/1");
    const call = (global.fetch as jest.Mock).mock.calls[0];
    expect(call[1].method).toBe("DELETE");
  });

  it("returns undefined for 204 No Content", async () => {
    mockSecureStore.getItemAsync.mockResolvedValueOnce("tok");
    (global.fetch as jest.Mock).mockResolvedValueOnce({ ok: true, status: 204 });
    const result = await api.delete("/api/v1/things/1");
    expect(result).toBeUndefined();
  });
});

describe("error handling", () => {
  it("throws { status, body } on non-ok response", async () => {
    mockSecureStore.getItemAsync.mockResolvedValueOnce("tok");
    (global.fetch as jest.Mock).mockResolvedValueOnce({
      ok: false,
      status: 422,
      json: () => Promise.resolve({ error: "Invalid" }),
    });
    await expect(api.post("/api/v1/fail", {})).rejects.toMatchObject({
      status: 422,
      body: { error: "Invalid" },
    });
  });
});
