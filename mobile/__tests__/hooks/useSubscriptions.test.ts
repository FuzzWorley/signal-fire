jest.mock("../../services/api", () => ({
  api: {
    get: jest.fn(),
    patch: jest.fn(),
    delete: jest.fn(),
  },
}));

import { renderHook, act } from "@testing-library/react-native";
import { api } from "../../services/api";
import { useSubscriptions } from "../../hooks/useSubscriptions";

const mockApi = api as jest.Mocked<typeof api>;

const follow1 = {
  id: 1,
  totem_id: 10,
  totem_name: "Waterfront North",
  totem_slug: "waterfront-north",
  notify_new_event: true,
  notify_reminder: false,
};

const follow2 = {
  id: 2,
  totem_id: 20,
  totem_name: "Williams Park",
  totem_slug: "williams-park",
  notify_new_event: false,
  notify_reminder: true,
};

const sub1 = {
  id: 1,
  host_user_id: 100,
  host_name: "Maria Santos",
  notify_new_event: true,
  notify_reminder: true,
};

beforeEach(() => {
  jest.clearAllMocks();
});

describe("load", () => {
  it("fetches and sets follows and subscriptions", async () => {
    mockApi.get.mockResolvedValueOnce({
      totem_follows: [follow1, follow2],
      host_subscriptions: [sub1],
    });
    const { result } = renderHook(() => useSubscriptions());
    await act(async () => {
      await result.current.load();
    });
    expect(result.current.follows).toEqual([follow1, follow2]);
    expect(result.current.subscriptions).toEqual([sub1]);
    expect(result.current.loading).toBe(false);
  });

  it("leaves state empty on error", async () => {
    mockApi.get.mockRejectedValueOnce(new Error("Network error"));
    const { result } = renderHook(() => useSubscriptions());
    await act(async () => {
      await result.current.load();
    });
    expect(result.current.follows).toEqual([]);
    expect(result.current.subscriptions).toEqual([]);
    expect(result.current.loading).toBe(false);
  });
});

describe("unfollow", () => {
  it("DELETEs by totem_id and removes from state", async () => {
    mockApi.get.mockResolvedValueOnce({
      totem_follows: [follow1, follow2],
      host_subscriptions: [],
    });
    mockApi.delete.mockResolvedValueOnce(undefined);
    const { result } = renderHook(() => useSubscriptions());
    await act(async () => {
      await result.current.load();
    });
    await act(async () => {
      await result.current.unfollow(follow1.totem_id);
    });
    expect(mockApi.delete).toHaveBeenCalledWith("/api/v1/totem_follows/10");
    expect(result.current.follows).toEqual([follow2]);
  });
});

describe("unsubscribe", () => {
  it("DELETEs by host_user_id and removes from state", async () => {
    mockApi.get.mockResolvedValueOnce({
      totem_follows: [],
      host_subscriptions: [sub1],
    });
    mockApi.delete.mockResolvedValueOnce(undefined);
    const { result } = renderHook(() => useSubscriptions());
    await act(async () => {
      await result.current.load();
    });
    await act(async () => {
      await result.current.unsubscribe(sub1.host_user_id);
    });
    expect(mockApi.delete).toHaveBeenCalledWith("/api/v1/host_subscriptions/100");
    expect(result.current.subscriptions).toEqual([]);
  });
});

describe("updateFollow", () => {
  it("PATCHes and updates the follow in state", async () => {
    mockApi.get.mockResolvedValueOnce({
      totem_follows: [follow1],
      host_subscriptions: [],
    });
    mockApi.patch.mockResolvedValueOnce(undefined);
    const { result } = renderHook(() => useSubscriptions());
    await act(async () => {
      await result.current.load();
    });
    await act(async () => {
      await result.current.updateFollow(1, { notify_new_event: false });
    });
    expect(mockApi.patch).toHaveBeenCalledWith(
      "/api/v1/totem_follows/1",
      { notify_new_event: false }
    );
    expect(result.current.follows[0].notify_new_event).toBe(false);
  });
});

describe("updateSubscription", () => {
  it("PATCHes and updates the subscription in state", async () => {
    mockApi.get.mockResolvedValueOnce({
      totem_follows: [],
      host_subscriptions: [sub1],
    });
    mockApi.patch.mockResolvedValueOnce(undefined);
    const { result } = renderHook(() => useSubscriptions());
    await act(async () => {
      await result.current.load();
    });
    await act(async () => {
      await result.current.updateSubscription(1, { notify_reminder: false });
    });
    expect(mockApi.patch).toHaveBeenCalledWith(
      "/api/v1/host_subscriptions/1",
      { notify_reminder: false }
    );
    expect(result.current.subscriptions[0].notify_reminder).toBe(false);
  });
});
