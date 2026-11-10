//
//  SnaplyRedact.tsx
//  @snaplyagent/react-native
//
//  Created by Gevorg Karapetyan on 11/10/26.
//  Copyright © 2026 iFixgroup. All rights reserved.
//

import React from 'react';
import { View, type ViewProps } from 'react-native';

/** The mark the native SDKs look for in a view's `testID`. */
export const SNAPLY_REDACT_MARK = 'snaply-redact';

/**
 * Hides its children in every screenshot and live frame, and locks them for remote control. The box is
 * painted on the device before the image is encoded.
 */
export function SnaplyRedact({ children, testID, ...props }: ViewProps) {
  return (
    <View
      {...props}
      collapsable={false}
      testID={testID ? `${SNAPLY_REDACT_MARK}-${testID}` : SNAPLY_REDACT_MARK}
    >
      {children}
    </View>
  );
}
