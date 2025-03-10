import { JsonBroadcast } from '@/lib/types';
import type {
  Intersection,
  LogEntry,
  Log as TypelizerLog,
  UserSerializerBasic,
} from '@/types';
import { LogsIndexBootstrap } from '@/types/bootstrap/LogsIndexBootstrap';

export type LogDataType = 'counter' | 'duration' | 'number' | 'text';

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

export type Bootstrap = Intersection<
  {
    current_user: UserSerializerBasic;
    logs: Array<Log>;
    log_input_types: Array<LogInput>;
    log_selector_keyboard_shortcut: string;
    toast_messages: Array<string>;
  },
  LogsIndexBootstrap
>;

export interface LogEntryBroadcast extends JsonBroadcast {
  model: LogEntry;
}
