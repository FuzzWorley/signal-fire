jest.mock("../../hooks/useAuth", () => ({
  useAuth: jest.fn(),
}));

import React from "react";
import { render, screen, fireEvent, waitFor, act } from "@testing-library/react-native";
import { Alert } from "react-native";
import { useAuth } from "../../hooks/useAuth";
import SignUpScreen from "../../app/(auth)/sign-up";

const mockUseAuth = useAuth as jest.MockedFunction<typeof useAuth>;

const defaultAuth = {
  user: null,
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

describe("SignUpScreen", () => {
  it("renders in signup mode by default", () => {
    render(<SignUpScreen />);
    expect(screen.getByText("CREATE ACCOUNT")).toBeTruthy();
    expect(screen.getByText("Create account")).toBeTruthy();
  });

  it("shows alert for missing fields", async () => {
    render(<SignUpScreen />);
    await act(async () => {
      fireEvent.press(screen.getByText("Create account"));
    });
    expect(Alert.alert).toHaveBeenCalledWith("Missing fields", expect.any(String));
  });

  it("calls signUp with email and password", async () => {
    const signUp = jest.fn().mockResolvedValueOnce(undefined);
    mockUseAuth.mockReturnValue({ ...defaultAuth, signUp });

    render(<SignUpScreen />);
    fireEvent.changeText(screen.getByLabelText("Email"), "user@example.com");
    fireEvent.changeText(screen.getByLabelText("Password"), "secret123");

    await act(async () => {
      fireEvent.press(screen.getByText("Create account"));
    });

    expect(signUp).toHaveBeenCalledWith("user@example.com", "secret123");
  });

  it("toggles to signin mode", () => {
    render(<SignUpScreen />);
    fireEvent.press(screen.getByText(/Already have an account/));
    expect(screen.getByText("SIGN IN")).toBeTruthy();
    expect(screen.getByText("Sign in")).toBeTruthy();
  });

  it("calls signIn in signin mode", async () => {
    const signIn = jest.fn().mockResolvedValueOnce(undefined);
    mockUseAuth.mockReturnValue({ ...defaultAuth, signIn });

    render(<SignUpScreen />);
    fireEvent.press(screen.getByText(/Already have an account/));
    fireEvent.changeText(screen.getByLabelText("Email"), "user@example.com");
    fireEvent.changeText(screen.getByLabelText("Password"), "secret123");

    await act(async () => {
      fireEvent.press(screen.getByText("Sign in"));
    });

    expect(signIn).toHaveBeenCalledWith("user@example.com", "secret123");
  });

  it("shows error alert when signUp fails", async () => {
    const signUp = jest.fn().mockRejectedValueOnce({ body: { error: "Email taken" } });
    mockUseAuth.mockReturnValue({ ...defaultAuth, signUp });

    render(<SignUpScreen />);
    fireEvent.changeText(screen.getByLabelText("Email"), "taken@example.com");
    fireEvent.changeText(screen.getByLabelText("Password"), "pass");

    await act(async () => {
      fireEvent.press(screen.getByText("Create account"));
    });

    expect(Alert.alert).toHaveBeenCalledWith("Error", "Email taken");
  });

  it("renders Continue with Google button", () => {
    render(<SignUpScreen />);
    expect(screen.getByText("Continue with Google")).toBeTruthy();
  });

  it("renders Continue with Apple button", () => {
    render(<SignUpScreen />);
    expect(screen.getByText("Continue with Apple")).toBeTruthy();
  });
});
