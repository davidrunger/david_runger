import { http } from '@/lib/http';
import {
  destroy_user_session_path,
  new_user_session_path,
} from '@/rails_assets/routes';

export async function signOut() {
  await http.delete(destroy_user_session_path({ format: 'json' }));
  window.location.assign(new_user_session_path());
}
