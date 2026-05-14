jest.mock("../../services/api", () => ({
  api: {
    get: jest.fn(),
    post: jest.fn(),
    delete: jest.fn(),
  },
  getToken: jest.fn(),
}));

import React from "react";
import { render, screen, fireEvent, waitFor, act } from "@testing-library/react-native";
import { ActivityIndicator } from "react-native";
import { useLocalSearchParams, router } from "expo-router";
import { api, getToken } from "../../services/api";
import HostPageScreen from "../../app/(app)/host/[slug]";
import { posthog } from "../../services/analytics";

const mockApi = api as jest.Mocked<typeof api>;
const mockGetToken = getToken as jest.MockedFunction<typeof getToken>;
const mockUseLocalSearchParams = useLocalSearchParams as jest.MockedFunction<typeof useLocalSearchParams>;
const mockRouter = router as jest.Mocked<typeof router>;

const mockHost = {
  slug: "amara-chen",
  host_user_id: 10,
  display_name: "Amara Chen",
  host_story: "Amara started Acro Yoga at Williams Park three years ago.",
  following: false,
  host_follow_id: null,
  upcoming_events: [
    {
      id: 1,
      title: "Sunday Jam",
      slug: "sunday-jam",
      start_time: new Date(Date.now() + 86400000).toISOString(),
      end_time: new Date(Date.now() + 90000000).toISOString(),
      next_occurrence: new Date(Date.now() + 86400000).toISOString(),
      recurrence_label: "Weekly on Sundays",
      host: { id: 10, slug: "amara-chen", name: "Amara Chen", blurb: null },
    },
  ],
  totems: [
    { name: "Williams Park Lawn", slug: "williams-park-lawn", neighborhood: "Old Northeast" },
  ],
};

beforeEach(() => {
  jest.clearAllMocks();
  mockGetToken.mockResolvedValue("token");
  mockUseLocalSearchParams.mockReturnValue({ slug: "amara-chen" });
});

describe("HostPageScreen loading", () => {
  it("shows loading indicator initially", () => {
    mockApi.get.mockImplementationOnce(() => new Promise(() => {}));
    render(<HostPageScreen />);
    expect(screen.UNSAFE_getByType(ActivityIndicator)).toBeTruthy();
  });

  it("shows not found when request fails", async () => {
    mockApi.get.mockRejectedValueOnce({ status: 404 });
    render(<HostPageScreen />);
    await waitFor(() => {
      expect(screen.getByText("Host not found")).toBeTruthy();
    });
  });
});

describe("HostPageScreen — content", () => {
  beforeEach(() => {
    mockApi.get.mockResolvedValueOnce({ host: mockHost });
  });

  it("renders host display name", async () => {
    render(<HostPageScreen />);
    await waitFor(() => expect(screen.getAllByText(/Amara/).length).toBeGreaterThan(0));
  });

  it("renders host story when present", async () => {
    render(<HostPageScreen />);
    await waitFor(() =>
      expect(
        screen.getByText("Amara started Acro Yoga at Williams Park three years ago.")
      ).toBeTruthy()
    );
  });

  it("renders MEET YOUR HOST label with host story", async () => {
    render(<HostPageScreen />);
    await waitFor(() => expect(screen.getByText("MEET YOUR HOST")).toBeTruthy());
  });

  it("renders Follow CTA button", async () => {
    render(<HostPageScreen />);
    await waitFor(() => expect(screen.getByText("+ Follow Amara")).toBeTruthy());
  });

  it("renders upcoming event title", async () => {
    render(<HostPageScreen />);
    await waitFor(() => expect(screen.getByText("Sunday Jam")).toBeTruthy());
  });

  it("renders totem name in Where to Find section", async () => {
    render(<HostPageScreen />);
    await waitFor(() => expect(screen.getAllByText("Williams Park Lawn").length).toBeGreaterThan(0));
  });

  it("tapping event card navigates to event detail", async () => {
    render(<HostPageScreen />);
    await waitFor(() => screen.getByText("Sunday Jam"));
    fireEvent.press(screen.getByText("Sunday Jam"));
    expect(mockRouter.push).toHaveBeenCalled();
  });
});

describe("HostPageScreen — host story absent", () => {
  it("does not render MEET YOUR HOST when host_story is null", async () => {
    mockApi.get.mockResolvedValueOnce({
      host: { ...mockHost, host_story: null },
    });
    render(<HostPageScreen />);
    await waitFor(() => expect(screen.getAllByText(/Amara/).length).toBeGreaterThan(0));
    expect(screen.queryByText("MEET YOUR HOST")).toBeNull();
  });
});

describe("HostPageScreen — follow toggle (authenticated)", () => {
  it("shows Following state after following", async () => {
    mockApi.get.mockResolvedValueOnce({ host: mockHost });
    mockApi.post.mockResolvedValueOnce({ id: 99 });
    render(<HostPageScreen />);
    await waitFor(() => screen.getByText("+ Follow Amara"));
    await act(async () => {
      fireEvent.press(screen.getByText("+ Follow Amara"));
    });
    await waitFor(() => expect(screen.getByText("Following Amara")).toBeTruthy());
  });

  it("fires host_followed analytics on follow", async () => {
    mockApi.get.mockResolvedValueOnce({ host: mockHost });
    mockApi.post.mockResolvedValueOnce({ id: 99 });
    render(<HostPageScreen />);
    await waitFor(() => screen.getByText("+ Follow Amara"));
    await act(async () => {
      fireEvent.press(screen.getByText("+ Follow Amara"));
    });
    expect(posthog.capture).toHaveBeenCalledWith("host_followed", {
      host_slug: "amara-chen",
    });
  });

  it("shows Follow button after unfollowing", async () => {
    mockApi.get.mockResolvedValueOnce({
      host: { ...mockHost, following: true, host_follow_id: 42 },
    });
    mockApi.delete.mockResolvedValueOnce(undefined);
    render(<HostPageScreen />);
    await waitFor(() => screen.getByText("Following Amara"));
    await act(async () => {
      fireEvent.press(screen.getByText("Following Amara"));
    });
    await waitFor(() => expect(screen.getByText("+ Follow Amara")).toBeTruthy());
  });
});
