import { supabase } from '../lib/supabaseClient';

export const authService = {
  // NEW: Get session context using the new RPC
  async getSessionContext() {
    try {
      const { data, error } = await supabase?.rpc('get_session_context');
      
      if (error) {
        return { 
          success: false, 
          error: error?.message || 'Session validation failed'
        };
      }

      // Return the single JSON object response
      return data || { success: false, error: 'No session data received' };
    } catch (error) {
      return { 
        success: false, 
        error: 'Network error. Please try again.'
      };
    }
  },

  // NEW: Set current tenant
  async setCurrentTenant(tenantId) {
    try {
      const { data, error } = await supabase?.rpc('set_current_tenant', { 
        p_tenant_id: tenantId 
      });
      
      if (error) {
        return { 
          success: false, 
          error: error?.message || 'Failed to set tenant'
        };
      }

      return data || { success: false, error: 'No response received' };
    } catch (error) {
      return { 
        success: false, 
        error: 'Network error. Please try again.'
      };
    }
  },

  // NEW: Create tenant and assign current user
  async createTenantAndAssign(name, slug) {
    try {
      const { data, error } = await supabase?.rpc('create_tenant_and_assign', {
        p_name: name,
        p_slug: slug
      });
      
      if (error) {
        return { 
          success: false, 
          error: error?.message || 'Failed to create tenant'
        };
      }

      return data || { success: false, error: 'No response received' };
    } catch (error) {
      return { 
        success: false, 
        error: 'Network error. Please try again.'
      };
    }
  },

  // Sign in with email and password - Updated to use new context
  async signIn(email, password) {
    try {
      const { data, error } = await supabase?.auth?.signInWithPassword({
        email,
        password,
      });
      
      if (error) {
        return { 
          success: false, 
          error: error?.message || 'Login failed'
        };
      }

      // Use new session context instead of manual profile fetching
      if (data?.user) {
        const contextResult = await this.getSessionContext();
        
        return {
          success: true,
          data: {
            user: data?.user,
            context: contextResult
          }
        };
      }

      return { success: false, error: 'Invalid login response' };
    } catch (error) {
      return { 
        success: false, 
        error: 'An unexpected error occurred during sign in'
      };
    }
  },

  // Sign up with email and password - Updated with proper redirect URLs
  async signUp(signUpData) {
    try {
      // Get current origin for proper redirect URLs
      const currentOrigin = window.location?.origin;
      
      // Configure signup with redirect URL for email confirmation
      const signUpConfig = {
        ...signUpData,
        options: {
          ...signUpData?.options,
          // Fixed redirect URL to use current domain instead of localhost:3000
          emailRedirectTo: `${currentOrigin}/magic-link-authentication`
        }
      };

      const { data, error } = await supabase?.auth?.signUp(signUpConfig);

      if (error) {
        return { 
          success: false, 
          error: error?.message || 'Registration failed'
        };
      }

      if (data?.user && !data?.user?.email_confirmed_at) {
        return {
          success: true,
          data: data?.user,
          message: 'Account created successfully! Please check your email to verify your account before signing in.',
          requiresVerification: true
        };
      }

      return {
        success: true,
        data: data?.user,
        message: 'Account created and verified successfully!'
      };
    } catch (error) {
      return { 
        success: false, 
        error: 'An unexpected error occurred during registration'
      };
    }
  },

  // Sign out
  async signOut() {
    try {
      const { error } = await supabase?.auth?.signOut();
      
      if (error) {
        return { 
          success: false, 
          error: error?.message || 'Sign out failed'
        };
      }
      
      return { success: true };
    } catch (error) {
      return { 
        success: false, 
        error: 'An unexpected error occurred during sign out'
      };
    }
  },

  // Get current session
  async getCurrentSession() {
    try {
      const { data: { session }, error } = await supabase?.auth?.getSession();
      
      if (error) {
        return { success: false, error: error?.message };
      }
      
      return { success: true, session };
    } catch (error) {
      return { success: false, error: 'Network error. Please try again.' };
    }
  },

  // Get current user profile - Updated to use new context
  async getUserProfile(userId) {
    if (!userId) return { success: false, error: 'No user ID provided' };
    
    try {
      // Use the new session context instead of direct profile query
      const contextResult = await this.getSessionContext();
      
      if (contextResult?.success && contextResult?.user_data) {
        return { 
          success: true, 
          profile: contextResult?.user_data 
        };
      }
      
      return { 
        success: false, 
        error: contextResult?.message || 'Failed to load user profile' 
      };
    } catch (error) {
      return { success: false, error: 'Failed to load user profile' };
    }
  },

  // Update user profile
  async updateUserProfile(userId, updates) {
    if (!userId) return { success: false, error: 'No user ID provided' };
    
    try {
      const { data, error } = await supabase?.from('user_profiles')?.update(updates)?.eq('id', userId)?.select()?.single();
      
      if (error) {
        return { success: false, error: error?.message };
      }
      
      return { success: true, profile: data };
    } catch (error) {
      return { success: false, error: 'Failed to update profile' };
    }
  },

  // Reset password - Fixed redirect URL
  async resetPassword(email) {
    try {
      // Get current origin for proper redirect URL
      const currentOrigin = window.location?.origin;
      
      const { error } = await supabase?.auth?.resetPasswordForEmail(email, {
        // Fixed redirect URL to use current domain instead of localhost:3000
        redirectTo: `${currentOrigin}/magic-link-authentication`
      });
      
      if (error) {
        return { 
          success: false, 
          error: error?.message || 'Password reset failed'
        };
      }
      
      return { 
        success: true, 
        message: 'Password reset email sent. Please check your inbox and follow the instructions to reset your password.' 
      };
    } catch (error) {
      return { 
        success: false, 
        error: 'An unexpected error occurred during password reset'
      };
    }
  },

  // Admin function to force password reset for users without passwords
  async adminForcePasswordReset(userEmail) {
    try {
      // Call the password reset but with admin privileges
      const result = await this.resetPassword(userEmail);
      
      if (result?.success) {
        return {
          success: true,
          message: `Password reset email sent to ${userEmail}. User can now create a password using the link.`
        };
      } else {
        return result;
      }
    } catch (error) {
      return {
        success: false,
        error: 'Failed to send password reset email'
      };
    }
  },

  // Send magic link for passwordless authentication - Fixed redirect URL
  async sendMagicLink(email) {
    try {
      // Get current origin for proper redirect URL
      const currentOrigin = window?.location?.origin;
      
      const { error } = await supabase?.auth?.signInWithOtp({
        email,
        options: {
          // Fixed redirect URL to use current domain instead of localhost:3000
          emailRedirectTo: `${currentOrigin}/magic-link-authentication`
        }
      });
      
      if (error) {
        return { 
          success: false, 
          error: error?.message || 'Magic link sending failed'
        };
      }
      
      return { 
        success: true, 
        message: 'Magic link sent! Please check your email and click the link to sign in.' 
      };
    } catch (error) {
      return { 
        success: false, 
        error: 'An unexpected error occurred while sending magic link'
      };
    }
  },

  // Update password (for authenticated users)
  async updatePassword(newPassword) {
    try {
      const { error } = await supabase?.auth?.updateUser({
        password: newPassword
      });
      
      if (error) {
        return { 
          success: false, 
          error: error?.message || 'Password update failed'
        };
      }
      
      return { 
        success: true, 
        message: 'Password updated successfully!' 
      };
    } catch (error) {
      return { 
        success: false, 
        error: 'An unexpected error occurred while updating password'
      };
    }
  },

  // Get current user
  async getCurrentUser() {
    try {
      const { data: { user }, error } = await supabase?.auth?.getUser();
      
      if (error) {
        return { success: false, error: error?.message };
      }

      if (user) {
        // Use new session context
        const contextResult = await this.getSessionContext();
        
        return {
          success: true,
          data: {
            user,
            context: contextResult
          }
        };
      }

      return { success: false, error: 'No user found' };
    } catch (error) {
      return { success: false, error: 'Failed to get current user' };
    }
  },

  // Check if user is authenticated
  async isAuthenticated() {
    try {
      const { data: { user } } = await supabase?.auth?.getUser();
      return !!user;
    } catch (error) {
      return false;
    }
  },

  // Multi-tenant: Create organization account (for MVP admin use)
  async createOrganizationAccount(organizationData, adminUserData) {
    try {
      // First create the admin user
      const signUpResult = await this.signUp({
        email: adminUserData?.email,
        password: adminUserData?.password,
        options: {
          data: {
            full_name: adminUserData?.fullName,
            role: 'admin',
            organization: organizationData?.name,
          },
        },
      });

      if (!signUpResult?.success) {
        return signUpResult;
      }

      return {
        success: true,
        data: {
          organization: organizationData,
          adminUser: signUpResult?.data
        },
        message: 'Organization account created successfully!'
      };
    } catch (error) {
      return {
        success: false,
        error: 'Failed to create organization account'
      };
    }
  },

  // Get all team members (reps and managers) for current user's tenant
  async getTeamMembers(userRole = null) {
    try {
      let query = supabase
        ?.from('user_profiles')
        ?.select('id, full_name, email, role, is_active, created_at')
        ?.eq('is_active', true)
        ?.order('full_name', { ascending: true });

      // Filter by role if specified
      if (userRole) {
        query = query?.eq('role', userRole);
      }

      const { data, error } = await query;
      
      if (error) {
        return { success: false, error: error?.message };
      }
      
      return { success: true, data: data || [] };
    } catch (error) {
      return { success: false, error: 'Failed to load team members' };
    }
  },

  // Get representatives (users with role='rep') for goals assignment
  async getRepresentatives() {
    return this.getTeamMembers('rep');
  },

  // Get all users by tenant (admin function)
  async getUsersByTenant(tenantId = null) {
    try {
      let query = supabase
        ?.from('user_profiles')
        ?.select('id, full_name, email, role, is_active, created_at, tenant_id')
        ?.order('full_name', { ascending: true });

      // Filter by tenant if specified
      if (tenantId) {
        query = query?.eq('tenant_id', tenantId);
      }

      const { data, error } = await query;
      
      if (error) {
        return { success: false, error: error?.message };
      }
      
      return { success: true, data: data || [] };
    } catch (error) {
      return { success: false, error: 'Failed to load users' };
    }
  },

  // Admin function to create user with temporary password
  async createUserWithTempPassword(userData) {
    try {
      // Call the database function to create user with temp password
      const { data, error } = await supabase?.rpc('admin_create_temp_password_user', {
        user_email: userData?.email,
        user_full_name: userData?.fullName,
        user_role: userData?.role || 'rep',
        user_phone: userData?.phone || null,
        user_organization: userData?.organization || null
      });

      if (error) {
        return {
          success: false,
          error: error?.message || 'Failed to create user'
        };
      }

      if (data && data?.length > 0) {
        const result = data?.[0];
        if (result?.success) {
          return {
            success: true,
            data: {
              email: userData?.email,
              tempPassword: result?.temp_password
            },
            message: 'User created successfully with temporary password'
          };
        } else {
          return {
            success: false,
            error: result?.message || 'Failed to create user'
          };
        }
      }

      return {
        success: false,
        error: 'Unexpected response from user creation'
      };
    } catch (error) {
      return {
        success: false,
        error: 'Failed to create user account'
      };
    }
  },

  // Setup password after email confirmation
  async setupPassword(email, password, profileData = {}) {
    try {
      const { data, error } = await supabase?.rpc('setup_user_password', {
        user_email: email,
        new_password: password,
        profile_data: profileData
      });

      if (error) {
        return {
          success: false,
          error: error?.message || 'Failed to setup password'
        };
      }

      if (data && data?.length > 0) {
        const result = data?.[0];
        if (result?.success) {
          return {
            success: true,
            data: {
              userId: result?.user_id
            },
            message: result?.message || 'Password setup completed successfully'
          };
        } else {
          return {
            success: false,
            error: result?.message || 'Failed to setup password'
          };
        }
      }

      return {
        success: false,
        error: 'Unexpected response from password setup'
      };
    } catch (error) {
      return {
        success: false,
        error: 'Failed to setup password'
      };
    }
  }
};

export { supabase };
function useAuth(...args) {
  // eslint-disable-next-line no-console
  console.warn('Placeholder: useAuth is not implemented yet.', args);
  return null;
}

export { useAuth };