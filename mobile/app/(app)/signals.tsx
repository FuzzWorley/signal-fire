import React, { useCallback } from "react";
import { useFocusEffect } from "expo-router";
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  Switch,
  ActivityIndicator,
  RefreshControl,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Colors } from "../../constants/colors";
import { FontFamily, FontSize } from "../../constants/typography";
import { useSubscriptions, TotemFollow, HostFollow } from "../../hooks/useSubscriptions";
import { api } from "../../services/api";
import { useAuth } from "../../hooks/useAuth";
import { posthog } from "../../services/analytics";

function FollowRow({
  follow,
  onUnfollow,
}: {
  follow: TotemFollow;
  onUnfollow: () => void;
}) {
  return (
    <View style={styles.itemCard}>
      <View style={styles.itemHeader}>
        <Text style={styles.itemName}>{follow.totem_name}</Text>
        <TouchableOpacity onPress={onUnfollow}>
          <Text style={styles.unfollowText}>Unfavorite</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

function HostFollowRow({
  host,
  onUnfollow,
}: {
  host: HostFollow;
  onUnfollow: () => void;
}) {
  return (
    <View style={styles.itemCard}>
      <View style={styles.itemHeader}>
        <Text style={styles.itemName}>{host.host_name}</Text>
        <TouchableOpacity onPress={onUnfollow}>
          <Text style={styles.unfollowText}>Unfollow</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

export default function SignalsScreen() {
  const {
    follows,
    hostFollows,
    loading,
    load,
    unfollow,
    unfollowHost,
  } = useSubscriptions();
  const { user, refreshUser } = useAuth();

  useFocusEffect(useCallback(() => {
    load();
    posthog.capture("signals_tab_viewed");
  }, [load]));

  const weeklyDigestOn  = user?.notification_prefs?.new_event !== false;
  const remindersOn     = user?.notification_prefs?.reminder  !== false;

  async function togglePref(key: "new_event" | "reminder", value: boolean) {
    await api.patch("/api/v1/me", { notification_prefs: { [key]: value } }).catch(() => {});
    refreshUser();
  }

  const isEmpty = follows.length === 0 && hostFollows.length === 0;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        refreshControl={
          <RefreshControl refreshing={loading} onRefresh={load} tintColor={Colors.ember} />
        }
      >
        <View style={styles.header}>
          <Text style={styles.eyebrow}>SIGNALS</Text>
          <Text style={styles.title}>Favorites & Follows</Text>
        </View>

        <View style={styles.masterCard}>
          <View style={styles.masterText}>
            <Text style={styles.masterLabel}>Weekly digest of what's happening</Text>
            <Text style={styles.masterSubtitle}>Thursday morning roundup of your spots</Text>
          </View>
          <Switch
            value={weeklyDigestOn}
            onValueChange={(v) => togglePref("new_event", v)}
            trackColor={{ false: Colors.border, true: Colors.ember }}
            thumbColor={Colors.white}
          />
        </View>

        <View style={[styles.masterCard, { marginTop: -10 }]}>
          <View style={styles.masterText}>
            <Text style={styles.masterLabel}>Reminders for events I've attended</Text>
            <Text style={styles.masterSubtitle}>1-hour heads-up before events you've been to</Text>
          </View>
          <Switch
            value={remindersOn}
            onValueChange={(v) => togglePref("reminder", v)}
            trackColor={{ false: Colors.border, true: Colors.ember }}
            thumbColor={Colors.white}
          />
        </View>

        {loading && follows.length === 0 && hostFollows.length === 0 ? (
          <ActivityIndicator color={Colors.ember} style={{ marginTop: 40 }} />
        ) : isEmpty ? (
          <View style={styles.empty}>
            <Text style={styles.emptyText}>
              Follow hosts and favorite places on any event page.
            </Text>
          </View>
        ) : (
          <>
            {follows.length > 0 && (
              <>
                <Text style={styles.sectionLabel}>
                  FAVORITE PLACES · {follows.length}
                </Text>
                {follows.map((f) => (
                  <FollowRow
                    key={f.id}
                    follow={f}
                    onUnfollow={() => unfollow(f.id)}
                  />
                ))}
              </>
            )}

            {hostFollows.length > 0 && (
              <>
                <Text style={[styles.sectionLabel, { marginTop: 20 }]}>
                  HOSTS YOU FOLLOW · {hostFollows.length}
                </Text>
                {hostFollows.map((h) => (
                  <HostFollowRow
                    key={h.id}
                    host={h}
                    onUnfollow={() => unfollowHost(h.id)}
                  />
                ))}
              </>
            )}
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.paper },
  scroll: { paddingHorizontal: 20, paddingBottom: 40 },
  header: { paddingTop: 20, marginBottom: 20 },
  eyebrow: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.stone,
    letterSpacing: 1,
    marginBottom: 4,
  },
  title: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.xxl,
    color: Colors.ink,
  },
  sectionLabel: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.stone,
    letterSpacing: 1,
    marginBottom: 10,
  },
  itemCard: {
    backgroundColor: Colors.white,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: Colors.border,
    padding: 14,
    marginBottom: 10,
  },
  itemHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "flex-start",
    marginBottom: 10,
  },
  itemName: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.ink,
  },
  unfollowText: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
  masterCard: {
    backgroundColor: Colors.white,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: Colors.border,
    padding: 14,
    marginBottom: 20,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  masterText: { flex: 1, marginRight: 12 },
  masterLabel: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.ink,
  },
  masterSubtitle: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
    marginTop: 2,
  },
  empty: { paddingTop: 60, alignItems: "center", paddingHorizontal: 20 },
  emptyText: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.stone,
    textAlign: "center",
    lineHeight: 22,
  },
});
