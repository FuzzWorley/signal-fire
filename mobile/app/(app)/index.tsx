import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  ScrollView,
  StyleSheet,
  TouchableOpacity,
  RefreshControl,
  ActivityIndicator,
} from "react-native";
import { router } from "expo-router";
import { SafeAreaView } from "react-native-safe-area-context";
import { Colors } from "../../constants/colors";
import { FontFamily, FontSize } from "../../constants/typography";
import { api } from "../../services/api";

interface ActiveEvent {
  slug: string;
  title: string;
  window_state: string;
  start_time: string;
}

interface NextEvent {
  slug: string;
  title: string;
  next_occurrence: string;
  recurrence_type: string;
}

interface Board {
  totem_slug: string;
  totem_name: string;
  active_event: ActiveEvent | null;
  next_event: NextEvent | null;
}

function formatNext(iso: string, recurrenceType: string): string {
  const d = new Date(iso);
  const day = d.toLocaleDateString("en-US", { weekday: "short" });
  const time = d.toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" });
  return recurrenceType === "weekly" ? `Next: ${day} · ${time}` : `Next: ${d.toLocaleDateString("en-US", { month: "short", day: "numeric" })} · ${time}`;
}

function BoardCard({ board }: { board: Board }) {
  const { totem_slug, totem_name, active_event, next_event } = board;
  const isHappeningNow = active_event?.window_state === "happening_now";

  return (
    <TouchableOpacity
      style={[styles.boardCard, isHappeningNow && styles.boardCardActive]}
      onPress={() => router.push(`/totem/${totem_slug}`)}
      activeOpacity={0.8}
    >
      <Text style={styles.boardTotemName}>{totem_name.toUpperCase()}</Text>

      {active_event ? (
        <>
          {isHappeningNow && (
            <View style={styles.happeningChip}>
              <Text style={styles.happeningChipText}>HAPPENING NOW</Text>
            </View>
          )}
          <Text style={styles.boardEventTitle}>{active_event.title}</Text>
          <Text style={styles.boardMeta}>
            Live — started {new Date(active_event.start_time).toLocaleTimeString("en-US", { hour: "numeric", minute: "2-digit" })}
          </Text>
        </>
      ) : next_event ? (
        <>
          <Text style={styles.boardEventTitle}>{next_event.title}</Text>
          <Text style={styles.boardMeta}>
            {formatNext(next_event.next_occurrence, next_event.recurrence_type)}
          </Text>
        </>
      ) : (
        <Text style={styles.boardMeta}>Nothing scheduled yet</Text>
      )}
    </TouchableOpacity>
  );
}

export default function HomeScreen() {
  const [boards, setBoards] = useState<Board[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  async function loadBoards() {
    try {
      const res = await api.get<{ boards: Board[] }>("/api/v1/home");
      setBoards(res.boards);
    } catch {
      setBoards([]);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  }

  useEffect(() => {
    loadBoards();
  }, []);

  function onRefresh() {
    setRefreshing(true);
    loadBoards();
  }

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor={Colors.ember} />}
      >
        <View style={styles.header}>
          <Text style={styles.headerLabel}>HOME</Text>
          <Text style={styles.title}>Your boards</Text>
        </View>

        <TouchableOpacity
          style={styles.scanButton}
          onPress={() => router.push("/(app)/scan")}
          activeOpacity={0.85}
        >
          <Text style={styles.scanButtonText}>Scan a totem</Text>
        </TouchableOpacity>

        {loading ? (
          <ActivityIndicator color={Colors.ember} style={{ marginTop: 40 }} />
        ) : boards.length === 0 ? (
          <View style={styles.empty}>
            <View style={styles.emptyIcon} />
            <Text style={styles.emptyTitle}>No totems yet</Text>
            <Text style={styles.emptyBody}>
              Scan an orange totem at a park, court, or hall. Follow the ones you want to keep up with.
            </Text>
            <TouchableOpacity
              style={styles.emptyScanButton}
              onPress={() => router.push("/(app)/scan")}
              activeOpacity={0.85}
            >
              <Text style={styles.emptyScanButtonText}>Scan a totem</Text>
            </TouchableOpacity>
          </View>
        ) : (
          <>
            <Text style={styles.sectionLabel}>
              FOLLOWING · {boards.length} {boards.length === 1 ? "TOTEM" : "TOTEMS"}
            </Text>
            {boards.map((board) => (
              <BoardCard key={board.totem_slug} board={board} />
            ))}
          </>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: Colors.paper },
  scroll: { paddingHorizontal: 20, paddingBottom: 40 },
  header: { paddingTop: 20, marginBottom: 16 },
  headerLabel: {
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
  scanButton: {
    backgroundColor: Colors.ember,
    borderRadius: 10,
    paddingVertical: 14,
    alignItems: "center",
    marginBottom: 24,
  },
  scanButtonText: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.white,
  },
  sectionLabel: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.stone,
    letterSpacing: 1,
    marginBottom: 10,
  },
  boardCard: {
    backgroundColor: Colors.white,
    borderRadius: 10,
    borderWidth: 1,
    borderColor: Colors.border,
    padding: 14,
    marginBottom: 10,
  },
  boardCardActive: {
    borderColor: Colors.ember,
    backgroundColor: Colors.emberLight,
  },
  boardTotemName: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.stone,
    letterSpacing: 0.5,
    marginBottom: 4,
  },
  happeningChip: {
    alignSelf: "flex-start",
    backgroundColor: Colors.ember,
    paddingHorizontal: 8,
    paddingVertical: 3,
    borderRadius: 4,
    marginBottom: 6,
  },
  happeningChipText: {
    fontFamily: FontFamily.mono,
    fontSize: FontSize.xs,
    color: Colors.white,
    letterSpacing: 0.5,
  },
  boardEventTitle: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.lg,
    color: Colors.ink,
    marginBottom: 3,
  },
  boardMeta: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
  empty: { alignItems: "center", paddingTop: 60, paddingHorizontal: 20 },
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
  },
  emptyBody: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.base,
    color: Colors.stone,
    textAlign: "center",
    lineHeight: 22,
    marginBottom: 28,
  },
  emptyScanButton: {
    backgroundColor: Colors.ember,
    borderRadius: 10,
    paddingVertical: 14,
    paddingHorizontal: 32,
    alignItems: "center",
  },
  emptyScanButtonText: {
    fontFamily: FontFamily.sansSemiBold,
    fontSize: FontSize.base,
    color: Colors.white,
  },
});
