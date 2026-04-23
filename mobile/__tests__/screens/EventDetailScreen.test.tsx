jest.mock("../../services/api", () => ({
  api: {
    get: jest.fn(),
    post: jest.fn(),
    delete: jest.fn(),
  },
  getToken: jest.fn(),
}));

import { posthog } from "../../services/analytics";

import React from "react";
import { render, screen, fireEvent, waitFor, act } from "@testing-library/react-native";
import { Alert, Linking } from "react-native";
import { useLocalSearchParams, router } from "expo-router";
import { api, getToken } from "../../services/api";
import EventDetailScreen from "../../app/(app)/totem/[slug]/[event_slug]";

const mockApi = api as jest.Mocked<typeof api>;
const mockGetToken = getToken as jest.MockedFunction<typeof getToken>;
const mockUseLocalSearchParams = useLocalSearchParams as jest.MockedFunction<typeof useLocalSearchParams>;
const mockRouter = router as jest.Mocked<typeof router>;

const now = new Date();
const activeEvent = {
  id: 5,
  title: "Ecstatic Dance",
  slug: "ecstatic-dance-now",
  recurrence_type: "one_time",
  start_time: new Date(now.getTime() - 20 * 60000).toISOString(),
  end_time: new Date(now.getTime() + 70 * 60000).toISOString(),
  next_occurrence: new Date(now.getTime() - 20 * 60000).toISOString(),
  chat_url: "https://chat.whatsapp.com/test",
  chat_platform: "whatsapp",
  status: "active",
  description: "Move your body freely.",
  community_norms: "No phones on the floor",
  window_state: "happening_now",
  host: { id: 10, name: "Maria Santos", blurb: "Welcomes newcomers every week." },
  user_checked_in: false,
  checked_in_at: null,
  subscribed_to_host: false,
};

const cancelledEvent = {
  ...activeEvent,
  status: "cancelled",
  window_state: "upcoming",
};

const upcomingEvent = {
  ...activeEvent,
  window_state: "upcoming",
  start_time: new Date(now.getTime() + 2 * 86400000).toISOString(),
  end_time: new Date(now.getTime() + 2 * 86400000 + 90 * 60000).toISOString(),
};

beforeEach(() => {
  jest.clearAllMocks();
  jest.spyOn(Alert, "alert");
  jest.spyOn(Linking, "openURL").mockResolvedValue(undefined as any);
  mockGetToken.mockResolvedValue("token");
  mockUseLocalSearchParams.mockReturnValue({
    slug: "waterfront-north",
    event_slug: "ecstatic-dance-now",
  });
});

describe("EventDetailScreen loading", () => {
  it("shows loading indicator initially", () => {
    mockApi.get.mockImplementationOnce(() => new Promise(() => {}));
    render(<EventDetailScreen />);
    expect(screen.UNSAFE_getByType(require("react-native").ActivityIndicator)).toBeTruthy();
  });

  it("shows not found when event is null", async () => {
    mockApi.get.mockRejectedValueOnce({ status: 404 });
    render(<EventDetailScreen />);
    await waitFor(() => {
      expect(screen.getByText("Event not found")).toBeTruthy();
    });
  });
});

describe("EventDetailScreen — active event", () => {
  beforeEach(() => {
    mockApi.get.mockResolvedValueOnce({ event: activeEvent });
  });

  it("renders event title", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("Ecstatic Dance")).toBeTruthy());
  });

  it("renders host name", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("Maria Santos")).toBeTruthy());
  });

  it("renders description", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("Move your body freely.")).toBeTruthy());
  });

  it("renders community norms", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("No phones on the floor")).toBeTruthy());
  });

  it("shows HAPPENING NOW chip", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("HAPPENING NOW")).toBeTruthy());
  });

  it("shows check-in button for in-window event", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("Check in")).toBeTruthy());
  });

  it("shows Join on WhatsApp button", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("Join on WhatsApp")).toBeTruthy());
  });

  it("opens chat URL when join button pressed", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => screen.getByText("Join on WhatsApp"));
    fireEvent.press(screen.getByText("Join on WhatsApp"));
    expect(Linking.openURL).toHaveBeenCalledWith("https://chat.whatsapp.com/test");
  });
});

describe("EventDetailScreen — check-in", () => {
  it("shows auth prompt for unauthenticated user", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    mockApi.get.mockResolvedValueOnce({ event: activeEvent });
    render(<EventDetailScreen />);
    await waitFor(() => screen.getByText("Check in"));
    await act(async () => {
      fireEvent.press(screen.getByText("Check in"));
    });
    expect(Alert.alert).toHaveBeenCalledWith(
      "Sign in to check in",
      expect.any(String),
      expect.any(Array)
    );
  });

  it("posts check-in when authenticated", async () => {
    mockApi.get.mockResolvedValueOnce({ event: activeEvent });
    mockApi.post.mockResolvedValueOnce({
      checked_in: true,
      checked_in_at: "2026-04-21T10:00:00Z",
    });
    render(<EventDetailScreen />);
    await waitFor(() => screen.getByText("Check in"));
    await act(async () => {
      fireEvent.press(screen.getByText("Check in"));
    });
    expect(mockApi.post).toHaveBeenCalledWith(
      `/api/v1/events/${activeEvent.id}/check_ins`,
      {}
    );
  });

  it("does not show check-in button for upcoming events", async () => {
    mockApi.get.mockResolvedValueOnce({ event: upcomingEvent });
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("Ecstatic Dance")).toBeTruthy());
    expect(screen.queryByText("Check in")).toBeNull();
  });
});

describe("EventDetailScreen — analytics", () => {
  beforeEach(() => {
    mockApi.get.mockResolvedValueOnce({ event: activeEvent });
  });

  it("fires check_in_tapped when check-in button pressed", async () => {
    mockApi.post.mockResolvedValueOnce({ checked_in: true, checked_in_at: "2026-04-22T10:00:00Z" });
    render(<EventDetailScreen />);
    await waitFor(() => screen.getByText("Check in"));
    await act(async () => {
      fireEvent.press(screen.getByText("Check in"));
    });
    expect(posthog.capture).toHaveBeenCalledWith("check_in_tapped", {
      event_id: activeEvent.id,
      totem_slug: "waterfront-north",
    });
  });

  it("fires chat_link_tapped when join button pressed", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => screen.getByText("Join on WhatsApp"));
    fireEvent.press(screen.getByText("Join on WhatsApp"));
    expect(posthog.capture).toHaveBeenCalledWith("chat_link_tapped", {
      event_id: activeEvent.id,
      platform: activeEvent.chat_platform,
    });
  });

  it("fires host_subscribe_toggled when subscribe switch toggled", async () => {
    const { Switch } = require("react-native");
    render(<EventDetailScreen />);
    await waitFor(() => screen.getByText("Maria Santos"));
    const switches = screen.UNSAFE_getAllByType(Switch);
    await act(async () => {
      fireEvent(switches[0], "valueChange", true);
    });
    expect(posthog.capture).toHaveBeenCalledWith("host_subscribe_toggled", {
      host_user_id: activeEvent.host.id,
      action: "subscribe",
    });
  });
});

describe("EventDetailScreen — cancelled event", () => {
  beforeEach(() => {
    mockApi.get.mockResolvedValueOnce({ event: cancelledEvent });
  });

  it("shows CANCELLED banner", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("CANCELLED")).toBeTruthy());
  });

  it("shows cancelled message", async () => {
    render(<EventDetailScreen />);
    await waitFor(() =>
      expect(screen.getByText("This event has been cancelled by the host.")).toBeTruthy()
    );
  });

  it("shows 'Open the WhatsApp group' instead of Join on", async () => {
    render(<EventDetailScreen />);
    await waitFor(() =>
      expect(screen.getByText("Open the WhatsApp group")).toBeTruthy()
    );
  });

  it("does not show check-in button", async () => {
    render(<EventDetailScreen />);
    await waitFor(() => expect(screen.getByText("CANCELLED")).toBeTruthy());
    expect(screen.queryByText("Check in")).toBeNull();
  });
});
