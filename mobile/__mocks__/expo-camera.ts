import React from "react";
import { View } from "react-native";

export const CameraView = ({ children, ...props }: any) =>
  React.createElement(View, props, children);

export const useCameraPermissions = jest.fn(() => [{ granted: true }, jest.fn()]);
