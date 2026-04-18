import React from "react";
import { View, Text, StyleSheet } from "react-native";
import { Colors } from "../constants/colors";
import { FontFamily, FontSize } from "../constants/typography";

interface Props {
  eventTitle: string;
}

export function YouAreHereBanner({ eventTitle }: Props) {
  return (
    <View style={styles.banner}>
      <Text style={styles.text}>● You're here · checked in to {eventTitle}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  banner: {
    backgroundColor: Colors.emberLight,
    borderWidth: 1,
    borderColor: Colors.ember,
    borderRadius: 8,
    paddingVertical: 10,
    paddingHorizontal: 14,
    marginBottom: 14,
  },
  text: {
    fontFamily: FontFamily.sansMedium,
    fontSize: FontSize.sm,
    color: Colors.ember,
    textAlign: "center",
  },
});
