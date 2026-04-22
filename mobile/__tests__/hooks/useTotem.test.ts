jest.mock("../../services/api", () => ({
  api: {
    get: jest.fn(),
    post: jest.fn(),
    delete: jest.fn(),
  },
  getToken: jest.fn(),
}));

import { renderHook, act } from "@testing-library/react-native";
import { api, getToken } from "../../services/api";
import { useTotem } from "../../hooks/useTotem";

const mockApi = api as jest.Mocked<typeof api>;
const mockGetToken = getToken as jest.MockedFunction<typeof getToken>;

const baseTotem = {
  id: 1,
  name: "Waterfront North",
  slug: "waterfront-north",
  location: "St. Petersburg",
  sublocation: null,
  active: true,
  empty: false,
  following: false,
  active_now: [],
  upcoming: [],
};

beforeEach(() => {
  jest.clearAllMocks();
  mockGetToken.mockResolvedValue("token");
});

describe("load", () => {
  it("fetches the totem and sets state", async () => {
    mockApi.get.mockResolvedValueOnce({ totem: baseTotem });
    const { result } = renderHook(() => useTotem("waterfront-north"));
    await act(async () => {
      await result.current.load();
    });
    expect(result.current.totem).toEqual(baseTotem);
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
  });

  it("sets error when fetch fails", async () => {
    mockApi.get.mockRejectedValueOnce({ body: { error: "Not found" } });
    const { result } = renderHook(() => useTotem("bad-slug"));
    await act(async () => {
      await result.current.load();
    });
    expect(result.current.totem).toBeNull();
    expect(result.current.error).toBe("Not found");
    expect(result.current.loading).toBe(false);
  });

  it("uses unauthenticated request when no token", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    mockApi.get.mockResolvedValueOnce({ totem: { ...baseTotem, following: null } });
    const { result } = renderHook(() => useTotem("waterfront-north"));
    await act(async () => {
      await result.current.load();
    });
    expect(mockApi.get).toHaveBeenCalledWith(
      "/api/v1/totems/waterfront-north",
      false
    );
  });
});

describe("toggleFollow", () => {
  it("POSTs to totem_follows when not following", async () => {
    mockApi.get.mockResolvedValueOnce({ totem: { ...baseTotem, following: false } });
    mockApi.post.mockResolvedValueOnce({ id: 10, totem_id: 1 });
    const { result } = renderHook(() => useTotem("waterfront-north"));
    await act(async () => {
      await result.current.load();
    });
    await act(async () => {
      await result.current.toggleFollow();
    });
    expect(mockApi.post).toHaveBeenCalledWith("/api/v1/totem_follows", { totem_id: 1 });
    expect(result.current.totem?.following).toBe(true);
  });

  it("DELETEs from totem_follows when already following", async () => {
    mockApi.get.mockResolvedValueOnce({ totem: { ...baseTotem, following: true } });
    mockApi.delete.mockResolvedValueOnce(undefined);
    const { result } = renderHook(() => useTotem("waterfront-north"));
    await act(async () => {
      await result.current.load();
    });
    await act(async () => {
      await result.current.toggleFollow();
    });
    expect(mockApi.delete).toHaveBeenCalledWith("/api/v1/totem_follows/1");
    expect(result.current.totem?.following).toBe(false);
  });

  it("does nothing when totem is null", async () => {
    const { result } = renderHook(() => useTotem("bad-slug"));
    await act(async () => {
      await result.current.toggleFollow();
    });
    expect(mockApi.post).not.toHaveBeenCalled();
    expect(mockApi.delete).not.toHaveBeenCalled();
  });
});
