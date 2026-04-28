export const requestPermissionsAsync = jest.fn(() =>
  Promise.resolve({ status: "granted" })
);

export const getPermissionsAsync = jest.fn(() =>
  Promise.resolve({ status: "denied" })
);

export const getExpoPushTokenAsync = jest.fn(() =>
  Promise.resolve({ data: "ExponentPushToken[test-token]" })
);

export const setNotificationHandler = jest.fn();

export const setNotificationChannelAsync = jest.fn(() => Promise.resolve());

export const addNotificationResponseReceivedListener = jest.fn(() => ({
  remove: jest.fn(),
}));

export const getLastNotificationResponseAsync = jest.fn(() =>
  Promise.resolve(null)
);

export const AndroidImportance = {
  MAX: 5,
  HIGH: 4,
  DEFAULT: 3,
  LOW: 2,
  MIN: 1,
};
