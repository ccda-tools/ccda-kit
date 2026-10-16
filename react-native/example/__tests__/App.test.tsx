import React from 'react';
import {Button, Pressable, Text} from 'react-native';
import renderer, {act} from 'react-test-renderer';
import {readFileSync} from 'node:fs';
import path from 'node:path';
import {parseCCDAXml} from '@ccda-tools/react-native';
import {NativeStackView} from '@react-navigation/native-stack';
import App from '../App';
import {samples} from '../src/samples';

jest.mock('@ccda-tools/react-native', () => {
  const ReactRuntime = require('react');
  const NativeText = require('react-native').Text;
  return {
    parseCCDAXml: jest.fn(),
    useCCDATheme: () => require('../../src/theme').CCDATheme.light,
    CCDADocumentView: ({document}: {document: {header: {title: string}}}) =>
      ReactRuntime.createElement(NativeText, null, document.header.title),
  };
});

const parseXml = parseCCDAXml as jest.Mock;
let screen: renderer.ReactTestRenderer;

beforeEach(() => {
  parseXml.mockReset();
  parseXml.mockResolvedValue({header: {title: 'Parsed shared document'}});
  act(() => {
    screen = renderer.create(<App />);
  });
});

afterEach(() => {
  act(() => screen.unmount());
});

it('lists the same seven samples in the same order as the native iOS example', () => {
  const nativeSource = readFileSync(
    path.resolve(
      __dirname,
      '../../../apple/Examples/iOS/Example/ContentView.swift',
    ),
    'utf8',
  );
  const nativeFilenames = [
    ...nativeSource.matchAll(/filename: "([^"]+)"/g),
  ].map(match => match[1]);
  expect(samples.map(sample => sample.filename)).toEqual(nativeFilenames);
  expect(
    screen.root
      .findAllByType(Pressable)
      .map(row => row.props.accessibilityLabel),
  ).toEqual(samples.map(sample => sample.title));
  expect(parseXml).not.toHaveBeenCalled();
});

it.each(samples)(
  'opens the shared XML for $title and returns to the list',
  async sample => {
    const row = screen.root
      .findAllByType(Pressable)
      .find(item => item.props.accessibilityLabel === sample.title)!;
    await act(async () => {
      row.props.onPress();
    });
    const xml = readFileSync(
      path.resolve(
        __dirname,
        '../../../test-data/ccda/samples',
        `${sample.filename}.xml`,
      ),
      'utf8',
    );
    expect(parseXml).toHaveBeenCalledWith(xml);
    expect(
      screen.root
        .findAllByType(Text)
        .some(text => text.props.children === 'Parsed shared document'),
    ).toBe(true);
    const stack = screen.root.findByType(NativeStackView);
    const route = stack.props.state.routes[stack.props.state.index];
    expect(route.name).toBe('Document');
    expect(route.params).toEqual({filename: sample.filename});
    expect(stack.props.descriptors[route.key].options.title).toBe(sample.title);
    act(() => {
      stack.props.descriptors[route.key].navigation.goBack();
    });
    expect(
      screen.root.findByType(NativeStackView).props.state.routes,
    ).toHaveLength(1);
    expect(screen.root.findAllByType(Pressable)).toHaveLength(samples.length);
  },
);

it('shows a parsing error and allows retrying the selected document', async () => {
  parseXml.mockRejectedValueOnce(new Error('Unable to parse sample'));
  await act(async () => {
    screen.root.findAllByType(Pressable)[0].props.onPress();
  });
  expect(
    screen.root
      .findAllByType(Text)
      .some(text => text.props.children === 'Unable to parse sample'),
  ).toBe(true);
  await act(async () => {
    screen.root
      .findAllByType(Button)
      .find(button => button.props.title === 'Retry')!
      .props.onPress();
  });
  expect(parseXml).toHaveBeenCalledTimes(2);
  expect(
    screen.root
      .findAllByType(Text)
      .some(text => text.props.children === 'Parsed shared document'),
  ).toBe(true);
});
