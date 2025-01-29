import * as RoutesType from '@/rails_assets/routes';
import { kyApi } from '@/shared/ky';

declare const Routes: typeof RoutesType;

export async function signOut() {
  await kyApi.delete(Routes.destroy_user_session_path({ format: 'json' }));
  window.location.assign('/login');
}
