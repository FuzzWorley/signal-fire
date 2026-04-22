jest.mock("../../services/api", () => ({
  getToken: jest.fn(),
}));

import React from "react";
import { render, waitFor } from "@testing-library/react-native";
import { getToken } from "../../services/api";
import Index from "../../app/index";

const mockGetToken = getToken as jest.MockedFunction<typeof getToken>;

beforeEach(() => {
  jest.clearAllMocks();
});

describe("Index redirect", () => {
  it("renders nothing while checking token", () => {
    mockGetToken.mockImplementationOnce(() => new Promise(() => {}));
    const { toJSON } = render(<Index />);
    expect(toJSON()).toBeNull();
  });

  it("redirects to /(app)/ when token exists", async () => {
    mockGetToken.mockResolvedValueOnce("valid-jwt");
    const { UNSAFE_getByType } = render(<Index />);
    await waitFor(() => {
      const redirect = UNSAFE_getByType(require("expo-router").Redirect);
      expect(redirect.props.href).toBe("/(app)/");
    });
  });

  it("redirects to /(auth)/welcome when no token", async () => {
    mockGetToken.mockResolvedValueOnce(null);
    const { UNSAFE_getByType } = render(<Index />);
    await waitFor(() => {
      const redirect = UNSAFE_getByType(require("expo-router").Redirect);
      expect(redirect.props.href).toBe("/(auth)/welcome");
    });
  });
});
