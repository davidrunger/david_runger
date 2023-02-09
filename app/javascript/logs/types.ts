export type LogEntryDataValue = string | number;
export type LogDataType = 'counter' | 'duration' | 'number' | 'text'

export type LogEntry = {
  id: number
  created_at: string
  data: LogEntryDataValue
  log_id: number
  note?: string
}

export type LogShare = {
  email: string
  id: number
}

export type Log = {
  id: number
  data_label: string
  data_type: LogDataType
  description: string
  log_entries: Array<LogEntry>
  log_shares: Array<LogShare>
  name: string
  publicly_viewable: boolean
  reminder_time_in_seconds: number
  slug: string
  user: {
    email: string
    id: number
  }
}

export type LogInputType = {
  data_type: LogDataType
  label: string
}

export type CurrentUser = {
  id: number
  email: string
}

export type Bootstrap = {
  current_user: CurrentUser
  logs: Array<Log>
  log_input_types: Array<LogInputType>
  toast_messages: Array<string>
}
