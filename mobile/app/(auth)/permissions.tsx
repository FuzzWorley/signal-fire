import React, { useEffect, useState } from "react";
import { View, Text, StyleSheet, TouchableOpacity, Alert } from "react-native";
import { router } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";
import * as Notifications from "expo-notifications";
import { Colors } from "../../constants/colors";
import { FontFamily, FontSize } from "../../constants/typography";
import { api } from "../../services/api";
import { posthog } from "../../services/analytics";

export default function PermissionsScreen() {
  const [requesting, setRequesting] = useState(false);

  useEffect(() => {
    posthog.capture("permissions_shown");
  }, []);

  async function handleAllow() {
    setRequesting(true);
    try {
      const { status } = await Notifications.requestPermissionsAsync();
      if (status === "granted") {
        posthog.capture("permissions_granted");
        const token = await Notifications.getExpoPushTokenAsync().catch(() => null);
        if (token) {
          await api.post("/api/v1/me/push_token", { push_token: token.data }).catch(() => {});
        }
      }
    } finally {
      setRequesting(false);
      router.push("/(auth)/sign-up");
    }
  }

  function handleSkip() {
    posthog.capture("permissions_skipped");
    router.push("/(auth)/sign-up");
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.inner}>
        <View style={styles.hero}>
          <View style={styles.iconPlaceholder}>
            <Text style={styles.bellEmoji}>🔔</Text>
          </View>
        </View>

        <View style={styles.copy}>
          <Text style={styles.headline}>
            Get notified when groups you follow post events.
          </Text>
          <Text style={styles.body}>
            Push notifications are how Signal Fire tells you something's happening near you.
            You can change this anytime.
          </Text>
        </View>

        <View style={styles.actions}>
          <TouchableOpacity
            style={styles.primaryButton}
            onPress={handleAllow}
            disabled={requesting}
            activeOpacity={0.85}
          >
            <Text style={styles.primaryButtonText}>Allow notifications</Text>
          </TouchableOpacity>

          <TouchableOpacity style={styles.skipButton} onPress={handleSkip}>
            <Text style={styles.skipText}>Skip for now</Text>
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: Colors.paper,
  },
  inner: {
    flex: 1,
    paddingHorizontal: 28,
    justifyContent: "space-between",
    paddingBottom: 32,
  },
  hero: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  iconPlaceholder: {
    width: 100,
    height: 100,
    borderRadius: 16,
    borderWidth: 1.5,
    borderColor: Colors.border,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: Colors.white,
  },
  bellEmoji: {
    fontSize: 40,
  },
  copy: {
    marginBottom: 40,
  },
  headline: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.xl,
    color: Colors.ink,
    textAlign: "center",
    marginBottom: 12,
    lineHeight: 28,
  },
  body: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.stone,
    textAlign: "center",
    lineHeight: 22,
  },
  actions: {
    gap: 12,
  },
  primaryButton: {
    backgroundColor: Colors.ember,
    borderRadius: 10,
    paddingVertical: 16,
    alignItems: "center",
  },
  primaryButtonText: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.white,
  },
  skipButton: {
    paddingVertical: 12,
    alignItems: "center",
  },
  skipText: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
});
