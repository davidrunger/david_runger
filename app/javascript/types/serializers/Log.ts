// Typelizer digest 957c490afd9d9f8a4394dd009747ec0e
//
// DO NOT MODIFY: This file was automatically generated by Typelizer.
import type {UserSerializerBasic, LogShare} from '@/types'

type Log = {
  data_label: string;
  data_type: string;
  description: string | null;
  id: number;
  name: string;
  slug: string;
  publicly_viewable?: boolean;
  reminder_time_in_seconds?: number | null;
  user: UserSerializerBasic;
  log_shares?: Array<LogShare>;
}

export default Log;
