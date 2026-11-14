# Technical Decisions

This file records decisions that affect the direction of the project. New decisions should include context, alternatives, consequences, and a review trigger.

## ADR-001 — Use Arch Linux as the base

**Status:** Accepted

**Decision:** Build the planned distribution on Arch Linux.

**Context:** The project values a flexible rolling base and access to current desktop software.

**Consequences:** The team must document update practices, package maintenance, and recovery. A rolling distribution needs thorough update testing before a broad release.

## ADR-002 — Start with KDE Plasma 6

**Status:** Accepted for initial integration

**Decision:** Use KDE Plasma 6 / KWin as the first desktop foundation.

**Context:** A complete custom desktop environment would expand scope dramatically. Plasma provides existing window management, workspace, panel, and Wayland capabilities.

**Consequences:** NeruOS must respect Plasma packaging conventions and avoid patching core components without need. Custom shell work can be evaluated after the first theme and panel integration.

## ADR-003 — Use Qt 6 and QML for UI prototypes

**Status:** Accepted

**Decision:** Use Qt 6 / QML for the desktop prototype and future first-party interface components.

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
