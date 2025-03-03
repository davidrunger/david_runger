export interface GroceriesIndexBootstrap {
    current_user:  CurrentUser;
    nonce:         string;
    own_stores:    Store[];
    spouse:        CurrentUser | null;
    spouse_stores: Store[];
}

interface CurrentUser {
    email: string;
    id:    number;
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
