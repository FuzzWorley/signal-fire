import React, { useEffect, useCallback } from "react";
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  RefreshControl,
  ActivityIndicator,
} from "react-native";
import { useLocalSearchParams, router } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";
import { Colors } from "../../constants/colors";
import { FontFamily, FontSize } from "../../constants/typography";
import { useTotem, Event } from "../../hooks/useTotem";
import { EventCard } from "../../components/EventCard";
import { FollowChip } from "../../components/FollowChip";
import { YouAreHereBanner } from "../../components/YouAreHereBanner";
import { api } from "../../services/api";
import { getToken } from "../../services/api";

export default function TotemBoardScreen() {
  const { slug } = useLocalSearchParams<{ slug: string }>();
  const { totem, loading, error, load, toggleFollow, setTotem } = useTotem(slug);

  useEffect(() => {
    load();
  }, [slug]);

  const checkedInEvent = totem?.active_now.find((e) => e.user_checked_in);

  async function handleSubscribe(event: Event, subscribed: boolean) {
    if (subscribed) {
      await api.post("/api/v1/host_subscriptions", { host_user_id: event.host.id }).catch(() => {});
    } else {
      await api.delete(`/api/v1/host_subscriptions/${event.host.id}`).catch(() => {});
    }
    setTotem((t) => {
      if (!t) return t;
      const updateEvents = (events: Event[]) =>
        events.map((e) =>
          e.host.id === event.host.id ? { ...e, subscribed_to_host: subscribed } : e
        );
      return {
        ...t,
        active_now: updateEvents(t.active_now),
        upcoming: updateEvents(t.upcoming),
      };
    });
  }

  const seenHostIds = new Set<number>();

  if (loading) {
    return (
      <SafeAreaView style={styles.container}>
        <ActivityIndicator color={Colors.ember} style={{ flex: 1 }} />
      </SafeAreaView>
    );
  }

  if (error || !totem) {
    return (
      <SafeAreaView style={styles.container}>
        <View style={styles.errorContainer}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            <Text style={styles.backText}>‹ Back</Text>
          </TouchableOpacity>
          <Text style={styles.errorText}>{error ?? "Totem not found"}</Text>
        </View>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        refreshControl={
          <RefreshControl refreshing={loading} onRefresh={load} tintColor={Colors.ember} />
        }
      >
        {/* Header */}
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            <Text style={styles.backText}>‹ Back</Text>
          </TouchableOpacity>

          <View style={styles.titleRow}>
            <View style={styles.titleBlock}>
              <Text style={styles.eyebrow}>TOTEM</Text>
              <Text style={styles.totemName}>{totem.name}</Text>
              {totem.location_description ? (
                <Text style={styles.location}>{totem.location_description}</Text>
              ) : null}
            </View>
            {totem.following !== null && (
              <FollowChip following={totem.following} onToggle={toggleFollow} />
            )}
          </View>
        </View>

        {/* You're here banner */}
        {checkedInEvent && (
          <YouAreHereBanner eventTitle={checkedInEvent.title} />
        )}

        {/* Active Now section */}
        {totem.active_now.length > 0 && (
          <>
            <Text style={styles.sectionLabel}>● ACTIVE NOW</Text>
            {totem.active_now.map((event) => {
              const showSubscribe = !seenHostIds.has(event.host.id);
              if (showSubscribe) seenHostIds.add(event.host.id);
              return (
                <EventCard
                  key={event.id}
                  event={event}
                  onPress={() => router.push(`/totem/${slug}/${event.slug}`)}
                  showSubscribeToggle={showSubscribe && event.subscribed_to_host !== null}
                  onSubscribeChange={(v) => handleSubscribe(event, v)}
                />
              );
            })}
          </>
        )}

        {/* Upcoming section */}
        {totem.upcoming.length > 0 && (
          <>
            <Text style={[styles.sectionLabel, totem.active_now.length > 0 && { marginTop: 20 }]}>
              UPCOMING
            </Text>
            {totem.upcoming.map((event) => {
              const showSubscribe = !seenHostIds.has(event.host.id);
              if (showSubscribe) seenHostIds.add(event.host.id);
              return (
                <EventCard
                  key={event.id}
                  event={event}
                  onPress={() => router.push(`/totem/${slug}/${event.slug}`)}
                  showSubscribeToggle={showSubscribe && event.subscribed_to_host !== null}
                  onSubscribeChange={(v) => handleSubscribe(event, v)}
                />
              );
            })}
          </>
        )}

        {/* Empty state */}
        {totem.empty && totem.active_now.length === 0 && totem.upcoming.length === 0 && (
          <View style={styles.empty}>
            <View style={styles.emptyIcon} />
            <Text style={styles.emptyTitle}>This spot isn't active yet</Text>
            <Text style={styles.emptyBody}>
              Nothing's been scheduled here yet. Check back soon.
            </Text>
          </View>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.paper },
  scroll: { paddingHorizontal: 20, paddingBottom: 40 },
  errorContainer: { flex: 1, padding: 20 },
  errorText: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.stone,
    textAlign: "center",
    marginTop: 40,
  },
  header: { paddingTop: 8, marginBottom: 16 },
  backButton: { paddingVertical: 8 },
  backText: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.stone,
  },
  titleRow: {
    flexDirection: "row",
    alignItems: "flex-start",
    justifyContent: "space-between",
    marginTop: 8,
  },
  titleBlock: { flex: 1, marginRight: 12 },
  eyebrow: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.stone,
    letterSpacing: 1,
    marginBottom: 4,
  },
  totemName: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.xxl,
    color: Colors.ink,
    marginBottom: 2,
  },
  location: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
  sectionLabel: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.stone,
    letterSpacing: 1,
    marginBottom: 10,
  },
  empty: { alignItems: "center", paddingTop: 48, paddingHorizontal: 20 },
  emptyIcon: {
    width: 60,
    height: 60,
    borderRadius: 30,
    borderWidth: 1.5,
    borderColor: Colors.border,
    borderStyle: "dashed",
    marginBottom: 20,
  },
  emptyTitle: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.xl,
    color: Colors.ink,
    marginBottom: 10,
    textAlign: "center",
  },
  emptyBody: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.stone,
    textAlign: "center",
    lineHeight: 22,
  },
});
