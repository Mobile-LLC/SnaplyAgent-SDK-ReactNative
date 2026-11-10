//
//  index.tsx
//  @snaplyagent/react-native
//
//  Created by Gevorg Karapetyan on 11/10/26.
//  Copyright © 2026 iFixgroup. All rights reserved.
//

import NativeSnaplyAgent, { type SnaplyNativeEvent } from './NativeSnaplyAgent';

export { SnaplyRedact, SNAPLY_REDACT_MARK } from './SnaplyRedact';

/** A failure the SDK reports: `invalid_key`, `origin_mismatch`, `quota_exceeded`, … */
export class SnaplyError extends Error {
  readonly code: string;
  readonly status: number;

  constructor(code: string, message: string, status = 0) {
    super(message);
    this.name = 'SnaplyError';
    this.code = code;
    this.status = status;
  }
}

export type SnaplyUser = { id: string; name?: string };

export type SnaplyCapture = { captureId: string; imageUrl: string };

export type SnaplyConfiguration = {
  /** Console → Products → your product → API key. An iOS and an Android product each have their own. */
  key: string;
  /** A self-hosted host, or a backend on your own machine. Plain `http` is accepted for loopback only. */
  environment?: string;
  user?: SnaplyUser;
  collectVendorId?: boolean;
  language?: string;
};

export type SnaplyIdentity = {
  id: string;
  name?: string;
  /** E.164. */
  phone?: string;
  /** Computed on your server. */
  identitySignature?: string;
};

/** What the SDK tells the app. Every callback is optional. */
export type SnaplyCallbacks = {
  onRequestShown?: () => void;
  onAllowed?: (capture: SnaplyCapture) => void;
  onDenied?: () => void;
  onExpired?: () => void;
  onError?: (error: SnaplyError) => void;
  /** Remote control started (`true`) after the person allowed it, or ended. */
  onRemoteControl?: (active: boolean) => void;
  /** Live view stopped; the argument is the session's id. */
  onLiveEnded?: (sessionId: string) => void;
};

let callbacks: SnaplyCallbacks = {};
let listening = false;

function listen() {
  if (listening) {
    return;
  }
  listening = true;
  NativeSnaplyAgent.onSnaplyEvent(dispatch);
}

function dispatch(event: SnaplyNativeEvent) {
  switch (event.name) {
    case 'requestShown':
      callbacks.onRequestShown?.();
      break;
    case 'allowed':
      callbacks.onAllowed?.({
        captureId: event.captureId ?? '',
        imageUrl: event.imageUrl ?? '',
      });
      break;
    case 'denied':
      callbacks.onDenied?.();
      break;
    case 'expired':
      callbacks.onExpired?.();
      break;
    case 'error':
      callbacks.onError?.(
        new SnaplyError(
          event.code ?? 'error',
          event.message ?? '',
          event.status ?? 0,
        ),
      );
      break;
    case 'remoteControl':
      callbacks.onRemoteControl?.(event.active === true);
      break;
    case 'liveEnded':
      callbacks.onLiveEnded?.(event.sessionId ?? '');
      break;
  }
}

/** Snaply Agent. Call `configure` once at app start; nothing else is needed for captures to work. */
export const Snaply = {
  /** Registers this device and connects. */
  async configure(configuration: SnaplyConfiguration): Promise<void> {
    listen();
    try {
      await NativeSnaplyAgent.configure(
        configuration.key,
        configuration.environment ?? null,
        configuration.user?.id ?? null,
        configuration.user?.name ?? null,
        configuration.collectVendorId ?? true,
        configuration.language ?? 'en',
      );
    } catch (error) {
      const native = error as {
        code?: string;
        message?: string;
        userInfo?: { status?: number };
      };
      throw new SnaplyError(
        native.code ?? 'error',
        native.message ?? 'error',
        native.userInfo?.status ?? 0,
      );
    }
  },

  /** Observe SDK events. Attach before `configure`: a request can arrive as soon as the device registers. */
  on(next: SnaplyCallbacks): void {
    callbacks = next;
    listen();
  },

  /** Attaches the signed-in person. */
  identify(identity: SnaplyIdentity): void {
    NativeSnaplyAgent.identify(
      identity.id,
      identity.name ?? null,
      identity.phone ?? null,
      identity.identitySignature ?? null,
    );
  },

  /** Detaches the person, on sign-out. The device keeps its support code. */
  reset(): void {
    NativeSnaplyAgent.reset();
  },

  /** The code an anonymous caller reads to the agent. */
  supportCode(): Promise<string | null> {
    return NativeSnaplyAgent.supportCode();
  },

  /** Shows the support code in the SDK's own sheet. */
  showSupportCode(): void {
    NativeSnaplyAgent.showSupportCode();
  },

  /** Disconnects and removes any visible prompt. */
  stop(): void {
    NativeSnaplyAgent.stop();
  },
};
