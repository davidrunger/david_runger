export interface EmojiPickerIndexBootstrap {
    current_user?: CurrentUser;
    nonce:         string;
}

interface CurrentUser {
    email:        string;
    emoji_boosts: EmojiBoost[];
    id:           number;
}

interface EmojiBoost {
    boostedName: string;
    symbol:      string;
}
