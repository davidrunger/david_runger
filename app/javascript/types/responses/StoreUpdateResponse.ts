export interface StoreUpdateResponse {
    id:        number;
    items:     Item[];
    name:      string;
    notes:     null | string;
    own_store: boolean;
    private:   boolean;
    viewed_at: string;
}

interface Item {
    id:       number;
    name:     string;
    needed:   number;
    store_id: number;
}
