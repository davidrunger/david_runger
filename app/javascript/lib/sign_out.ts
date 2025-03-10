import { kyApi } from '@/lib/ky';
import {
  destroy_user_session_path,
  new_user_session_path,
} from '@/rails_assets/routes';

export async function signOut() {
  await kyApi.delete(destroy_user_session_path({ format: 'json' }));
  window.location.assign(new_user_session_path());
}
