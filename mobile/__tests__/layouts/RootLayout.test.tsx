import React from "react";
import { render } from "@testing-library/react-native";
import * as SplashScreen from "expo-splash-screen";
import { useFonts } from "expo-font";
import RootLayout from "../../app/_layout";

const mockUseFonts = useFonts as jest.MockedFunction<typeof useFonts>;
const mockSplashScreen = SplashScreen as jest.Mocked<typeof SplashScreen>;

beforeEach(() => {
  jest.clearAllMocks();
});

describe("RootLayout", () => {
  it("returns null when fonts are not yet loaded", () => {
    mockUseFonts.mockReturnValueOnce([false, null]);
    const { toJSON } = render(<RootLayout />);
    expect(toJSON()).toBeNull();
  });

  it("renders Stack when fonts are loaded", () => {
    mockUseFonts.mockReturnValueOnce([true, null]);
    const { UNSAFE_getByType } = render(<RootLayout />);
    expect(UNSAFE_getByType(require("expo-router").Stack)).toBeTruthy();
  });

  it("hides splash screen when fonts finish loading", async () => {
    mockUseFonts.mockReturnValueOnce([true, null]);
    render(<RootLayout />);
    expect(mockSplashScreen.hideAsync).toHaveBeenCalled();
  });

  it("does not hide splash screen when fonts are not loaded", () => {
    mockUseFonts.mockReturnValueOnce([false, null]);
    render(<RootLayout />);
    expect(mockSplashScreen.hideAsync).not.toHaveBeenCalled();
  });
});
