export interface LogEntryCreateResponse {
    created_at: string;
    data:       number | string;
    id:         number;
    log_id:     number;
    note:       null | string;
}
