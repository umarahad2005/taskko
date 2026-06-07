/**
 * pages/index.tsx — admin console entry point.
 *
 * The whole console depends on the Firebase Web SDK (browser-only), so we load
 * the LoginGate with SSR disabled. The gate signs the admin in and reveals the
 * console only when the `admin` custom claim is present (FR-11.1/11.9).
 */
import dynamic from 'next/dynamic';

const LoginGate = dynamic(() => import('../components/LoginGate').then((m) => m.LoginGate), {
  ssr: false,
});

export default function AdminHome() {
  return <LoginGate />;
}
