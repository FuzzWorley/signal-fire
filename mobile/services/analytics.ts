import PostHog from "posthog-react-native";
import { Platform } from "react-native";

// expo-file-system is auto-detected on iOS/Android. On web, posthog-react-native
// excludes expo-file-system, so we provide localStorage as a custom storage provider.
// Use your PostHog Development environment key locally and the Production key
// in production builds (via EAS env vars). Events are always sent so the full
// pipeline can be verified in development — they just land in a separate
// PostHog environment dashboard.
export const posthog = new PostHog(
  process.env.EXPO_PUBLIC_POSTHOG_API_KEY ?? "dev",
  {
    host: "https://us.i.posthog.com",
    ...(Platform.OS === "web" && {
      customStorage: {
        getItem: (key: string) =>
          typeof localStorage !== "undefined" ? localStorage.getItem(key) : null,
        setItem: (key: string, value: string) => {
          if (typeof localStorage !== "undefined") localStorage.setItem(key, value);
        },
      },
    }),
  }
);
