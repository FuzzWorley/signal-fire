import React from "react";
import { render } from "@testing-library/react-native";
import SignIn from "../../app/(auth)/sign-in";

describe("SignIn", () => {
  it("redirects immediately to /(auth)/sign-up", () => {
    const { UNSAFE_getByType } = render(<SignIn />);
    const redirect = UNSAFE_getByType(require("expo-router").Redirect);
    expect(redirect.props.href).toBe("/(auth)/sign-up");
  });
});
