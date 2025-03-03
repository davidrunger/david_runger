export interface StoresIndexResponse {
    own_stores:    Store[];
    spouse_stores: Store[];
}

interface Store {
    id:        number;
    items:     Item[];
    name:      string;
    notes:     null | string;
    own_store: boolean;
    private:   boolean;
    viewed_at: string | null;
}

interface Item {
    id:       number;
    name:     string;
    needed:   number;
    store_id: number;
}
