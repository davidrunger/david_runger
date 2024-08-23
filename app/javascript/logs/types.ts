import { JsonBroadcast } from '@/shared/types';
import type { Log as TypelizerLog, UserSerializerBasic } from '@/types';

export type LogEntryDataValue = string | number;
export type LogDataType = 'counter' | 'duration' | 'number' | 'text';

export interface LogEntry {
  id: number;
  created_at: string;
  data: LogEntryDataValue;
  log_id: number;
  note?: string;
}

export interface TextLogEntry extends LogEntry {
  data: string;
}

export interface Log extends TypelizerLog {
  data_type: LogDataType;
  log_entries?: Array<LogEntry>;
}

export type LogInput = {
  data_type: LogDataType;
  label: string;
};

export type Bootstrap = {
  current_user: UserSerializerBasic;
  logs: Array<Log>;
  log_input_types: Array<LogInput>;
  toast_messages: Array<string>;
};

export interface LogEntryBroadcast extends JsonBroadcast {
  model: LogEntry;
}
