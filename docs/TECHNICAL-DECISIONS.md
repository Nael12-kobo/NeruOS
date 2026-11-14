# Technical Decisions

This file records decisions that affect the direction of the project. New decisions should include context, alternatives, consequences, and a review trigger.

## ADR-001 — Use Arch Linux as the base

**Status:** Accepted

**Decision:** Build the planned distribution on Arch Linux.

**Context:** The project values a flexible rolling base and access to current desktop software.

**Consequences:** The team must document update practices, package maintenance, and recovery. A rolling distribution needs thorough update testing before a broad release.

## ADR-002 — Develop a standalone NeruOS shell

**Status:** Accepted

**Decision:** Build NeruOS's own shell UI components with Qt 6 / QML. Do not make a KDE Plasma theme the primary desktop product.

**Context:** The desired product needs its own interaction language and visual identity.

**Consequences:** NeruOS must eventually select or develop a window-management / compositor foundation, session startup, login integration, and recovery path. The UI shell alone does not manage native windows.

## ADR-003 — Use Qt 6 and QML

**Status:** Accepted

**Decision:** Use Qt 6 / QML for the shell prototype and future first-party interface components.

**Context:** Qt Quick supports fluid, declarative interfaces and animation.

**Consequences:** Contributors need Qt/QML build tooling. Prototype controls are not automatically connected to system services.

## ADR-004 — Nebula desktop defaults

**Status:** Accepted

**Decision:** Default to dark appearance, floating dock, user-selectable wallpaper, and a hidden navigation rail revealed at the left edge.

**Consequences:** These choices are documented in the design system and must remain consistent across mockups and components.

## ADR-005 — Keep the early prototype safe

**Status:** Accepted

**Decision:** The prototype runs as a regular user application and does not modify the active desktop shell or boot configuration.

**Consequences:** It can be tested without installing a custom session. Real system controls require separate design, permission review, and integration work.

## ADR-006 — Separate NeruBar and NeruDock components

**Status:** Accepted

**Decision:** Keep the top bar and dock in separate reusable QML components.

**Context:** Both components have their own interaction state and will grow independently.

**Consequences:** Their APIs should remain explicit and signal-based. Parent shell state owns active application, workspace, and system-service data.
