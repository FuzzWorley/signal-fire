jest.mock("../../services/api", () => ({
  api: {
    get: jest.fn(),
  },
}));

import React from "react";
import { ActivityIndicator } from "react-native";
import { render, screen, fireEvent, waitFor } from "@testing-library/react-native";
import { router } from "expo-router";
import { api } from "../../services/api";
import HomeScreen from "../../app/(app)/index";

const mockApi = api as jest.Mocked<typeof api>;
const mockRouter = router as jest.Mocked<typeof router>;

const board = {
  totem_slug: "waterfront-north",
  totem_name: "St. Pete Waterfront North",
  active_event: null,
  next_event: {
    slug: "ecstatic-dance",
    title: "Sunday Mass — Ecstatic Dance",
    next_occurrence: new Date(Date.now() + 86400000).toISOString(),
    recurrence_type: "weekly",
  },
};

beforeEach(() => {
  jest.clearAllMocks();
});

describe("HomeScreen loading", () => {
  it("shows loading indicator while fetching", () => {
    mockApi.get.mockImplementationOnce(() => new Promise(() => {}));
    render(<HomeScreen />);
    expect(screen.UNSAFE_getByType(ActivityIndicator)).toBeTruthy();
  });
});

describe("HomeScreen empty state", () => {
  it("shows 'No totems yet' when boards list is empty", async () => {
    mockApi.get.mockResolvedValueOnce({ boards: [] });
    render(<HomeScreen />);
    await waitFor(() => {
      expect(screen.getByText("No totems yet")).toBeTruthy();
    });
  });

  it("shows exactly one scan button in empty state", async () => {
    mockApi.get.mockResolvedValueOnce({ boards: [] });
    render(<HomeScreen />);
    await waitFor(() => {
      const scanButtons = screen.getAllByText("Scan a totem");
      expect(scanButtons).toHaveLength(1);
    });
  });

  it("scan button navigates to scan screen", async () => {
    mockApi.get.mockResolvedValueOnce({ boards: [] });
    render(<HomeScreen />);
    await waitFor(() => screen.getByText("Scan a totem"));
    fireEvent.press(screen.getByText("Scan a totem"));
    expect(mockRouter.push).toHaveBeenCalledWith("/(app)/scan");
  });
});

describe("HomeScreen with boards", () => {
  it("shows the board totem name", async () => {
    mockApi.get.mockResolvedValueOnce({ boards: [board] });
    render(<HomeScreen />);
    await waitFor(() => {
      expect(screen.getByText("ST. PETE WATERFRONT NORTH")).toBeTruthy();
    });
  });

  it("shows following count", async () => {
    mockApi.get.mockResolvedValueOnce({ boards: [board] });
    render(<HomeScreen />);
    await waitFor(() => {
      expect(screen.getByText("FOLLOWING · 1 TOTEM")).toBeTruthy();
    });
  });

  it("shows exactly one scan button with boards present", async () => {
    mockApi.get.mockResolvedValueOnce({ boards: [board] });
    render(<HomeScreen />);
    await waitFor(() => {
      const scanButtons = screen.getAllByText("Scan a totem");
      expect(scanButtons).toHaveLength(1);
    });
  });

  it("navigates to totem board when card is pressed", async () => {
    mockApi.get.mockResolvedValueOnce({ boards: [board] });
    render(<HomeScreen />);
    await waitFor(() => screen.getByText("ST. PETE WATERFRONT NORTH"));
    fireEvent.press(screen.getByText("ST. PETE WATERFRONT NORTH"));
    expect(mockRouter.push).toHaveBeenCalledWith("/totem/waterfront-north");
  });

  it("shows HAPPENING NOW chip for active events", async () => {
    const activeBoard = {
      ...board,
      active_event: {
        slug: "ecstatic-dance-now",
        title: "Ecstatic Dance",
        window_state: "happening_now",
        start_time: new Date(Date.now() - 20 * 60000).toISOString(),
      },
    };
    mockApi.get.mockResolvedValueOnce({ boards: [activeBoard] });
    render(<HomeScreen />);
    await waitFor(() => {
      expect(screen.getByText("HAPPENING NOW")).toBeTruthy();
    });
  });
});
