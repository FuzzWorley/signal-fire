import React from "react";
import { render, screen, fireEvent } from "@testing-library/react-native";
import { SubscribeToggle } from "../../components/SubscribeToggle";

describe("SubscribeToggle", () => {
  it("renders the label", () => {
    render(<SubscribeToggle label="Subscribe to Maria" subscribed={false} onToggle={jest.fn()} />);
    expect(screen.getByText("Subscribe to Maria")).toBeTruthy();
  });

  it("Switch reflects subscribed=false", () => {
    render(<SubscribeToggle label="Label" subscribed={false} onToggle={jest.fn()} />);
    const sw = screen.UNSAFE_getByType(require("react-native").Switch);
    expect(sw.props.value).toBe(false);
  });

  it("Switch reflects subscribed=true", () => {
    render(<SubscribeToggle label="Label" subscribed={true} onToggle={jest.fn()} />);
    const sw = screen.UNSAFE_getByType(require("react-native").Switch);
    expect(sw.props.value).toBe(true);
  });

  it("calls onToggle with new value when switched", () => {
    const onToggle = jest.fn();
    render(<SubscribeToggle label="Label" subscribed={false} onToggle={onToggle} />);
    const sw = screen.UNSAFE_getByType(require("react-native").Switch);
    fireEvent(sw, "valueChange", true);
    expect(onToggle).toHaveBeenCalledWith(true);
  });
});
