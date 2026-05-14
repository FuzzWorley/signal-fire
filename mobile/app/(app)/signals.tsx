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
  active,
  onUnfollow,
  onUpdatePref,
}: {
  follow: TotemFollow;
  active: boolean;
  onUnfollow: () => void;
  onUpdatePref: (key: "notify_new_event" | "notify_reminder", val: boolean) => void;
}) {
  return (
    <View style={[styles.itemCard, !active && styles.itemCardMuted]}>
      <View style={styles.itemHeader}>
        <View>
          <Text style={styles.itemName}>{follow.totem_name}</Text>
        </View>
        <TouchableOpacity onPress={onUnfollow}>
          <Text style={styles.unfollowText}>Unfollow</Text>
        </TouchableOpacity>
      </View>
      <View style={styles.toggleRow}>
        <Text style={styles.toggleLabel}>New event</Text>
        <Switch
          value={active && follow.notify_new_event}
          onValueChange={(v) => onUpdatePref("notify_new_event", v)}
          trackColor={{ false: Colors.border, true: Colors.ember }}
          thumbColor={Colors.white}
          disabled={!active}
        />
        <Text style={[styles.toggleLabel, { marginLeft: 16 }]}>Reminder</Text>
        <Switch
          value={active && follow.notify_reminder}
          onValueChange={(v) => onUpdatePref("notify_reminder", v)}
          trackColor={{ false: Colors.border, true: Colors.ember }}
          thumbColor={Colors.white}
          disabled={!active}
        />
      </View>
    </View>
  );
}

function HostFollowRow({
  host,
  active,
  onUnfollow,
  onUpdatePref,
}: {
  host: HostFollow;
  active: boolean;
  onUnfollow: () => void;
  onUpdatePref: (key: "notify_new_event" | "notify_reminder", val: boolean) => void;
}) {
  return (
    <View style={[styles.itemCard, !active && styles.itemCardMuted]}>
      <View style={styles.itemHeader}>
        <View>
          <Text style={styles.itemName}>{host.host_name}</Text>
        </View>
        <TouchableOpacity onPress={onUnfollow}>
          <Text style={styles.unfollowText}>Unfollow</Text>
        </TouchableOpacity>
      </View>
      <View style={styles.toggleRow}>
        <Text style={styles.toggleLabel}>New event</Text>
        <Switch
          value={active && host.notify_new_event}
          onValueChange={(v) => onUpdatePref("notify_new_event", v)}
          trackColor={{ false: Colors.border, true: Colors.ember }}
          thumbColor={Colors.white}
          disabled={!active}
        />
        <Text style={[styles.toggleLabel, { marginLeft: 16 }]}>Reminder</Text>
        <Switch
          value={active && host.notify_reminder}
          onValueChange={(v) => onUpdatePref("notify_reminder", v)}
          trackColor={{ false: Colors.border, true: Colors.ember }}
          thumbColor={Colors.white}
          disabled={!active}
        />
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
    updateFollow,
    updateHostFollow,
  } = useSubscriptions();
  const { user, refreshUser } = useAuth();

  useFocusEffect(useCallback(() => {
    load();
    posthog.capture("signals_tab_viewed");
  }, [load]));

  const allNotifications = user?.notification_prefs?.all !== false;

  async function toggleAllNotifications(value: boolean) {
    posthog.capture("master_notifications_toggled", { value });
    await api.patch("/api/v1/me", { notification_prefs: { all: value } }).catch(() => {});
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
            <Text style={styles.masterLabel}>All notifications</Text>
            <Text style={styles.masterSubtitle}>Master toggle — turns everything off</Text>
          </View>
          <Switch
            value={allNotifications}
            onValueChange={toggleAllNotifications}
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
                    active={allNotifications}
                    onUnfollow={() => unfollow(f.totem_id)}
                    onUpdatePref={(key, val) => updateFollow(f.id, { [key]: val })}
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
                    active={allNotifications}
                    onUnfollow={() => unfollowHost(h.host_user_id)}
                    onUpdatePref={(key, val) => updateHostFollow(h.id, { [key]: val })}
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
  itemCardMuted: {
    opacity: 0.45,
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
  toggleRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  toggleLabel: {
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
