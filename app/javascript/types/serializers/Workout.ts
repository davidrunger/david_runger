// Typelizer digest dc28bd7e28d6b1a363352ef1a033c3be
//
// DO NOT MODIFY: This file was automatically generated by Typelizer.
import type {RepTotals} from '@/types'

type Workout = {
  created_at: string;
  id: number;
  publicly_viewable: boolean;
  time_in_seconds: number;
  rep_totals: RepTotals;
  username: string;
}

export default Workout;
