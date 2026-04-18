import React from "react";
import { View, Text, StyleSheet, TouchableOpacity } from "react-native";
import { Colors } from "../constants/colors";
import { FontFamily, FontSize } from "../constants/typography";
import { Event } from "../hooks/useTotem";
import { SubscribeToggle } from "./SubscribeToggle";

function formatNextOccurrence(iso: string, recurrenceType: string): string {
  const d = new Date(iso);
  if (recurrenceType === "weekly") {
    return d.toLocaleDateString("en-US", { weekday: "long" }) +
      " · " +
      d.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" });
  }
  return d.toLocaleDateString("en-US", { month: "short", day: "numeric" }) +
    " · " +
    d.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" });
}

interface Props {
  event: Event;
  onPress: () => void;
  showSubscribeToggle?: boolean;
  onSubscribeChange?: (subscribed: boolean) => void;
}

export function EventCard({ event, onPress, showSubscribeToggle, onSubscribeChange }: Props) {
  const windowState = event.window_state;
  const isHappeningNow = windowState === "happening_now";
  const isStartingSoon = windowState === "starting_soon";
  const isJustEnded = windowState === "just_ended";
  const isActive = isHappeningNow || isStartingSoon || isJustEnded;

  return (
    <TouchableOpacity
      onPress={onPress}
      style={[
        styles.card,
        isHappeningNow && styles.cardHappeningNow,
        isStartingSoon && styles.cardStartingSoon,
        isJustEnded && styles.cardJustEnded,
      ]}
      activeOpacity={0.75}
    >
      {isActive && (
        <View style={[
          styles.chip,
          isHappeningNow && styles.chipHappeningNow,
          isStartingSoon && styles.chipStartingSoon,
          isJustEnded && styles.chipJustEnded,
        ]}>
          <Text style={[
            styles.chipText,
            (isStartingSoon || isJustEnded) && styles.chipTextDark,
          ]}>
            {isHappeningNow ? "HAPPENING NOW" : isStartingSoon ? "STARTING SOON" : "JUST ENDED"}
          </Text>
        </View>
      )}

      <Text style={styles.title}>{event.title}</Text>
      <Text style={styles.meta}>
        {formatNextOccurrence(event.next_occurrence, event.recurrence_type)} · with {event.host.name}
      </Text>

      {event.host.blurb ? (
        <Text style={styles.blurb} numberOfLines={2}>{event.host.blurb}</Text>
      ) : null}

      {showSubscribeToggle && (
        <SubscribeToggle
          label={`Subscribe to ${event.host.name}`}
          subscribed={event.subscribed_to_host ?? false}
          onToggle={onSubscribeChange ?? (() => {})}
        />
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    backgroundColor: Colors.white,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: Colors.border,
    padding: 14,
    marginBottom: 10,
  },
  cardHappeningNow: {
    borderColor: Colors.ember,
    backgroundColor: Colors.emberLight,
  },
  cardStartingSoon: {
    borderWidth: 1,
    borderColor: Colors.stone,
    borderStyle: "dashed" as const,
  },
  cardJustEnded: {
    backgroundColor: "#f9f8f2",
    borderColor: Colors.border,
    opacity: 0.85,
  },
  chip: {
    alignSelf: "flex-start",
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 4,
    marginBottom: 8,
  },
  chipHappeningNow: {
    backgroundColor: Colors.ember,
  },
  chipStartingSoon: {
    backgroundColor: Colors.border,
  },
  chipJustEnded: {
    backgroundColor: Colors.border,
  },
  chipText: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.white,
    letterSpacing: 0.5,
  },
  chipTextDark: {
    color: Colors.ink,
  },
  title: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.ink,
    marginBottom: 3,
  },
  meta: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
    marginBottom: 4,
  },
  blurb: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.ink,
    marginTop: 4,
  },
});
