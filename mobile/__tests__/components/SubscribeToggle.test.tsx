import React from "react";
import { render, screen, fireEvent } from "@testing-library/react-native";
import { SubscribeToggle } from "../../components/SubscribeToggle";

describe("SubscribeToggle", () => {
  it("renders the label", () => {
    render(<SubscribeToggle label="Follow Maria" following={false} onToggle={jest.fn()} />);
    expect(screen.getByText("Follow Maria")).toBeTruthy();
  });

  it("Switch reflects following=false", () => {
    render(<SubscribeToggle label="Label" following={false} onToggle={jest.fn()} />);
    const sw = screen.UNSAFE_getByType(require("react-native").Switch);
    expect(sw.props.value).toBe(false);
  });

  it("Switch reflects following=true", () => {
    render(<SubscribeToggle label="Label" following={true} onToggle={jest.fn()} />);
    const sw = screen.UNSAFE_getByType(require("react-native").Switch);
    expect(sw.props.value).toBe(true);
  });

  it("calls onToggle with new value when switched", () => {
    const onToggle = jest.fn();
    render(<SubscribeToggle label="Label" following={false} onToggle={onToggle} />);
    const sw = screen.UNSAFE_getByType(require("react-native").Switch);
    fireEvent(sw, "valueChange", true);
    expect(onToggle).toHaveBeenCalledWith(true);
  });
});
