import React from "react";
import { TouchableOpacity, ActivityIndicator } from "react-native";
import { render, screen, fireEvent } from "@testing-library/react-native";
import { CheckInButton } from "../../components/CheckInButton";

const defaultProps = {
  windowState: "happening_now",
  checkedIn: false,
  checkedInAt: null,
  loading: false,
  onPress: jest.fn(),
};

beforeEach(() => {
  jest.clearAllMocks();
});

describe("visibility", () => {
  it("returns null for non-window states", () => {
    const { toJSON } = render(<CheckInButton {...defaultProps} windowState="upcoming" />);
    expect(toJSON()).toBeNull();
  });

  it("renders for happening_now", () => {
    render(<CheckInButton {...defaultProps} windowState="happening_now" />);
    expect(screen.getByText("Check in")).toBeTruthy();
  });

  it("renders for starting_soon with correct label", () => {
    render(<CheckInButton {...defaultProps} windowState="starting_soon" />);
    expect(screen.getByText("Check in — starting soon")).toBeTruthy();
  });

  it("renders for just_ended with correct label", () => {
    render(<CheckInButton {...defaultProps} windowState="just_ended" />);
    expect(screen.getByText("Check in — just ended")).toBeTruthy();
  });
});

describe("loading state", () => {
  it("shows ActivityIndicator instead of label when loading", () => {
    render(<CheckInButton {...defaultProps} loading={true} />);
    expect(screen.queryByText("Check in")).toBeNull();
    expect(screen.UNSAFE_getByType(ActivityIndicator)).toBeTruthy();
  });
});

describe("checked-in state", () => {
  it("shows checked-in confirmation with formatted time", () => {
    render(
      <CheckInButton
        {...defaultProps}
        checkedIn={true}
        checkedInAt="2026-04-21T10:30:00.000Z"
      />
    );
    expect(screen.getByText(/✓ Checked in/)).toBeTruthy();
  });

  it("checked-in button is disabled", () => {
    render(
      <CheckInButton
        {...defaultProps}
        checkedIn={true}
        checkedInAt="2026-04-21T10:30:00.000Z"
      />
    );
    const btn = screen.UNSAFE_getByType(TouchableOpacity);
    expect(btn.props.disabled).toBe(true);
  });
});

describe("interaction", () => {
  it("calls onPress when tapped", () => {
    const onPress = jest.fn();
    render(<CheckInButton {...defaultProps} onPress={onPress} />);
    fireEvent.press(screen.getByText("Check in"));
    expect(onPress).toHaveBeenCalledTimes(1);
  });
});
