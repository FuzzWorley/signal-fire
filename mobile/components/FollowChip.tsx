import React from "react";
import { TouchableOpacity, Text, StyleSheet } from "react-native";
import { Colors } from "../constants/colors";
import { FontFamily, FontSize } from "../constants/typography";

interface Props {
  following: boolean;
  onToggle: () => void;
}

export function FollowChip({ following, onToggle }: Props) {
  return (
    <TouchableOpacity
      onPress={onToggle}
      style={[styles.chip, following && styles.chipFollowing]}
      activeOpacity={0.8}
    >
      <Text style={[styles.text, following && styles.textFollowing]}>
        {following ? "● Following" : "Follow"}
      </Text>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  chip: {
    borderWidth: 1,
    borderColor: Colors.border,
    borderRadius: 20,
    paddingHorizontal: 14,
    paddingVertical: 6,
    backgroundColor: Colors.white,
  },
  chipFollowing: {
    borderColor: Colors.ember,
    backgroundColor: Colors.emberLight,
  },
  text: {
    fontFamily: FontFamily.sansMedium,
    fontSize: FontSize.sm,
    color: Colors.stone,
  },
  textFollowing: {
    color: Colors.ember,
  },
});
