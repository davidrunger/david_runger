import { kyApi } from '@/shared/ky';

export function signOut() {
  kyApi.delete(Routes.destroy_user_session_path({ format: 'json' })).
    then(() => { window.location.assign('/login'); });
}
