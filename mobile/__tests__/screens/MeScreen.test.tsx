jest.mock("../../hooks/useAuth", () => ({
  useAuth: jest.fn(),
}));

jest.mock("../../services/api", () => ({
  api: {
    get: jest.fn(),
  },
}));

import React from "react";
import { render, screen, fireEvent, waitFor, act } from "@testing-library/react-native";
import { Alert } from "react-native";
import { useAuth } from "../../hooks/useAuth";
import { api } from "../../services/api";
import MeScreen from "../../app/(app)/me";

const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>;
const mockApi = api as jest.Mocked<typeof api>;

const fakeUser = {
  id: 1,
  email: "test@example.com",
  name: "Alex Rivera",
  auth_method: "email",
  push_token: null,
  notification_prefs: {},
};

const defaultAuth = {
  user: fakeUser,
  loading: false,
  signUp: jest.fn(),
  signIn: jest.fn(),
  signInWithGoogle: jest.fn(),
  signOut: jest.fn(),
  deleteAccount: jest.fn(),
  refreshUser: jest.fn(),
};

beforeEach(() => {
  jest.clearAllMocks();
  mockUseAuth.mockReturnValue({ ...defaultAuth });
  jest.spyOn(Alert, "alert");
});

describe("MeScreen", () => {
  it("shows loading indicator when user is null", () => {
    mockUseAuth.mockReturnValueOnce({ ...defaultAuth, user: null });
    render(<MeScreen />);
    expect(screen.UNSAFE_getByType(require("react-native").ActivityIndicator)).toBeTruthy();
  });

  it("shows user name in profile card", () => {
    render(<MeScreen />);
    expect(screen.getByText("Alex Rivera")).toBeTruthy();
  });

  it("shows user email in profile card", () => {
    render(<MeScreen />);
    expect(screen.getByText("test@example.com")).toBeTruthy();
  });

  it("shows initials in avatar for named user", () => {
    render(<MeScreen />);
    expect(screen.getByText("AR")).toBeTruthy();
  });

  it("shows single initial when user has only email", () => {
    const userNoName = { ...fakeUser, name: null };
    mockUseAuth.mockReturnValueOnce({ ...defaultAuth, user: userNoName });
    render(<MeScreen />);
    expect(screen.getByText("T")).toBeTruthy();
  });

  it("shows Email auth method", () => {
    render(<MeScreen />);
    expect(screen.getByText("Email")).toBeTruthy();
  });

  it("shows Google auth method label", () => {
    const googleUser = { ...fakeUser, auth_method: "google" };
    mockUseAuth.mockReturnValueOnce({ ...defaultAuth, user: googleUser });
    render(<MeScreen />);
    expect(screen.getByText("● Signed in with Google")).toBeTruthy();
  });

  it("shows check-in history when pressed and loads data", async () => {
    mockApi.get.mockResolvedValueOnce({
      check_ins: [
        {
          checked_in_at: "2026-04-21T10:00:00Z",
          event: { title: "Ecstatic Dance", totem_slug: "waterfront-north", slug: "ed-now" },
        },
      ],
    });
    render(<MeScreen />);
    await act(async () => {
      fireEvent.press(screen.getByText(/Check-in history/));
    });
    await waitFor(() => {
      expect(screen.getByText("Ecstatic Dance")).toBeTruthy();
    });
  });

  it("shows empty message when no check-ins", async () => {
    mockApi.get.mockResolvedValueOnce({ check_ins: [] });
    render(<MeScreen />);
    await act(async () => {
      fireEvent.press(screen.getByText(/Check-in history/));
    });
    await waitFor(() => {
      expect(screen.getByText("No check-ins yet.")).toBeTruthy();
    });
  });

  it("shows sign out alert on sign out press", () => {
    render(<MeScreen />);
    fireEvent.press(screen.getByText("Sign out"));
    expect(Alert.alert).toHaveBeenCalledWith(
      "Sign out",
      expect.any(String),
      expect.any(Array)
    );
  });

  it("shows delete account alert on delete press", () => {
    render(<MeScreen />);
    fireEvent.press(screen.getByText("Delete account"));
    expect(Alert.alert).toHaveBeenCalledWith(
      "Delete account",
      expect.any(String),
      expect.any(Array)
    );
  });
});
