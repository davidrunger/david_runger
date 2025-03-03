export type LogEntriesIndexResponse = Array<LogEntriesIndexResponseElement>

interface LogEntriesIndexResponseElement {
    created_at: string;
    data:       number | string;
    id:         number;
    log_id:     number;
    note:       null | string;
}

