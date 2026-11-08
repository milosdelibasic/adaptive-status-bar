import { useEffect, useState } from 'react';

import { stacks } from './AdaptiveStatusBar';
import type { IconStyle } from './types';

const useStackEntry = (
  stack: typeof stacks.overrides,
  style: IconStyle | null,
) => {
  const [key] = useState(() => ({}));
  useEffect(() => {
    stack.set(key, style);
    return () => stack.set(key, null);
  }, [stack, key, style]);
};

export const useStatusBarOverride = (style: IconStyle | null): void => {
  useStackEntry(stacks.overrides, style);
};

export const useStatusBarHint = (style: IconStyle | null): void => {
  useStackEntry(stacks.hints, style);
};
