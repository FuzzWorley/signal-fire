jest.mock("../../hooks/useTotem", () => ({
  useTotem: jest.fn(),
}));

jest.mock("../../services/api", () => ({
  api: {
    post: jest.fn(),
    delete: jest.fn(),
  },
}));

import React from "react";
import { render, screen, waitFor } from "@testing-library/react-native";
import { useLocalSearchParams, router } from "expo-router";
import { useTotem } from "../../hooks/useTotem";
import TotemBoardScreen from "../../app/(app)/totem/[slug]";

const mockUseTotem = useTotem as jest.MockedFunction<typeof useTotem>;
const mockUseLocalSearchParams = useLocalSearchParams as jest.MockedFunction<typeof useLocalSearchParams>;
const mockRouter = router as jest.Mocked<typeof router>;

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

const defaultHook = {
  totem: baseTotem,
  loading: false,
  error: null,
  load: jest.fn(),
  toggleFollow: jest.fn(),
  setTotem: jest.fn(),
};

beforeEach(() => {
  jest.clearAllMocks();
  mockUseLocalSearchParams.mockReturnValue({ slug: "waterfront-north" });
  mockUseTotem.mockReturnValue({ ...defaultHook });
});

describe("TotemBoardScreen rendering", () => {
  it("renders the totem name", () => {
    render(<TotemBoardScreen />);
    expect(screen.getByText("Waterfront North")).toBeTruthy();
  });

  it("renders location", () => {
    render(<TotemBoardScreen />);
    expect(screen.getByText("St. Petersburg")).toBeTruthy();
  });

  it("shows loading indicator while loading", () => {
    mockUseTotem.mockReturnValueOnce({ ...defaultHook, totem: null, loading: true });
    render(<TotemBoardScreen />);
    expect(screen.UNSAFE_getByType(require("react-native").ActivityIndicator)).toBeTruthy();
  });

  it("shows error state", () => {
    mockUseTotem.mockReturnValueOnce({
      ...defaultHook,
      totem: null,
      loading: false,
      error: "Totem not found",
    });
    render(<TotemBoardScreen />);
    expect(screen.getByText("Totem not found")).toBeTruthy();
  });

  it("shows empty state when totem is empty", () => {
    mockUseTotem.mockReturnValueOnce({
      ...defaultHook,
      totem: { ...baseTotem, empty: true },
    });
    render(<TotemBoardScreen />);
    expect(screen.getByText("This spot isn't active yet")).toBeTruthy();
  });
});

describe("auto-follow on scan", () => {
  it("calls toggleFollow when source=scan and following=false", async () => {
    const toggleFollow = jest.fn();
    mockUseLocalSearchParams.mockReturnValue({ slug: "waterfront-north", source: "scan" });
    mockUseTotem.mockReturnValue({
      ...defaultHook,
      totem: { ...baseTotem, following: false },
      toggleFollow,
    });
    render(<TotemBoardScreen />);
    await waitFor(() => {
      expect(toggleFollow).toHaveBeenCalledTimes(1);
    });
  });

  it("does NOT call toggleFollow when already following", async () => {
    const toggleFollow = jest.fn();
    mockUseLocalSearchParams.mockReturnValue({ slug: "waterfront-north", source: "scan" });
    mockUseTotem.mockReturnValue({
      ...defaultHook,
      totem: { ...baseTotem, following: true },
      toggleFollow,
    });
    render(<TotemBoardScreen />);
    await waitFor(() => expect(screen.getByText("Waterfront North")).toBeTruthy());
    expect(toggleFollow).not.toHaveBeenCalled();
  });

  it("does NOT call toggleFollow when unauthenticated (following=null)", async () => {
    const toggleFollow = jest.fn();
    mockUseLocalSearchParams.mockReturnValue({ slug: "waterfront-north", source: "scan" });
    mockUseTotem.mockReturnValue({
      ...defaultHook,
      totem: { ...baseTotem, following: null },
      toggleFollow,
    });
    render(<TotemBoardScreen />);
    await waitFor(() => expect(screen.getByText("Waterfront North")).toBeTruthy());
    expect(toggleFollow).not.toHaveBeenCalled();
  });

  it("does NOT call toggleFollow without source=scan", async () => {
    const toggleFollow = jest.fn();
    mockUseLocalSearchParams.mockReturnValue({ slug: "waterfront-north" });
    mockUseTotem.mockReturnValue({
      ...defaultHook,
      totem: { ...baseTotem, following: false },
      toggleFollow,
    });
    render(<TotemBoardScreen />);
    await waitFor(() => expect(screen.getByText("Waterfront North")).toBeTruthy());
    expect(toggleFollow).not.toHaveBeenCalled();
  });
});

describe("FollowChip", () => {
  it("renders Follow chip when following=false", () => {
    render(<TotemBoardScreen />);
    expect(screen.getByText("Follow")).toBeTruthy();
  });

  it("renders Following chip when following=true", () => {
    mockUseTotem.mockReturnValueOnce({
      ...defaultHook,
      totem: { ...baseTotem, following: true },
    });
    render(<TotemBoardScreen />);
    expect(screen.getByText("● Following")).toBeTruthy();
  });

  it("does not render FollowChip when following=null (unauthenticated)", () => {
    mockUseTotem.mockReturnValueOnce({
      ...defaultHook,
      totem: { ...baseTotem, following: null },
    });
    render(<TotemBoardScreen />);
    expect(screen.queryByText("Follow")).toBeNull();
    expect(screen.queryByText("● Following")).toBeNull();
  });
});
