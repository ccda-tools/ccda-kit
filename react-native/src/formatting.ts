import type {CCDAAddress, CCDATimestamp, CCDAValue} from './types';

/** Preserve source precision and wall-clock time, as the native renderers do. */
export function formatTimestamp(timestamp: CCDATimestamp): string {
  const {
    year,
    month,
    day,
    hour,
    minute,
    second,
    fractionalSecond,
    timeZoneOffset,
  } = timestamp;
  const monthName =
    month == null
      ? null
      : new Intl.DateTimeFormat(undefined, {
          month: 'short',
          timeZone: 'UTC',
        }).format(new Date(Date.UTC(2000, month - 1, 1)));
  let text =
    monthName == null
      ? String(year)
      : day == null
      ? `${monthName} ${year}`
      : `${monthName} ${day}, ${year}`;
  if (hour != null) {
    const pad = (value: number) => String(value).padStart(2, '0');
    let time = String(hour % 12 || 12);
    if (minute != null) {
      time += `:${pad(minute)}`;
      if (second != null) {
        time += `:${pad(second)}`;
        if (fractionalSecond) time += `.${fractionalSecond}`;
      }
    }
    text += ` at ${time} ${hour < 12 ? 'AM' : 'PM'}`;
  }
  if (timeZoneOffset) {
    text += ` ${
      /^[+-]\d{4}$/.test(timeZoneOffset)
        ? `UTC${timeZoneOffset.slice(0, 3)}:${timeZoneOffset.slice(3)}`
        : timeZoneOffset
    }`;
  }
  return text;
}

export function formatAddress(address: CCDAAddress): string {
  return [
    ...address.streetLines,
    [address.city, address.state, address.postalCode].filter(Boolean).join(' '),
    address.country,
  ]
    .filter(Boolean)
    .join('\n');
}

export function formatValue(value: CCDAValue): string {
  return (
    value.displayName ??
    [value.value ?? value.code, value.unit].filter(Boolean).join(' ')
  );
}
