import { TextLogEntry } from '@/logs/types';
import { LogEntry } from '@/types';

export function isArrayOfStrings(object: unknown): object is Array<string> {
  return (
    Array.isArray(object) &&
    object.every((element) => typeof element === 'string')
  );
}

export function isArrayOfTextLogEntries(
  logEntries: Array<LogEntry>,
): logEntries is Array<TextLogEntry> {
  return logEntries.every((logEntry) => typeof logEntry.data === 'string');
}

export function isElement(element: EventTarget | null): element is Element {
  return element instanceof Element;
}

export function isAnchorElement(
  element: EventTarget | null,
): element is HTMLAnchorElement {
  return element instanceof HTMLAnchorElement;
}

export function isMouseEvent(event: Event | null): event is MouseEvent {
  return event instanceof MouseEvent;
}
