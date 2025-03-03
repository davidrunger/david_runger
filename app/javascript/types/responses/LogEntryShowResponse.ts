export interface LogEntryShowResponse {
    created_at?: string;
    data?:       number | string;
    id?:         number;
    log_id?:     number;
    note?:       null | string;
    [property: string]: any;
}
