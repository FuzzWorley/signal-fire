// Global fetch mock — individual tests control return values via mockResolvedValueOnce
global.fetch = jest.fn();

beforeEach(() => {
  (global.fetch as jest.Mock).mockReset();
});
