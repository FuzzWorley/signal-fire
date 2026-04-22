jest.mock("../../services/api", () => ({
  api: {
    post: jest.fn(),
  },
}));

import { renderHook, act, waitFor } from "@testing-library/react-native";
import { api } from "../../services/api";
import { useCheckin } from "../../hooks/useCheckin";

const mockApi = api as jest.Mocked<typeof api>;

beforeEach(() => {
  jest.clearAllMocks();
});

describe("initial state", () => {
  it("starts unchecked, not loading, no error", () => {
    const { result } = renderHook(() => useCheckin(42));
    expect(result.current.checkedIn).toBe(false);
    expect(result.current.loading).toBe(false);
    expect(result.current.error).toBeNull();
    expect(result.current.checkedInAt).toBeNull();
  });
});

describe("checkIn", () => {
  it("POSTs to the correct endpoint", async () => {
    mockApi.post.mockResolvedValueOnce({
      checked_in: true,
      checked_in_at: "2026-04-21T10:00:00Z",
    });
    const { result } = renderHook(() => useCheckin(42));

    await act(async () => {
      await result.current.checkIn();
    });

    expect(mockApi.post).toHaveBeenCalledWith("/api/v1/events/42/check_ins", {});
  });

  it("sets checkedIn and checkedInAt on success", async () => {
    mockApi.post.mockResolvedValueOnce({
      checked_in: true,
      checked_in_at: "2026-04-21T10:00:00Z",
    });
    const { result } = renderHook(() => useCheckin(5));

    await act(async () => {
      await result.current.checkIn();
    });

    expect(result.current.checkedIn).toBe(true);
    expect(result.current.checkedInAt).toBe("2026-04-21T10:00:00Z");
    expect(result.current.error).toBeNull();
  });

  it("sets error on failure", async () => {
    mockApi.post.mockRejectedValueOnce({ body: { error: "Check-in window closed" } });
    const { result } = renderHook(() => useCheckin(5));

    await act(async () => {
      await result.current.checkIn();
    });

    expect(result.current.checkedIn).toBe(false);
    expect(result.current.error).toBe("Check-in window closed");
  });

  it("clears loading after failure", async () => {
    mockApi.post.mockRejectedValueOnce({ body: { error: "Oops" } });
    const { result } = renderHook(() => useCheckin(5));

    await act(async () => {
      await result.current.checkIn();
    });

    expect(result.current.loading).toBe(false);
  });
});
