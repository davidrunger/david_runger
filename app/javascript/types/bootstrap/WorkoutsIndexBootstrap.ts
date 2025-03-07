// This is a generated file. Do not edit this file directly.

export interface WorkoutsIndexBootstrap {
    current_user:    CurrentUser;
    nonce:           string;
    others_workouts: Workout[];
    workouts:        Workout[];
}

interface CurrentUser {
    default_workout: DefaultWorkout | null;
    email:           string;
    id:              number;
}

interface DefaultWorkout {
    exercises:    Exercise[];
    minutes:      number;
    numberOfSets: number;
}

interface Exercise {
    name: string;
    reps: number;
}

interface Workout {
    created_at:        string;
    id:                number;
    publicly_viewable: boolean;
    rep_totals:        { [key: string]: number };
    time_in_seconds:   number;
    username:          string;
}
