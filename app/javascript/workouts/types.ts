export type RepTotals = { [key:string]: number }

export type Exercise = {
  name: string
  reps: number
}

export type WorkoutPlan = {
  minutes: number
  numberOfSets: number
  exercises: Array<Exercise>
};

export type NewWorkoutAttributes = {
  publiclyViewable: boolean
  repTotals: RepTotals
  timeInSeconds: number
}

export type Workout = {
  created_at: string
  id: number
  publicly_viewable: boolean
  rep_totals: RepTotals
  time_in_seconds: number
  username: string
}

export type Bootstrap = {
  current_user: {
    id: number
  }
  others_workouts: Array<Workout>
  workouts: Array<Workout>
}
