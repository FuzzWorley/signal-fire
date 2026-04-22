import React from "react";
import { render, screen, fireEvent } from "@testing-library/react-native";
import { router } from "expo-router";
import WelcomeScreen from "../../app/(auth)/welcome";

const mockRouter = router as jest.Mocked<typeof router>;

beforeEach(() => {
  jest.clearAllMocks();
});

describe("WelcomeScreen", () => {
  it("renders the headline", () => {
    render(<WelcomeScreen />);
    expect(screen.getByText("Find your people, already gathered.")).toBeTruthy();
  });

  it("navigates to permissions on Get started", () => {
    render(<WelcomeScreen />);
    fireEvent.press(screen.getByText("Get started"));
    expect(mockRouter.push).toHaveBeenCalledWith("/(auth)/permissions");
  });

  it("navigates to sign-up when already have account is pressed", () => {
    render(<WelcomeScreen />);
    fireEvent.press(screen.getByText(/Already have an account/));
    expect(mockRouter.push).toHaveBeenCalledWith("/(auth)/sign-up");
  });
});
