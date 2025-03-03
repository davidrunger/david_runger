export interface WorkoutCreateResponse {
    created_at:        string;
    id:                number;
    publicly_viewable: boolean;
    rep_totals:        { [key: string]: any };
    time_in_seconds:   number;
    username:          string;
}
