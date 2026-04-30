import { useEffect, useState } from 'react';
import { exchangeCodeForTokens, getLoginUrl } from './api';

export function CallbackHandler() {
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const handleCallback = async () => {
      try {
        // Get the authorization code from URL
        const params = new URLSearchParams(window.location.search);
        const code = params.get('code');
        const errorParam = params.get('error');

        if (errorParam) {
          setError(`Authentication failed: ${errorParam}`);
          setLoading(false);
          return;
        }

        if (!code) {
          setError('No authorization code received');
          setLoading(false);
          return;
        }

        // Exchange code for tokens
        const { user } = await exchangeCodeForTokens(code);

        // Redirect to home page
        window.location.href = '/';
      } catch (err) {
        console.error('Callback error:', err);
        setError(`Authentication error: ${err.message}`);
        setLoading(false);
      }
    };

    handleCallback();
  }, []);

  if (loading) {
    return (
      <div style={{ textAlign: 'center', padding: '40px' }}>
        <h2>Authenticating...</h2>
        <p>Please wait while we process your login.</p>
      </div>
    );
  }

  if (error) {
    return (
      <div style={{ textAlign: 'center', padding: '40px', color: 'red' }}>
        <h2>Authentication Failed</h2>
        <p>{error}</p>
        <button onClick={() => (window.location.href = getLoginUrl())}>
          Try Again
        </button>
      </div>
    );
  }

  return null;
}
