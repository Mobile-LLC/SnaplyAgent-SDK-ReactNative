//
//  index.test.ts
//  @snaplyagent/react-mockNative
//
//  Created by Gevorg Karapetyan on 11/10/26.
//  Copyright © 2026 iFixgroup. All rights reserved.
//

const mockNative = {
  configure: jest.fn<Promise<void>, unknown[]>(async () => {}),
  identify: jest.fn(),
  reset: jest.fn(),
  supportCode: jest.fn(async () => '40-291'),
  showSupportCode: jest.fn(),
  stop: jest.fn(),
  listener: undefined as undefined | ((event: Record<string, unknown>) => void),
  onSnaplyEvent: jest.fn(
    (listener: (event: Record<string, unknown>) => void) => {
      mockNative.listener = listener;
      return { remove: jest.fn() };
    },
  ),
};

// The import below is hoisted above the object this refers to, so the module reads it lazily.
jest.mock('../src/NativeSnaplyAgent', () => ({
  __esModule: true,
  get default() {
    return mockNative;
  },
}));

import { Snaply, SnaplyError } from '../src/index';

describe('Snaply', () => {
  it('configure sends the key, the host, the user and the options', async () => {
    await Snaply.configure({
      key: 'snap_live_abc',
      environment: 'http://10.0.2.2:5100',
      user: { id: 'usr_1', name: 'Maya' },
      collectVendorId: false,
      language: 'hy',
    });
    expect(mockNative.configure).toHaveBeenLastCalledWith(
      'snap_live_abc',
      'http://10.0.2.2:5100',
      'usr_1',
      'Maya',
      false,
      'hy',
    );
  });

  it('the live environment is sent as no host at all, with the defaults', async () => {
    await Snaply.configure({ key: 'snap_live_abc' });
    expect(mockNative.configure).toHaveBeenLastCalledWith(
      'snap_live_abc',
      null,
      null,
      null,
      true,
      'en',
    );
  });

  it('a native failure arrives as a SnaplyError with its code and status', async () => {
    mockNative.configure.mockRejectedValueOnce({
      code: 'origin_mismatch',
      message: 'The key does not allow this app.',
      userInfo: { status: 403 },
    });
    await expect(
      Snaply.configure({ key: 'snap_live_abc' }),
    ).rejects.toMatchObject({
      name: 'SnaplyError',
      code: 'origin_mismatch',
      status: 403,
    });
  });

  it('identify passes what is given and null for the rest', () => {
    Snaply.identify({ id: 'usr_1', phone: '+14155550142' });
    expect(mockNative.identify).toHaveBeenLastCalledWith(
      'usr_1',
      null,
      '+14155550142',
      null,
    );
  });

  it('native events reach the callbacks, and only the one named', () => {
    const seen: string[] = [];
    Snaply.on({
      onRequestShown: () => seen.push('shown'),
      onAllowed: capture => seen.push(`allowed ${capture.captureId}`),
      onRemoteControl: active => seen.push(`control ${active}`),
      onLiveEnded: id => seen.push(`ended ${id}`),
      onError: error =>
        seen.push(
          `error ${error instanceof SnaplyError} ${error.code} ${error.status}`,
        ),
    });
    expect(mockNative.onSnaplyEvent).toHaveBeenCalledTimes(1);

    mockNative.listener?.({ name: 'requestShown' });
    mockNative.listener?.({
      name: 'allowed',
      captureId: 'c1',
      imageUrl: '/u/1',
    });
    mockNative.listener?.({ name: 'remoteControl', active: true });
    mockNative.listener?.({ name: 'liveEnded', sessionId: 's1' });
    mockNative.listener?.({
      name: 'error',
      code: 'quota_exceeded',
      status: 429,
    });
    mockNative.listener?.({ name: 'denied' });

    expect(seen).toEqual([
      'shown',
      'allowed c1',
      'control true',
      'ended s1',
      'error true quota_exceeded 429',
    ]);
  });
});
