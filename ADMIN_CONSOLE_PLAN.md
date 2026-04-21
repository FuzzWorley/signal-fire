# Admin Console — Build Plan

## Context

Building an internal admin console at `/admin/*`. Password-protected (founders only). Web-only.
Source of truth: `AdminScreens.pdf`. Style guide: `CLAUDE.md`.

Stack: Rails 8.1, ERB + Tailwind + Stimulus. No React on web.
Custom colors: `ink` (#1a1a12), `paper` (#f2f0d9), `ember` (#e24820), `glen` (#d4a82d), `stone` (#867a60).

## Schema decisions

- `totems.location_description` (text) → replaced by `park_name` (string) + `sublocation` (string)
- Migration: `20260421000001_split_totem_location_into_park_and_sublocation.rb`
- All other schema stays as-is

## Gem additions

- `rqrcode` — QR PNG generation for totem download links

## Route structure

```ruby
# existing admin_root redirects to /admin/totems (changed from /admin/login)
get "/admin", to: redirect("/admin/totems"), as: :admin_root

# auth stays as-is under scope "/admin"

# console
namespace :admin do
  resources :totems do
    member { get :qr }   # GET /admin/totems/:id/qr.png — downloads QR PNG
  end
  resources :hosts, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :events
end
```

## Auth flow

- `Admin::ApplicationController` calls `before_action :require_admin!` (already in ApplicationController)
- Layout: `admin` (mirrors host layout)
- After login, `Auth::Admin::SessionsController#create` redirects to `admin_root_path` → `/admin/totems`

## Chunks

### Chunk 1 — Foundation + Totems (DONE)
- [x] Migration: split location_description
- [x] Gemfile: add rqrcode
- [x] Routes updated
- [x] Totem model: park_name + sublocation (remove location_description)
- [x] `app/controllers/admin/application_controller.rb`
- [x] `app/views/layouts/admin.html.erb`
- [x] `app/controllers/admin/totems_controller.rb`
- [x] `app/views/admin/totems/index.html.erb`
- [x] `app/views/admin/totems/_form.html.erb`
- [x] `app/views/admin/totems/new.html.erb`
- [x] `app/views/admin/totems/edit.html.erb`

### Chunk 2 — Hosts (TODO)

Screens (from PDF 4.4.2):
- Index table: HOST (name + email), TOTEMS (assigned totem names), STATUS badge, EVENTS count, JOINED date
- Filter tabs: All | Active | Invited | Deactivated
- "+ Invite host" button → modal or page with Name + Email fields
- Row actions: Edit, Deactivate (or re-activate), Delete

Business logic:
- Invite creates: `User` (email, name, is_host: true) + `HostProfile` (invite_status: :invited, invitation_token, invited_at)
- Sends invite email via existing Resend/mailer setup (look at existing mailer for pattern)
- Edit: change name, email, assigned totems (add/remove HostTotemAssignment records)
- Deactivate: sets `host_profile.invite_status = :deactivated`
- Delete: destroys user + cascade (host_profile, assignments, events — check dependent: :destroy on models first)

Files to create:
- `app/controllers/admin/hosts_controller.rb`
- `app/views/admin/hosts/index.html.erb`
- `app/views/admin/hosts/new.html.erb` (invite form: name + email)
- `app/views/admin/hosts/edit.html.erb` (name, email, totem assignments)
- `app/views/admin/hosts/_form.html.erb`
- A service object for invite logic (check if one exists already)

### Chunk 3 — Events (TODO)

Screens (from PDF 4.4.3):
- Index table: EVENT (title + "Created by admin" sub-label when applicable), HOST · TOTEM, WHEN, STATUS badge, ACTIONS
- Filter/search by host, totem, or title (single text field)
- "+ Create event (as host)" button → host picker first, then event form
- Status badges: UPCOMING, LIVE, CANCELLED, PAST
- Actions: Edit + Delete for upcoming/live; View + Delete for cancelled/past
- Admin override: `created_by_admin = true` stored in DB; host name shown publicly (not "admin")

Business logic:
- Admin picks a host from a dropdown → loads that host's assigned totems → fills event form
- On create: sets `host_user = selected_host`, `created_by_admin = true`
- Edit: same form, admin can change any field
- Status derivation (for badges): same logic as Event model (active_now?, window_state, etc.)

Files to create:
- `app/controllers/admin/events_controller.rb`
- `app/views/admin/events/index.html.erb`
- `app/views/admin/events/new.html.erb` (host picker → event form)
- `app/views/admin/events/edit.html.erb`
- `app/views/admin/events/_form.html.erb` (reuse host event form with host selector added)
- Stimulus controller for host→totem cascade (or simple Turbo Frame)

## Key files for reference

| File | Purpose |
|------|---------|
| `app/controllers/host/events_controller.rb` | Event CRUD pattern + time assembly helper — reuse for admin |
| `app/views/host/events/_form.html.erb` | Event form partial — adapt for admin (add host selector) |
| `app/views/layouts/host.html.erb` | Layout template — admin layout mirrors this exactly |
| `app/controllers/auth/host/invitations_controller.rb` | Invite accept flow — admin invite should generate same token/profile |
| `app/models/host_profile.rb` | invite_status enum: invited / active / deactivated |
| `app/models/host_totem_assignment.rb` | Join table for host ↔ totem, tracks assigned_by_admin_id |
| `db/schema.rb` | Full schema reference |
| `config/routes.rb` | All routes |

## Notes

- Settings page: skip for V1
- QR codes: `GET /admin/totems/:id/qr` → PNG download via rqrcode gem, points to `/t/:slug` (public board URL)
- `qr_url` column on totems exists in schema but is unused — leave it alone
- Admin events index derives status label from: active_now? → LIVE, future start_time → UPCOMING, status==cancelled → CANCELLED, else PAST
- Host events count = `events.where(host_user_id: user.id).count` (all events, not just upcoming)
