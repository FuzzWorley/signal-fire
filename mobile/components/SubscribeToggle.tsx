import React from "react";
import { View, Text, Switch, StyleSheet } from "react-native";
import { Colors } from "../constants/colors";
import { FontFamily, FontSize } from "../constants/typography";

interface Props {
  label: string;
  subscribed: boolean;
  onToggle: (value: boolean) => void;
}

export function SubscribeToggle({ label, subscribed, onToggle }: Props) {
  return (
    <View style={styles.row}>
      <Text style={styles.label}>{label}</Text>
      <Switch
        value={subscribed}
        onValueChange={onToggle}
        trackColor={{ false: Colors.border, true: Colors.ember }}
        thumbColor={Colors.white}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  row: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginTop: 10,
  },
  label: {
    fontFamily: FontFamily.sans,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
});
