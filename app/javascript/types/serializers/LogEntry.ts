// Typelizer digest ea5bdac88547a11638dea52d4790ea45
//
// DO NOT MODIFY: This file was automatically generated by Typelizer.
import type {LogEntryDataValue} from '@/types'

type LogEntry = {
  id: number;
  log_id: number;
  note: string | null;
  created_at: string;
  data: LogEntryDataValue;
}

export default LogEntry;
