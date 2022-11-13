import { kyApi } from '@/shared/ky';

export async function signOut() {
  await kyApi.delete(Routes.destroy_user_session_path({ format: 'json' }));
  window.location.assign('/login');
}
