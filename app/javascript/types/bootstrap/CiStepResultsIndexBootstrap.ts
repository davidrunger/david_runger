export interface CiStepResultsIndexBootstrap {
    current_user:                 CurrentUser;
    nonce:                        string;
    recent_gantt_chart_metadatas: RecentGanttChartMetadata[];
}

interface CurrentUser {
    email: string;
    id:    number;
}

interface RecentGanttChartMetadata {
    branch:                 string;
    dom_id:                 string;
    github_run_attempt:     number;
    github_run_id:          number;
    pretty_github_run_info: string;
    pretty_start_time:      string;
    run_times:              RunTime[];
}

interface RunTime {
    name:       string;
    seconds:    number;
    started_at: string;
    stopped_at: string;
}
