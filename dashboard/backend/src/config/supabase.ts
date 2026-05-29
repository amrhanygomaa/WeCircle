// Dummy object to satisfy legacy routes until they are removed
export const supabaseAdmin = {
  auth: {
    signInWithPassword: async () => ({ data: { session: { access_token: "dummy" } }, error: null }),
    admin: {
      createUser: async () => ({ error: null }),
      updateUserById: async () => ({ error: null }),
      deleteUser: async () => ({ error: null })
    }
  }
} as any;
