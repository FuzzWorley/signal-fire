import React from "react";
import { render, screen, fireEvent } from "@testing-library/react-native";
import { FollowChip } from "../../components/FollowChip";

describe("FollowChip", () => {
  it("shows 'Follow' when not following", () => {
    render(<FollowChip following={false} onToggle={jest.fn()} />);
    expect(screen.getByText("Follow")).toBeTruthy();
  });

  it("shows '● Following' when following", () => {
    render(<FollowChip following={true} onToggle={jest.fn()} />);
    expect(screen.getByText("● Following")).toBeTruthy();
  });

  it("calls onToggle when pressed", () => {
    const onToggle = jest.fn();
    render(<FollowChip following={false} onToggle={onToggle} />);
    fireEvent.press(screen.getByText("Follow"));
    expect(onToggle).toHaveBeenCalledTimes(1);
  });

  it("calls onToggle when pressed while following", () => {
    const onToggle = jest.fn();
    render(<FollowChip following={true} onToggle={onToggle} />);
    fireEvent.press(screen.getByText("● Following"));
    expect(onToggle).toHaveBeenCalledTimes(1);
  });
});
