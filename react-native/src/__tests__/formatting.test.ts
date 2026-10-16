import {formatAddress, formatTimestamp, formatValue} from '../formatting';
import type {CCDATimestamp} from '../types';

const timestamp = (parts: Partial<CCDATimestamp>): CCDATimestamp => ({
  year: 2026,
  rawValue: '2026',
  hasTime: false,
  ...parts,
});

describe('clinical display formatting', () => {
  it('does not invent missing date or time components', () => {
    expect(formatTimestamp(timestamp({}))).toBe('2026');
    expect(formatTimestamp(timestamp({month: 1}))).toBe('Jan 2026');
    expect(formatTimestamp(timestamp({month: 1, day: 15}))).toBe(
      'Jan 15, 2026',
    );
    expect(
      formatTimestamp(timestamp({month: 1, day: 15, hour: 0, hasTime: true})),
    ).toBe('Jan 15, 2026 at 12 AM');
  });

  it('preserves wall-clock time, fractional precision, and the source offset', () => {
    expect(
      formatTimestamp(
        timestamp({
          month: 1,
          day: 15,
          hour: 14,
          minute: 5,
          second: 9,
          fractionalSecond: '120',
          timeZoneOffset: '-0500',
          hasTime: true,
        }),
      ),
    ).toBe('Jan 15, 2026 at 2:05:09.120 PM UTC-05:00');
  });

  it('keeps measurement units and coded display labels', () => {
    expect(formatValue({value: '120', unit: 'mmHg'})).toBe('120 mmHg');
    expect(formatValue({displayName: 'Negative', code: 'NEG'})).toBe(
      'Negative',
    );
    expect(formatValue({code: 'NEG'})).toBe('NEG');
  });

  it('formats address lines without missing-field placeholders', () => {
    expect(
      formatAddress({
        use: 'home',
        streetLines: ['123 Test Street', 'Unit 2'],
        city: 'Test City',
        state: 'CA',
        postalCode: '00000',
        country: 'US',
      }),
    ).toBe('123 Test Street\nUnit 2\nTest City CA 00000\nUS');
    expect(formatAddress({use: 'unknown', streetLines: []})).toBe('');
  });
});
