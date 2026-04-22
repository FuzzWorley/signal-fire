import React from "react";
import { View } from "react-native";

export const SafeAreaView = ({ children, style }: any) =>
  React.createElement(View, { style }, children);

export const SafeAreaProvider = ({ children }: any) =>
  React.createElement(View, null, children);

export const useSafeAreaInsets = () => ({ top: 0, right: 0, bottom: 0, left: 0 });
