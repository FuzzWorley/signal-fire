import React from "react";
import { View } from "react-native";

export const router = {
  push: jest.fn(),
  replace: jest.fn(),
  back: jest.fn(),
  canGoBack: jest.fn(() => true),
};

export const useLocalSearchParams = jest.fn(() => ({}));

export const useFocusEffect = jest.fn((cb: () => void) => cb());

export function Redirect({ href }: { href: string }) {
  return null;
}

const StackComponent = ({ children }: any) =>
  React.createElement(View, null, children);
StackComponent.Screen = () => null;
export const Stack = StackComponent;

const TabsComponent = ({ children }: any) =>
  React.createElement(View, null, children);
TabsComponent.Screen = () => null;
export const Tabs = TabsComponent;
