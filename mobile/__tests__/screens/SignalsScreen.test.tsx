jest.mock("../../hooks/useSubscriptions", () => ({
  useSubscriptions: jest.fn(),
}));

import React from "react";
import { render, screen, fireEvent, waitFor, act } from "@testing-library/react-native";
import { useSubscriptions } from "../../hooks/useSubscriptions";
import SignalsScreen from "../../app/(app)/signals";

const mockUseSubscriptions = useSubscriptions as jest.MockedFunction<typeof useSubscriptions>;

const follow = {
  id: 1,
  totem_id: 10,
  totem_name: "Waterfront North",
  totem_slug: "waterfront-north",
  notify_new_event: true,
  notify_reminder: false,
};

const sub = {
  id: 1,
  host_user_id: 100,
  host_name: "Maria Santos",
  notify_new_event: true,
  notify_reminder: true,
};

const defaultHook = {
  follows: [],
  subscriptions: [],
  loading: false,
  load: jest.fn(),
  unfollow: jest.fn(),
  unsubscribe: jest.fn(),
  updateFollow: jest.fn(),
  updateSubscription: jest.fn(),
};

beforeEach(() => {
  jest.clearAllMocks();
  mockUseSubscriptions.mockReturnValue({ ...defaultHook });
});

describe("SignalsScreen", () => {
  it("shows loading indicator initially", () => {
    mockUseSubscriptions.mockReturnValueOnce({ ...defaultHook, loading: true });
    render(<SignalsScreen />);
    expect(screen.UNSAFE_getByType(require("react-native").ActivityIndicator)).toBeTruthy();
  });

  it("shows empty state when no follows or subscriptions", () => {
    render(<SignalsScreen />);
    expect(screen.getByText(/Follow totems and subscribe to hosts/)).toBeTruthy();
  });

  it("shows followed totems section", () => {
    mockUseSubscriptions.mockReturnValueOnce({ ...defaultHook, follows: [follow] });
    render(<SignalsScreen />);
    expect(screen.getByText("FOLLOWED TOTEMS · 1")).toBeTruthy();
    expect(screen.getByText("Waterfront North")).toBeTruthy();
  });

  it("shows subscribed hosts section", () => {
    mockUseSubscriptions.mockReturnValueOnce({ ...defaultHook, subscriptions: [sub] });
    render(<SignalsScreen />);
    expect(screen.getByText("SUBSCRIBED HOSTS · 1")).toBeTruthy();
    expect(screen.getByText("Maria Santos")).toBeTruthy();
  });

  it("calls unfollow when Unfollow is pressed", async () => {
    const unfollow = jest.fn().mockResolvedValueOnce(undefined);
    mockUseSubscriptions.mockReturnValueOnce({ ...defaultHook, follows: [follow], unfollow });
    render(<SignalsScreen />);
    await act(async () => {
      fireEvent.press(screen.getByText("Unfollow"));
    });
    expect(unfollow).toHaveBeenCalledWith(follow.totem_id);
  });

  it("calls unsubscribe when Unsubscribe is pressed", async () => {
    const unsubscribe = jest.fn().mockResolvedValueOnce(undefined);
    mockUseSubscriptions.mockReturnValueOnce({
      ...defaultHook,
      subscriptions: [sub],
      unsubscribe,
    });
    render(<SignalsScreen />);
    await act(async () => {
      fireEvent.press(screen.getByText("Unsubscribe"));
    });
    expect(unsubscribe).toHaveBeenCalledWith(sub.host_user_id);
  });

  it("calls updateFollow when new event switch is toggled", async () => {
    const updateFollow = jest.fn().mockResolvedValueOnce(undefined);
    mockUseSubscriptions.mockReturnValueOnce({ ...defaultHook, follows: [follow], updateFollow });
    render(<SignalsScreen />);
    const switches = screen.UNSAFE_getAllByType(require("react-native").Switch);
    await act(async () => {
      fireEvent(switches[0], "valueChange", false);
    });
    expect(updateFollow).toHaveBeenCalledWith(follow.id, { notify_new_event: false });
  });
});
