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
