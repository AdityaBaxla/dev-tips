
### **1. Create Google OAuth credentials**

* Go to **Google Cloud Console → APIs & Services → Credentials → Create OAuth Client ID**.
* Set application type: **Web Application**.
* Add **Authorized JavaScript origins**:

  ```
  http://localhost:5173
  ```

  (replace port if different)
* Add **Authorized redirect URIs**:

  ```
  https://<your-supabase-project>.supabase.co/auth/v1/callback
  ```

---

### **2. Configure Supabase**

* Go to **Supabase Dashboard → Authentication → Providers → Google**.
* Paste the **Client ID** and **Client Secret** from Google Cloud.
* No need to add redirect URLs here; Supabase uses its callback URL automatically.

---

### **3. Install Supabase client**

```bash
npm install @supabase/supabase-js
```

---

### **4. Setup Supabase in your project**

```js
// supabase.js
import { createClient } from "@supabase/supabase-js";

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_KEY;

export const supabase = createClient(supabaseUrl, supabaseKey);
```

---

### **5. Implement login in Vue**

```js
await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: { redirectTo: window.location.origin + '/dashboard' }
});
```

* `redirectTo` is where users land after login.
* Supabase handles OAuth redirect via its callback URL.

---

### **6. Handle post-login in Vue**

```js
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') {
    window.history.replaceState({}, document.title, window.location.pathname); // remove token from URL
  }
});
```

---

### **7. Secure routes**

* Use `router.beforeEach` to check `supabase.auth.getSession()` before allowing access to protected routes.

---

### **8. Test locally**

* Run your app on `http://localhost:5173`.
* Make sure the redirect URI exactly matches the Supabase callback URL in Google Cloud Console.

---

### **Notes**

* Access token appears in URL fragment briefly — normal behavior, Supabase clears it automatically.
* For production, add your deployed URL to **Authorized JavaScript origins** in Google Cloud.

---
