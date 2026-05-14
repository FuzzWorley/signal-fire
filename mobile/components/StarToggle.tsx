import React from "react";
import { TouchableOpacity, StyleSheet } from "react-native";
import Svg, { Polygon } from "react-native-svg";
import { Colors } from "../constants/colors";

interface Props {
  favorited: boolean;
  onToggle: () => void;
  size?: number;
}

export function StarToggle({ favorited, onToggle, size = 24 }: Props) {
  return (
    <TouchableOpacity
      onPress={onToggle}
      style={styles.button}
      activeOpacity={0.7}
      accessibilityRole="button"
      accessibilityLabel={favorited ? "Remove from favorites" : "Add to favorites"}
      accessibilityState={{ selected: favorited }}
    >
      <Svg width={size} height={size} viewBox="0 0 24 24">
        <Polygon
          points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"
          fill={favorited ? Colors.ink : "none"}
          stroke={Colors.ink}
          strokeWidth="1.5"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </Svg>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  button: {
    padding: 6,
  },
});
