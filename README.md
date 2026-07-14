# Task247 — mobile app with login (mobile number + 6-digit PIN)

## What's in this folder
```
index.html            the app (now with a login screen)
manifest.json          PWA manifest (installable icon/name)
sw.js                   service worker (offline app shell)
icons/                  app icons
supabase-schema.sql     run this once in Supabase to create your tables
```

The app now requires logging in with a **mobile number + a 6-digit password**
before it opens. Tasks are stored in **Supabase** (a hosted Postgres database)
instead of just the browser, so your data follows your account across
devices, and installs on your phone as a real app.

---

## 1. Create your Supabase project (~3 minutes, free)

1. Go to **supabase.com** → sign up → **New project**. Pick any name/region
   (Mumbai region is closest for you) and set a database password (you won't
   need this password again — it's separate from user logins).
2. Once it's created, go to **Project Settings → API**. Copy:
   - **Project URL**
   - **anon public** key
3. Go to **Authentication → Providers → Email** and turn **OFF** "Confirm
   email". (We're not sending real emails — this lets people log in
   immediately after creating an account.) Also check **Authentication →
   Settings** and make sure "Minimum password length" is **6** (it usually
   is by default).
4. Go to **SQL Editor → New query**, paste the contents of
   `supabase-schema.sql` from this folder, and click **Run**. This creates
   the `tasks` and `recurring` tables, locked down so each person can only
   ever see their own data.

## 2. Connect the app to your project

Open `index.html`, find this near the top of the `<body>`:

```html
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```

Paste in the Project URL and anon key you copied in step 1. Save the file.

*(The anon key is meant to be public/client-side — that's normal for
Supabase. The Row Level Security policies in the SQL script are what
actually keep everyone's tasks private, not the secrecy of this key.)*

## 3. Deploy to Vercel

1. vercel.com → **New Project** → drag-and-drop this whole folder (or push
   it to a GitHub repo and import it, same as your Revie projects).
2. No build step needed — it's a static site, deploy as-is.
3. You'll get a URL like `taskdesk-yourname.vercel.app`.

## 4. Install it on your phone

Open the Vercel URL on your phone:

- **Android (Chrome):** tap **⋮** → **Install app** (or accept the install
  banner). Opens full-screen with its own icon.
- **iPhone (Safari):** tap **Share** → **Add to Home Screen**. iOS never
  shows an automatic install banner for web apps — this manual step is
  expected there.

## How login works

- On first use, tap **"Create an account"**, enter a mobile number and pick
  any 6-digit number as your password.
- Behind the scenes this uses Supabase's normal email/password login — your
  phone number is turned into a private, fixed placeholder email
  (`p<number>@taskdesk.local`) that only your account knows about. You never
  see or use this "email" anywhere.
- Once logged in, the session is remembered on that device/browser — you
  won't be asked to log in again until you tap **Log Out** (in the
  **Drive/Sync** tab).
- Every task/recurring-task change is saved to Supabase automatically a
  couple of seconds after you make it, so switching phones or reinstalling
  just requires logging in again with the same number + PIN.

## What was fixed for mobile (previous request)

- Chat input font-size was under 16px, which made iOS Safari auto-zoom on
  focus and break the layout — fixed by forcing 16px on all inputs on
  mobile widths.
- Chat tab no longer force-opens the keyboard on mobile (unreliable there);
  it still auto-focuses on desktop.
- Added a "Send" action key on the mobile keyboard for the chat box.
- Bottom nav / floating "+" button / chat input now respect the iPhone
  notch and home-indicator safe areas.
- Manifest, icons and a service worker were added so the app installs like
  a normal app and keeps working offline for anything already loaded.

## Notifications

Each task has a "Remind me X days before due" field (in the add/edit task
form). Turn notifications on once in the **Drive/Sync** tab
("Enable Notifications" — your browser will ask for permission). After that,
Task247 shows a real phone notification (not just an in-app toast) for:
- tasks entering their reminder window
- tasks due today
- overdue tasks

It re-checks every 5 minutes while the app is open, and once per task per
day (so it won't spam you repeatedly for the same task).

**Honest limitation:** this fires while the app/tab is open or running in the
background — it can't wake up and notify you while the app is fully closed
and your phone has been idle for hours, without a real backend push server
(Web Push + VAPID keys + a scheduler). If you want that "closed-app" style
push later, it's a bigger addition — happy to build it, but it also needs a
way to run on a schedule (Vercel's free/Hobby plan only allows cron jobs to
run once a day, so it'd need a different scheduler to be timely).

## Notes / limits of this setup

- There's no SMS OTP verification — anyone can type in any mobile number
  when creating an account, the same way many small internal tools work.
  If you later want real OTP verification, that requires wiring up an SMS
  provider (e.g. Twilio) inside Supabase Auth's phone provider — happy to
  do that next if you want it.
- Data syncs to the cloud automatically, but only while you're online.
  Offline, the app keeps working off the last-loaded local copy (service
  worker), and syncs again once you're back online.
