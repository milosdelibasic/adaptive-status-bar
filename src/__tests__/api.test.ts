const mockNative = {
  enable: jest.fn(),
  configure: jest.fn(),
  disable: jest.fn(),
  setOverride: jest.fn(),
  setHint: jest.fn(),
  resetStats: jest.fn(),
  getStats: jest.fn(async () =>
    JSON.stringify({ style: 'light', source: 'sample' }),
  ),
};
jest.mock('../specs/NativeSkyvistAdaptiveStatusBar', () => ({
  __esModule: true,
  default: mockNative,
}));

const { AdaptiveStatusBar: bar } = require('../AdaptiveStatusBar');

afterEach(() => {
  bar.clearOverride();
  bar.setHint(null);
  bar.disable();
  jest.clearAllMocks();
});

it('validates before enabling native sampling', () => {
  expect(() => bar.enable({ samplingInterval: 0 })).toThrow(RangeError);
  expect(mockNative.enable).not.toHaveBeenCalled();
  expect(bar.isEnabled).toBe(false);
});

it('retains configuration when updating one option', () => {
  bar.enable({ strategy: 'automatic', ios: { captureMethod: 'hierarchy' } });
  bar.configure({ performance: 'battery' });
  expect(JSON.parse(mockNative.configure.mock.calls[0][0])).toMatchObject({
    strategy: 'automatic',
    performance: 'battery',
    iosCaptureMethod: 'hierarchy',
  });
});

it('clears an override and returns control to native detection', () => {
  bar.setOverride('dark');
  bar.clearOverride();
  expect(mockNative.setOverride.mock.calls).toEqual([['dark'], [null]]);
});

it('reads native diagnostic snapshots asynchronously', async () => {
  await expect(bar.getStats()).resolves.toEqual({
    style: 'light',
    source: 'sample',
  });
});
