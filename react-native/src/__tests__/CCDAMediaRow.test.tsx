import React from 'react';
import renderer, {act} from 'react-test-renderer';
import {Image, NativeModules, Pressable, StyleSheet, Text} from 'react-native';
import {CCDAMediaRow} from '../components/CCDAMediaRow';
import {CCDADocumentView} from '../components/CCDADocumentView';
import {documentFixture} from './fixtures';
import type {CCDAMedia} from '../types';

const nativeOpen = NativeModules.CCDAKit.openMedia as jest.Mock;
const attachment = (kind = 'applicationPDF'): CCDAMedia => ({
  ...documentFixture.sections[0].media[0],
  mediaType: {kind},
  payload: {
    kind: 'cachedFile',
    filePath: '/tmp/sample.pdf',
    fileUri: 'file:///tmp/sample.pdf',
    byteCount: 100,
  },
});

beforeEach(() => {
  nativeOpen.mockReset();
  nativeOpen.mockResolvedValue(undefined);
});

it.each([
  'applicationPDF',
  'textPlain',
  'textHTML',
  'imagePNG',
  'imageJPEG',
  'imageGIF',
])('opens %s in the native preview', async kind => {
  const media = attachment(kind);
  const tree = renderer.create(<CCDAMediaRow media={media} />);
  await act(async () => {
    await tree.root.findByType(Pressable).props.onPress();
  });
  expect(nativeOpen).toHaveBeenCalledWith(media);
});

it('loads cached and inline images without reserving a fixed preview height', () => {
  const tree = renderer.create(<CCDAMediaRow media={attachment('imagePNG')} />);
  expect(tree.root.findByType(Image).props.source.uri).toBe(
    'file:///tmp/sample.pdf',
  );
  expect(
    StyleSheet.flatten(tree.root.findByType(Image).props.style).height,
  ).toBe(1);
  act(() =>
    tree.update(
      <CCDAMediaRow
        media={{
          ...attachment('imagePNG'),
          payload: {kind: 'inlineBase64', value: 'aW1hZ2U='},
        }}
      />,
    ),
  );
  expect(tree.root.findByType(Image).props.source.uri).toBe(
    'data:image/png;base64,aW1hZ2U=',
  );
});

it('keeps small images at their natural size and scales large images within the row', () => {
  const tree = renderer.create(<CCDAMediaRow media={attachment('imagePNG')} />);
  act(() => {
    tree.root
      .findByType(Pressable)
      .props.onLayout({nativeEvent: {layout: {width: 220}}});
    tree.root
      .findByType(Image)
      .props.onLoad({nativeEvent: {source: {width: 64, height: 32}}});
  });
  expect(
    StyleSheet.flatten(tree.root.findByType(Image).props.style),
  ).toMatchObject({width: 64, height: 32});
  act(() => {
    tree.root
      .findByType(Image)
      .props.onLoad({nativeEvent: {source: {width: 1200, height: 600}}});
  });
  expect(
    StyleSheet.flatten(tree.root.findByType(Image).props.style),
  ).toMatchObject({width: 200, height: 100});
  act(() => {
    tree.root
      .findByType(Image)
      .props.onLoad({nativeEvent: {source: {width: 600, height: 1200}}});
  });
  expect(
    StyleSheet.flatten(tree.root.findByType(Image).props.style),
  ).toMatchObject({width: 90, height: 180});
});

it('shows compact document actions without byte counts or image space', () => {
  const tree = renderer.create(<CCDAMediaRow media={attachment()} />);
  expect(tree.root.findAllByType(Image)).toHaveLength(0);
  const text = tree.root
    .findAllByType(Text)
    .map(node => node.props.children)
    .join(' ');
  expect(text).toContain('Open PDF');
  expect(text).not.toContain('bytes');
  expect(text).not.toContain('100');
});

it('uses a host handler instead of the built-in preview', async () => {
  const media = attachment();
  const onOpen = jest.fn();
  const tree = renderer.create(<CCDAMediaRow media={media} onOpen={onOpen} />);
  await act(async () => {
    await tree.root.findByType(Pressable).props.onPress();
  });
  expect(onOpen).toHaveBeenCalledWith(media);
  expect(nativeOpen).not.toHaveBeenCalled();
});

it('passes the document-level handler to default attachment rows', async () => {
  const media = attachment();
  const onOpenMedia = jest.fn();
  const document = {
    ...documentFixture,
    sections: [{...documentFixture.sections[0], media: [media]}],
  };
  const tree = renderer.create(
    <CCDADocumentView document={document} onOpenMedia={onOpenMedia} />,
  );
  await act(async () => {
    await tree.root.findByType(Pressable).props.onPress();
  });
  expect(onOpenMedia).toHaveBeenCalledWith(media);
  expect(nativeOpen).not.toHaveBeenCalled();
});

it('shows preview failures without leaving the button disabled', async () => {
  nativeOpen.mockRejectedValueOnce(new Error('Attachment file was removed'));
  const tree = renderer.create(<CCDAMediaRow media={attachment()} />);
  await act(async () => {
    await tree.root.findByType(Pressable).props.onPress();
  });
  expect(
    tree.root.findAllByType(Text).map(text => text.props.children),
  ).toContain('Attachment file was removed');
  expect(tree.root.findByType(Pressable).props.disabled).toBe(false);
});

it('keeps unsupported or missing payloads informational, while allowing host overrides', () => {
  const unsupported = {
    ...attachment('unsupported'),
    mediaType: {kind: 'unsupported', mimeType: 'application/custom'},
  };
  const tree = renderer.create(<CCDAMediaRow media={unsupported} />);
  expect(tree.root.findAllByType(Pressable)).toHaveLength(0);
  act(() =>
    tree.update(
      <CCDAMediaRow
        media={{...attachment(), payload: {kind: 'unavailable'}}}
      />,
    ),
  );
  expect(tree.root.findAllByType(Pressable)).toHaveLength(0);
  act(() =>
    tree.update(<CCDAMediaRow media={unsupported} onOpen={() => {}} />),
  );
  expect(tree.root.findAllByType(Pressable)).toHaveLength(1);
});

it('keeps the action busy until the host finishes opening the preview', async () => {
  let finish!: () => void;
  const onOpen = jest.fn(
    () =>
      new Promise<void>(resolve => {
        finish = resolve;
      }),
  );
  const tree = renderer.create(
    <CCDAMediaRow media={attachment()} onOpen={onOpen} />,
  );
  let pending!: Promise<void>;
  act(() => {
    pending = tree.root.findByType(Pressable).props.onPress();
  });
  expect(tree.root.findByType(Pressable).props.disabled).toBe(true);
  expect(tree.root.findByType(Pressable).props.accessibilityState.busy).toBe(
    true,
  );
  await act(async () => {
    finish();
    await pending;
  });
  expect(tree.root.findByType(Pressable).props.disabled).toBe(false);
});

it('hides a failed thumbnail and resets dimensions for a different image', () => {
  const tree = renderer.create(<CCDAMediaRow media={attachment('imagePNG')} />);
  act(() => {
    tree.root.findByType(Image).props.onError();
  });
  expect(tree.root.findAllByType(Image)).toHaveLength(0);
  expect(tree.root.findAllByType(Pressable)).toHaveLength(1);
  act(() =>
    tree.update(
      <CCDAMediaRow
        media={{
          ...attachment('imagePNG'),
          payload: {
            kind: 'cachedFile',
            filePath: '/tmp/other.png',
            fileUri: 'file:///tmp/other.png',
            byteCount: 50,
          },
        }}
      />,
    ),
  );
  expect(tree.root.findAllByType(Image)).toHaveLength(1);
  expect(
    StyleSheet.flatten(tree.root.findByType(Image).props.style).height,
  ).toBe(1);
});

it('reports a synchronous host error and allows retrying the action', async () => {
  const onOpen = jest.fn().mockImplementationOnce(() => {
    throw new Error('Host preview failed');
  });
  const tree = renderer.create(
    <CCDAMediaRow media={attachment()} onOpen={onOpen} />,
  );
  await act(async () => {
    await tree.root.findByType(Pressable).props.onPress();
  });
  expect(
    tree.root.findAllByType(Text).map(text => text.props.children),
  ).toContain('Host preview failed');
  await act(async () => {
    await tree.root.findByType(Pressable).props.onPress();
  });
  expect(onOpen).toHaveBeenCalledTimes(2);
  expect(
    tree.root.findAllByType(Text).map(text => text.props.children),
  ).not.toContain('Host preview failed');
});
