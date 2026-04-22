export const requestPermissionsAsync = jest.fn(() =>
  Promise.resolve({ status: "granted" })
);

export const getExpoPushTokenAsync = jest.fn(() =>
  Promise.resolve({ data: "ExponentPushToken[test-token]" })
);
