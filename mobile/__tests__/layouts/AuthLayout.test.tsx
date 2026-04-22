import React from "react";
import { render } from "@testing-library/react-native";
import AuthLayout from "../../app/(auth)/_layout";

describe("AuthLayout", () => {
  it("renders a Stack navigator", () => {
    const { UNSAFE_getByType } = render(<AuthLayout />);
    expect(UNSAFE_getByType(require("expo-router").Stack)).toBeTruthy();
  });

  it("renders without crashing", () => {
    expect(() => render(<AuthLayout />)).not.toThrow();
  });
});
