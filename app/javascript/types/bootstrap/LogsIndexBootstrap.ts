export interface LogsIndexBootstrap {
    current_user?:                  User;
    log_input_types:                LogInputType[];
    log_selector_keyboard_shortcut: string;
    logs:                           Log[];
    nonce:                          string;
    toast_messages?:                string[];
}

interface User {
    email: string;
    id:    number;
}

interface LogInputType {
    data_type: string;
    label:     string;
}

interface Log {
    data_label:                string;
    data_type:                 string;
    description:               null | string;
    id:                        number;
    log_shares?:               User[];
    name:                      string;
    publicly_viewable?:        boolean;
    reminder_time_in_seconds?: number | null;
    slug:                      string;
    user:                      User;
}
