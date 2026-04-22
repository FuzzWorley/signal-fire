import React from "react";
import { render } from "@testing-library/react-native";
import TotemLayout from "../../app/totem/_layout";

describe("TotemLayout", () => {
  it("renders a Stack navigator", () => {
    const { UNSAFE_getByType } = render(<TotemLayout />);
    expect(UNSAFE_getByType(require("expo-router").Stack)).toBeTruthy();
  });

  it("renders without crashing", () => {
    expect(() => render(<TotemLayout />)).not.toThrow();
  });
});
