const mockClient = {
  capture: jest.fn(),
  identify: jest.fn(),
  reset: jest.fn(),
};

export default jest.fn(() => mockClient);
export const usePostHog = jest.fn(() => mockClient);
export const PostHogProvider = ({ children }: { children: React.ReactNode }) => children;
