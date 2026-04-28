import React from "react";
import { render, act, waitFor } from "@testing-library/react-native";
import * as SplashScreen from "expo-splash-screen";
import * as Notifications from "expo-notifications";
import { useFonts } from "expo-font";
import { router } from "expo-router";
import RootLayout from "../../app/_layout";

const mockUseFonts = useFonts as jest.MockedFunction<typeof useFonts>;
const mockSplashScreen = SplashScreen as jest.Mocked<typeof SplashScreen>;
const mockNotifications = Notifications as jest.Mocked<typeof Notifications>;
const mockRouter = router as jest.Mocked<typeof router>;

beforeEach(() => {
  jest.clearAllMocks();
  mockUseFonts.mockReturnValue([false, null]);
});

describe("RootLayout — fonts and splash", () => {
  it("returns null when fonts are not yet loaded", () => {
    const { toJSON } = render(<RootLayout />);
    expect(toJSON()).toBeNull();
  });

  it("renders Stack when fonts are loaded", () => {
    mockUseFonts.mockReturnValueOnce([true, null]);
    const { UNSAFE_getByType } = render(<RootLayout />);
    expect(UNSAFE_getByType(require("expo-router").Stack)).toBeTruthy();
  });

  it("hides splash screen when fonts finish loading", () => {
    mockUseFonts.mockReturnValueOnce([true, null]);
    render(<RootLayout />);
    expect(mockSplashScreen.hideAsync).toHaveBeenCalled();
  });

  it("does not hide splash screen when fonts are not loaded", () => {
    render(<RootLayout />);
    expect(mockSplashScreen.hideAsync).not.toHaveBeenCalled();
  });
});

describe("RootLayout — foreground notification handler", () => {
  it("registers a foreground notification handler on module load", () => {
    jest.isolateModules(() => {
      const Notifs = require("expo-notifications");
      require("../../app/_layout");
      expect(Notifs.setNotificationHandler).toHaveBeenCalledWith(
        expect.objectContaining({ handleNotification: expect.any(Function) })
      );
    });
  });

  it("foreground handler shows alert, plays sound, and does not set badge", async () => {
    jest.isolateModules(() => {
      const Notifs = require("expo-notifications");
      require("../../app/_layout");
      const { handleNotification } = Notifs.setNotificationHandler.mock.calls[0][0];
      handleNotification().then((opts: any) => {
        expect(opts.shouldShowAlert).toBe(true);
        expect(opts.shouldPlaySound).toBe(true);
        expect(opts.shouldSetBadge).toBe(false);
      });
    });
  });
});

describe("RootLayout — notification tap deep linking", () => {
  function makeNotificationResponse(data: object) {
    return {
      notification: { request: { content: { data } } },
    };
  }

  it("navigates to event when notification is tapped with totem and event slugs", () => {
    let tapCallback: ((r: any) => void) | undefined;
    mockNotifications.addNotificationResponseReceivedListener.mockImplementationOnce((cb) => {
      tapCallback = cb;
      return { remove: jest.fn() } as any;
    });

    render(<RootLayout />);

    act(() => {
      tapCallback!(makeNotificationResponse({ totem_slug: "my-totem", event_slug: "my-event" }));
    });

    expect(mockRouter.push).toHaveBeenCalledWith("/(app)/totem/my-totem/my-event");
  });

  it("does not navigate when notification data is missing slugs", () => {
    let tapCallback: ((r: any) => void) | undefined;
    mockNotifications.addNotificationResponseReceivedListener.mockImplementationOnce((cb) => {
      tapCallback = cb;
      return { remove: jest.fn() } as any;
    });

    render(<RootLayout />);

    act(() => {
      tapCallback!(makeNotificationResponse({ event_id: 1 }));
    });

    expect(mockRouter.push).not.toHaveBeenCalled();
  });

  it("removes tap listener on unmount", () => {
    const removeMock = jest.fn();
    mockNotifications.addNotificationResponseReceivedListener.mockReturnValueOnce({
      remove: removeMock,
    } as any);

    const { unmount } = render(<RootLayout />);
    unmount();

    expect(removeMock).toHaveBeenCalled();
  });
});

describe("RootLayout — cold-start deep linking", () => {
  function makeNotificationResponse(data: object) {
    return {
      notification: { request: { content: { data } } },
    };
  }

  it("navigates to event when app was launched by tapping a notification", async () => {
    mockNotifications.getLastNotificationResponseAsync.mockResolvedValueOnce(
      makeNotificationResponse({ totem_slug: "cold-totem", event_slug: "cold-event" }) as any
    );

    render(<RootLayout />);

    await waitFor(() => {
      expect(mockRouter.push).toHaveBeenCalledWith("/(app)/totem/cold-totem/cold-event");
    });
  });

  it("does not navigate when there is no last notification response", async () => {
    mockNotifications.getLastNotificationResponseAsync.mockResolvedValueOnce(null);

    render(<RootLayout />);

    await waitFor(() => {
      expect(mockNotifications.getLastNotificationResponseAsync).toHaveBeenCalled();
    });
    expect(mockRouter.push).not.toHaveBeenCalled();
  });

  it("does not navigate when last notification response has no slugs", async () => {
    mockNotifications.getLastNotificationResponseAsync.mockResolvedValueOnce(
      makeNotificationResponse({ event_id: 99 }) as any
    );

    render(<RootLayout />);

    await waitFor(() => {
      expect(mockNotifications.getLastNotificationResponseAsync).toHaveBeenCalled();
    });
    expect(mockRouter.push).not.toHaveBeenCalled();
  });
});
