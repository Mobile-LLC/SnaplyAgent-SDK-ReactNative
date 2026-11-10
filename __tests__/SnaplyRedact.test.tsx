//
//  SnaplyRedact.test.tsx
//  @snaplyagent/react-native
//
//  Created by Gevorg Karapetyan on 11/10/26.
//  Copyright © 2026 iFixgroup. All rights reserved.
//

import React from 'react';
import { Text } from 'react-native';
import renderer, { act } from 'react-test-renderer';

import { SnaplyRedact } from '../src/SnaplyRedact';

function render(element: React.ReactElement) {
  let tree!: renderer.ReactTestRenderer;
  act(() => {
    tree = renderer.create(element);
  });
  return tree.toJSON() as renderer.ReactTestRendererJSON;
}

describe('SnaplyRedact', () => {
  it('is a real view carrying the mark the native SDKs look for', () => {
    const view = render(
      <SnaplyRedact>
        <Text>4242 4242 4242 4242</Text>
      </SnaplyRedact>,
    );
    expect(view.props.testID).toBe('snaply-redact');
    expect(view.props.collapsable).toBe(false);
    expect(view.children).toHaveLength(1);
  });

  it('keeps a testID of its own after the mark, and cannot be un-marked', () => {
    expect(render(<SnaplyRedact testID="card" />).props.testID).toBe(
      'snaply-redact-card',
    );
    const forced = render(
      <SnaplyRedact {...({ collapsable: true } as object)} />,
    );
    expect(forced.props.collapsable).toBe(false);
  });
});
