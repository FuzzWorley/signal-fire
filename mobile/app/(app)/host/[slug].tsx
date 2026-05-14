import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
} from "react-native";
import { useLocalSearchParams, router } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";
import { Colors } from "../../../constants/colors";
import { FontFamily, FontSize } from "../../../constants/typography";
import { useHostPage } from "../../../hooks/useHostPage";
import { getToken } from "../../../services/api";
import { posthog } from "../../../services/analytics";

function formatEventDate(iso: string): string {
  const d = new Date(iso);
  return (
    d.toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric" }) +
    " · " +
    d.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" })
  );
}

export default function HostPageScreen() {
  const { slug } = useLocalSearchParams<{ slug: string }>();
  const { host, loading, error, load, toggleFollow } = useHostPage(slug);
  const [authenticated, setAuthenticated] = useState(false);
  const [followLoading, setFollowLoading] = useState(false);

  useEffect(() => {
    getToken().then((t) => setAuthenticated(!!t));
    load();
  }, [slug]);

  async function handleFollowToggle() {
    if (!host || followLoading) return;
    setFollowLoading(true);
    posthog.capture(host.following ? "host_unfollowed" : "host_followed", {
      host_slug: slug,
    });
    await toggleFollow(!host.following, host.host_follow_id);
    setFollowLoading(false);
  }

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <ActivityIndicator color={Colors.ember} style={{ flex: 1 }} />
      </SafeAreaView>
    );
  }

  if (error || !host) {
    return (
      <SafeAreaView style={styles.container}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>‹ Back</Text>
        </TouchableOpacity>
        <Text style={styles.notFound}>Host not found</Text>
      </SafeAreaView>
    );
  }

  const nameParts = host.display_name.split(" ");
  const firstName = nameParts[0];

  const eventsByTotem = host.upcoming_events.reduce<Record<string, typeof host.upcoming_events>>(
    (acc, event) => {
      const totemName = event.host?.name ?? "Events";
      acc[totemName] = acc[totemName] ?? [];
      acc[totemName].push(event);
      return acc;
    },
    {}
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scroll}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
          <Text style={styles.backText}>‹ Back</Text>
        </TouchableOpacity>

        {/* Eyebrow */}
        <Text style={styles.eyebrow}>HOST · ST. PETERSBURG</Text>

        {/* Name — italic on last word */}
        <View style={styles.nameRow}>
          {nameParts.length > 1 ? (
            <Text style={styles.nameDisplay}>
              {nameParts.slice(0, -1).join(" ")}{"\n"}
              <Text style={styles.nameDisplayItalic}>{nameParts[nameParts.length - 1]}.</Text>
            </Text>
          ) : (
            <Text style={[styles.nameDisplay, styles.nameDisplayItalic]}>
              {host.display_name}.
            </Text>
          )}
        </View>

        {/* Totem summary */}
        {host.totems.length > 0 && (
          <Text style={styles.locationSummary}>
            {host.totems.map((t) => t.name).join(" · ")}
          </Text>
        )}

        {/* Host story panel */}
        {host.host_story ? (
          <View style={styles.storyPanel}>
            <Text style={styles.storyLabel}>MEET YOUR HOST</Text>
            <Text style={styles.storyBody}>{host.host_story}</Text>
          </View>
        ) : null}

        {/* Follow CTA */}
        {authenticated ? (
          <TouchableOpacity
            style={[styles.followButton, host.following && styles.followButtonActive]}
            onPress={handleFollowToggle}
            disabled={followLoading}
            activeOpacity={0.85}
          >
            <Text style={[styles.followButtonText, host.following && styles.followButtonTextActive]}>
              {host.following ? `Following ${firstName}` : `+ Follow ${firstName}`}
            </Text>
          </TouchableOpacity>
        ) : (
          <TouchableOpacity style={styles.followButton} activeOpacity={0.85}>
            <Text style={styles.followButtonText}>+ Follow {firstName}</Text>
          </TouchableOpacity>
        )}
        <Text style={styles.followSubtext}>
          You'll hear about new events in the weekly digest.
        </Text>

        {/* Upcoming events */}
        {host.upcoming_events.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionLabel}>UPCOMING EVENTS</Text>
            {host.upcoming_events.map((event) => (
              <TouchableOpacity
                key={event.id}
                style={styles.eventCard}
                onPress={() =>
                  router.push(`/(app)/totem/${event.host?.slug ?? slug}/${event.slug}` as any)
                }
                activeOpacity={0.85}
              >
                <Text style={styles.eventTitle}>{event.title}</Text>
                <Text style={styles.eventMeta}>
                  {formatEventDate(event.next_occurrence)}
                  {event.recurrence_label ? ` · ${event.recurrence_label}` : ""}
                </Text>
              </TouchableOpacity>
            ))}
          </View>
        )}

        {/* Where to find */}
        {host.totems.length > 0 && (
          <View style={styles.section}>
            <Text style={styles.sectionLabel}>WHERE TO FIND {firstName.toUpperCase()}</Text>
            {host.totems.map((totem) => (
              <TouchableOpacity
                key={totem.slug}
                style={styles.totemCard}
                onPress={() => router.push(`/(app)/totem/${totem.slug}` as any)}
                activeOpacity={0.85}
              >
                <Text style={styles.totemName}>{totem.name}</Text>
                {totem.neighborhood ? (
                  <Text style={styles.totemNeighborhood}>{totem.neighborhood}</Text>
                ) : null}
              </TouchableOpacity>
            ))}
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.paper },
  scroll: { paddingHorizontal: 20, paddingBottom: 60 },
  backButton: { paddingTop: 8, paddingBottom: 12 },
  backText: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
  notFound: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.stone,
    textAlign: "center",
    marginTop: 40,
  },
  eyebrow: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.stone,
    letterSpacing: 1.5,
    marginBottom: 8,
  },
  nameRow: { marginBottom: 8 },
  nameDisplay: {
    fontFamily: FontFamily.serifDisplay,
    fontSize: FontSize.display,
    color: Colors.ink,
    lineHeight: 40,
  },
  nameDisplayItalic: {
    fontStyle: "italic",
  },
  locationSummary: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
    marginBottom: 20,
  },
  storyPanel: {
    backgroundColor: "#fdf6f0",
    borderWidth: 1,
    borderColor: "#e8d5c4",
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
  },
  storyLabel: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.ember,
    letterSpacing: 1.5,
    marginBottom: 8,
  },
  storyBody: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.ink,
    lineHeight: 20,
  },
  followButton: {
    backgroundColor: Colors.ember,
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: "center",
    marginBottom: 8,
  },
  followButtonActive: {
    backgroundColor: Colors.white,
    borderWidth: 1,
    borderColor: Colors.border,
  },
  followButtonText: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.white,
  },
  followButtonTextActive: {
    color: Colors.stone,
  },
  followSubtext: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.xs,
    color: Colors.stone,
    textAlign: "center",
    marginBottom: 24,
  },
  section: { marginTop: 8, marginBottom: 16 },
  sectionLabel: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.stone,
    letterSpacing: 1.5,
    marginBottom: 12,
  },
  eventCard: {
    backgroundColor: Colors.white,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: Colors.border,
    padding: 14,
    marginBottom: 8,
  },
  eventTitle: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.ink,
    marginBottom: 2,
  },
  eventMeta: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
  totemCard: {
    backgroundColor: Colors.white,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: Colors.border,
    padding: 14,
    marginBottom: 8,
  },
  totemName: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.ink,
    marginBottom: 2,
  },
  totemNeighborhood: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.xs,
    color: Colors.stone,
    marginBottom: 4,
  },
  totemEventName: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
});
