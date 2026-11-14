# NeruOS Nebula Design System v0.2

This document records the visual rules approved for the first NeruOS edition. It will evolve through implementation, testing, accessibility reviews, and contributor feedback.

## 1. Design intent

Nebula should feel **atmospheric, premium, calm, and responsive**. It takes inspiration from deep-space colors and soft aurora light. It must remain its own design language rather than imitate another operating system.

1. **Atmospheric, not noisy** — backgrounds may be expressive, while controls stay quiet.
2. **Minimal, not empty** — every control should have a clear purpose.
3. **Futuristic, not cyberpunk-heavy** — avoid excessive neon, outlines, and clutter.
4. **Fluid, not decorative** — motion should communicate state and never delay work.

## 2. Locked desktop decisions

| Decision | Current value |
|---|---|
| Default appearance | Dark |
| Dock | Floating, horizontally centered near the bottom |
| Dock hover | Pointer-distance magnification with eased scaling |
| NeruBar | Dynamic application-context menus and system status actions |
| Wallpaper | User-selectable; Nebula is the default concept |
| Navigation rail | Hidden by default; reveal from the left edge |
| Quick settings | NeruCenter, opened from the top bar |
| App search | NeruSearch, opened from the top bar or Alt+Space |
| Workspace presets | General, Coding, Gaming, Study |

## 3. Color tokens

| Token | Hex | Usage |
|---|---|---|
| Obsidian | #080F1A | Deepest background |
| Midnight | #151D2F | Elevated surfaces and windows |
| Nebula Cyan | #54C8EB | Primary accent, focus, active states |
| Nebula Violet | #9277E8 | Secondary accent and selection |
| Aurora Pink | #E57BFF | Rare highlight; avoid large surfaces |
| Primary Text | #F2F5FF | Main text |
| Secondary Text | #AAB6D0 | Supporting information |
| Border | #50617E | Subtle borders and separators |

### Color rules

- Use Obsidian for the deepest surface and Midnight for cards, panels, and windows.
- Cyan is the primary accent. Violet supports it; pink is reserved for small highlights.
- Never rely on color alone to communicate state.
- Place text on stable surfaces when wallpaper contrast is uncertain.

## 4. Typography

| Context | Typeface | Notes |
|---|---|---|
| UI | Inter | Regular, Medium, SemiBold |
| Headings | Inter | Medium or SemiBold |
| Code / terminal | JetBrains Mono | Monospaced |
| Fallback | System sans-serif | Required when optional fonts are unavailable |

Suggested scale: 10–12 px metadata, 14 px secondary UI, 16 px body text, 20–24 px section headings, and 32–38 px display headings.

## 5. Shape, spacing, and depth

| Element | Radius |
|---|---:|
| Small control | 8–10 px |
| Input / compact card | 12–14 px |
| Standard card | 16 px |
| Window / floating panel | 20–24 px |

Use a restrained 1 px border and soft shadow. Blur and transparency are optional effects, not requirements. Provide a readable fallback when compositor effects are unavailable.

Suggested spacing rhythm: 4, 8, 12, 16, 24, 32, and 48 px.

## 6. Motion

| Interaction | Target duration |
|---|---:|
| Hover / pressed feedback | 100–130 ms |
| NeruDock magnification | 135 ms |
| Popover open / close | 150–190 ms |
| Window open / close | 180–220 ms |
| Workspace transition | 220–280 ms |

Motion must be interruptible, must not block input, and must respect reduced-motion preferences in the production shell.

## 7. Core components

- **NeruBar** — dynamic app-context menus, global status, clock, and quick actions.
- **NeruDock** — floating app launcher, pointer-distance magnification, tooltips, and selected-app indicator.
- **NeruCenter** — quick settings and notifications.
- **NeruSearch** — universal search and app launcher.
- **NeruSpace** — workspace identity and switching.
- **NeruFiles** — first-party file-management experience (future).
- **NeruStore** — software discovery experience (future).

## 8. Accessibility and performance

- Keyboard navigation and visible focus are mandatory for production components.
- Provide accessible names for icon-only controls.
- Respect system font scaling, high-contrast preferences, and reduced motion.
- Do not make blur the only way to distinguish a panel.
- Avoid unnecessary full-screen layers and expensive blur.
- Animate only properties that can be rendered efficiently.
- Allow effects to be disabled on lower-powered hardware.
- Test on integrated graphics and lower-memory systems before release.

## 9. Change process

When changing a token or locked decision, include the reason, a before/after screenshot or reproducible example, accessibility and performance considerations, and affected components.
