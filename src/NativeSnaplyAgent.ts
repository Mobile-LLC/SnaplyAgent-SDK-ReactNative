//
//  NativeSnaplyAgent.ts
//  @snaplyagent/react-native
//
//  Created by Gevorg Karapetyan on 11/10/26.
//  Copyright © 2026 iFixgroup. All rights reserved.
//

import type { CodegenTypes, TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export type SnaplyNativeEvent = {
  name: string;
  captureId?: string;
  imageUrl?: string;
  code?: string;
  message?: string;
  status?: CodegenTypes.Int32;
  active?: boolean;
  sessionId?: string;
};

export interface Spec extends TurboModule {
  configure(
    key: string,
    host: string | null,
    userId: string | null,
    userName: string | null,
    collectVendorId: boolean,
    language: string,
  ): Promise<void>;
  identify(
    id: string,
    name: string | null,
    phone: string | null,
    identitySignature: string | null,
  ): void;
  reset(): void;
  supportCode(): Promise<string | null>;
  showSupportCode(): void;
  stop(): void;
  readonly onSnaplyEvent: CodegenTypes.EventEmitter<SnaplyNativeEvent>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('SnaplyAgent');
