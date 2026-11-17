# Promotion Plan Status

- Plan: [PLAN.md](PLAN.md)
- Started: 2026-11-17
- Last updated: 2026-11-17
- Current stage: 2 — awaiting command

## 0. Scaffolding — complete

- [x] Switch to `main` and verify a clean worktree
- [x] Create `docs/promotion/PLAN.md`
- [x] Create `docs/promotion/status.md`
- [x] Verify docs files are tracked and not ignored
- [x] Commit and push docs scaffolding
  - commit: `da86459` (`docs: add promotion plan and status tracker`)
  - date: 2026-11-17

## 1. GitHub metadata — complete

- [x] Set repository description
- [x] Add topics (17)
- [x] Verify About section via `gh repo view`
- [x] Pin repository in the profile
  - manual: profile → Customize your pins → `happ-nix` → Save
  - verified via GraphQL `viewer.pinnedItems` on 2026-11-17
- [x] Mark stage complete

## 2. Assets — not started

- [ ] Capture Happ screenshot with demo/sanitized data
- [ ] Hide or blur subscriptions, servers, email, HWID, tokens
- [ ] Get user approval for the screenshot
- [ ] Create social preview 1280x640
- [ ] Strip metadata and optimize images
- [ ] Save `assets/happ-nixos.png` and `assets/social-preview.png`
- [ ] Mark stage complete

## 3. Release 4.7.2 — not started

- [ ] Prepare release notes
- [ ] Create GitHub release from tag `happ-4.7.2`
- [ ] Verify release notes and links
- [ ] Confirm release is marked Latest
- [ ] Mark stage complete

## 4. README — not started

- [ ] Make English README default (`README.md`)
- [ ] Move Russian README to `README.ru.md`
- [ ] Update language switcher links
- [ ] Add CI, license and latest-release badges
- [ ] Add screenshot and feature sections
- [ ] Add quick start for NixOS and package-only caveat
- [ ] Add how-it-works, updates and compatibility sections
- [ ] Add troubleshooting section
- [ ] Keep options, comparison, acknowledgements and license
- [ ] Sync English and Russian content
- [ ] Add gentle star ask
- [ ] Mark stage complete

## 5. Publish and verify — not started

- [ ] Update `status.md`
- [ ] Commit README, assets and status
- [ ] Push `main`
- [ ] CI green
- [ ] Upload social preview (manual: Settings → Social preview)
- [ ] Verify README rendering, links and badges
- [ ] Verify metadata, topics, release and pinned repository
- [ ] Verify no secrets or metadata remain in assets
- [ ] Mark all applicable items done

## 6. Deferred

- [ ] Release `happ-4.8.1` after PR #1 merge and real TUN/DNS/IPv6 test
- [ ] Consider NixOS Wiki / awesome-nix publication as a separate plan

## Notes

- Root `PLAN.md` and `status.md` are ignored migration notes; these files
  are the tracked promotion plan and status.
- PR #1 (`happ-4.8.1`, draft) is intentionally outside this plan.
- Manual steps: pinning the repository and uploading social preview.
