import Toast from 'vue-toastification';

import EmojiPicker from '@/emoji_picker/EmojiPicker.vue';
import { renderApp } from '@/lib/customizedVue';

const app = renderApp(EmojiPicker);

app.use(Toast);
