import React, { useState } from 'react';
import { authService } from '../../../services/authService';

export default function ForgotPasswordCard() {
  const [email, setEmail] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [message, setMessage] = useState(null); // { type: 'success' | 'error', text: string }

  const handleSubmit = async (event) => {
    event?.preventDefault();
    if (!email?.trim()) {
      setMessage({ type: 'error', text: 'Please enter the email associated with your account.' });
      return;
    }

    setSubmitting(true);
    setMessage(null);

    try {
      const result = await authService?.resetPassword(email?.trim());

      if (result?.success) {
        setMessage({
          type: 'success',
          text:
            result?.message ||
            'Check your inbox for a password reset link. The email may take a few minutes to arrive.',
        });
      } else {
        setMessage({
          type: 'error',
          text: result?.error || 'We could not send a reset link. Please try again.',
        });
      }
    } catch (err) {
      console.error('Login reset password error:', err);
      setMessage({
        type: 'error',
        text: 'An unexpected error occurred while sending the reset link. Please try again.',
      });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="bg-white py-6 px-6 shadow rounded-lg space-y-4">
      <h2 className="text-lg font-semibold text-gray-900 text-center">Forgot your password?</h2>
      <p className="text-sm text-gray-600 text-center">
        Enter your email address and we&apos;ll send you a link to reset your password.
      </p>

      {message ? (
        <div
          className={`p-3 rounded-md text-sm ${
            message.type === 'success'
              ? 'bg-green-50 text-green-700 border border-green-200'
              : 'bg-red-50 text-red-700 border border-red-200'
          }`}
        >
          {message.text}
        </div>
      ) : null}

      <form onSubmit={handleSubmit} className="space-y-3">
        <div>
          <label htmlFor="reset-email" className="block text-sm font-medium text-gray-700">
            Email Address
          </label>
          <input
            id="reset-email"
            type="email"
            autoComplete="email"
            required
            value={email}
            onChange={(event) => setEmail(event?.target?.value)}
            className="mt-1 block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
            placeholder="you@example.com"
            disabled={submitting}
          />
        </div>

        <button
          type="submit"
          disabled={submitting}
          className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {submitting ? 'Sending reset link...' : 'Send reset link'}
        </button>
      </form>
    </div>
  );
}
