import Toast from 'vue-toastification';

import EmojiPicker from '@/emoji_picker/EmojiPicker.vue';
import { renderApp } from '@/shared/customized_vue';

const app = renderApp(EmojiPicker);

app.use(Toast);
