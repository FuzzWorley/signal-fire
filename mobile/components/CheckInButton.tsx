import React from "react";
import { TouchableOpacity, Text, StyleSheet, ActivityIndicator } from "react-native";
import { Colors } from "../constants/colors";
import { FontFamily, FontSize } from "../constants/typography";

interface Props {
  windowState: string;
  checkedIn: boolean;
  checkedInAt: string | null;
  loading: boolean;
  onPress: () => void;
}

function formatTime(iso: string): string {
  return new Date(iso).toLocaleTimeString("en-US", {
    hour: "numeric",
    minute: "2-digit",
  });
}

function labelForState(windowState: string): string {
  if (windowState === "starting_soon") return "Check in — starting soon";
  if (windowState === "just_ended") return "Check in — just ended";
  return "Check in";
}

export function CheckInButton({ windowState, checkedIn, checkedInAt, loading, onPress }: Props) {
  const inWindow =
    windowState === "happening_now" ||
    windowState === "starting_soon" ||
    windowState === "just_ended";

  if (!inWindow) return null;

  if (checkedIn && checkedInAt) {
    return (
      <TouchableOpacity style={styles.checkedIn} disabled>
        <Text style={styles.checkedInText}>
          ✓ Checked in — {formatTime(checkedInAt)}
        </Text>
      </TouchableOpacity>
    );
  }

  return (
    <TouchableOpacity style={styles.button} onPress={onPress} disabled={loading}>
      {loading ? (
        <ActivityIndicator color={Colors.white} size="small" />
      ) : (
        <Text style={styles.buttonText}>{labelForState(windowState)}</Text>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    backgroundColor: Colors.ember,
    borderRadius: 8,
    paddingVertical: 14,
    alignItems: "center",
    marginTop: 12,
  },
  buttonText: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.white,
  },
  checkedIn: {
    backgroundColor: "#e8f5e8",
    borderRadius: 8,
    paddingVertical: 14,
    alignItems: "center",
    marginTop: 12,
    borderWidth: 1,
    borderColor: "#4caf50",
  },
  checkedInText: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: "#2e7d32",
  },
});
