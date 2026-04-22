jest.mock("../../services/api", () => ({
  api: {
    post: jest.fn(),
  },
}));

import React from "react";
import { render, screen, fireEvent, waitFor } from "@testing-library/react-native";
import { router } from "expo-router";
import * as Notifications from "expo-notifications";
import { api } from "../../services/api";
import PermissionsScreen from "../../app/(auth)/permissions";

const mockRouter = router as jest.Mocked<typeof router>;
const mockNotifications = Notifications as jest.Mocked<typeof Notifications>;
const mockApi = api as jest.Mocked<typeof api>;

beforeEach(() => {
  jest.clearAllMocks();
});

describe("PermissionsScreen", () => {
  it("renders the Allow notifications button", () => {
    render(<PermissionsScreen />);
    expect(screen.getByText("Allow notifications")).toBeTruthy();
  });

  it("renders Skip for now button", () => {
    render(<PermissionsScreen />);
    expect(screen.getByText("Skip for now")).toBeTruthy();
  });

  it("navigates to sign-up on skip", () => {
    render(<PermissionsScreen />);
    fireEvent.press(screen.getByText("Skip for now"));
    expect(mockRouter.push).toHaveBeenCalledWith("/(auth)/sign-up");
  });

  it("requests permissions and navigates to sign-up on allow", async () => {
    mockNotifications.requestPermissionsAsync.mockResolvedValueOnce({ status: "granted" } as any);
    mockNotifications.getExpoPushTokenAsync.mockResolvedValueOnce({ data: "ExponentPushToken[abc]" } as any);
    mockApi.post.mockResolvedValueOnce(undefined);

    render(<PermissionsScreen />);
    fireEvent.press(screen.getByText("Allow notifications"));

    await waitFor(() => {
      expect(mockRouter.push).toHaveBeenCalledWith("/(auth)/sign-up");
    });
  });

  it("sends push token to API when permission granted", async () => {
    mockNotifications.requestPermissionsAsync.mockResolvedValueOnce({ status: "granted" } as any);
    mockNotifications.getExpoPushTokenAsync.mockResolvedValueOnce({ data: "ExponentPushToken[xyz]" } as any);
    mockApi.post.mockResolvedValueOnce(undefined);

    render(<PermissionsScreen />);
    fireEvent.press(screen.getByText("Allow notifications"));

    await waitFor(() => {
      expect(mockApi.post).toHaveBeenCalledWith("/api/v1/me/push_token", {
        push_token: "ExponentPushToken[xyz]",
      });
    });
  });

  it("navigates to sign-up even when permission is denied", async () => {
    mockNotifications.requestPermissionsAsync.mockResolvedValueOnce({ status: "denied" } as any);

    render(<PermissionsScreen />);
    fireEvent.press(screen.getByText("Allow notifications"));

    await waitFor(() => {
      expect(mockRouter.push).toHaveBeenCalledWith("/(auth)/sign-up");
    });
    expect(mockApi.post).not.toHaveBeenCalled();
  });
});
