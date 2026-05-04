# Design System Specification: The Technical Verdancy

## 1. Overview & Creative North Star
This design system is built upon the **"Technical Verdancy"** North Star. It is a visual philosophy that marries the rugged, data-driven precision of modern ag-tech with the organic, rhythmic growth of the harvest. We are moving away from "generic farm" aesthetics and toward a high-end, editorial experience that feels both authoritative and breathable.

To achieve this, the system breaks the traditional "dashboard" mold. We utilize intentional asymmetry, exaggerated typographic scales, and high-contrast color blocking to ensure maximum legibility in outdoor environments (direct sunlight on fields) while maintaining a premium, "Atma Clear" minimalist soul.

## 2. Colors: The Verdant Spectrum
The palette is a sophisticated range of greens—from deep forest shadows to vibrant mint highlights. This isn’t just about color; it’s about **tonal depth**.

### The "No-Line" Rule
**Explicit Instruction:** Designers are prohibited from using 1px solid borders to define sections or containers. Structure must be achieved through:
*   **Background Shifts:** Placing a `surface-container-low` component against a `surface` background.
*   **Tonal Transitions:** Using color-blocked regions to define the transition from one content area to the next.

### Surface Hierarchy & Nesting
Treat the UI as a physical stack of semi-translucent materials. 
*   **Base:** `surface` (#f5fbf6) is your ground.
*   **Layer 1:** Use `surface-container-low` (#eff5f0) for large structural areas.
*   **Layer 2 (The Focus):** Use `surface-container-lowest` (#ffffff) for the most critical interactive cards, creating a "pop" against the minty-white backgrounds.
*   **Deep Contrast:** Use `primary` (#012d1d) for header sections or "Hero" moments to anchor the page with the weight of forest green.

### The "Glass & Gradient" Rule
To elevate the UI beyond flat material design, use Glassmorphism for floating elements (like navigation bars or action sheets). 
*   **Execution:** Apply a `surface` color at 80% opacity with a `20px` backdrop blur.
*   **Gradients:** For primary CTAs, use a subtle linear gradient from `primary` (#012d1d) to `primary_container` (#1b4332). This adds "soul" and a tactile, three-dimensional quality to the agricultural tools.

## 3. Typography: Editorial Precision
The system utilizes two distinct typefaces to balance character with utility.

*   **Display & Headlines (Public Sans):** This is our "voice." Public Sans offers a clean, geometric authority. Use `display-lg` (3.5rem) with tight tracking for hero statistics (e.g., harvest yields) to create a high-impact editorial feel.
*   **Body & Labels (Inter):** This is our "tool." Inter is used for technical data, input fields, and long-form reading. Its high x-height ensures clarity on mobile devices in bright outdoor conditions.
*   **The Hierarchy Goal:** Use extreme scale differences. A `display-md` headline paired with a `body-sm` label creates the sophisticated "white space" luxury typical of high-end digital journals.

## 4. Elevation & Depth
Depth is conveyed through **Tonal Layering** rather than heavy shadows or structural lines.

*   **The Layering Principle:** Place a `surface-container-lowest` (pure white) card on top of a `surface-container` (#eaefea) background. The subtle 2-3% difference in value creates a natural lift that feels light and modern.
*   **Ambient Shadows:** If a floating action button or modal requires a shadow, it must be "Ambient." Use a large blur (32px+) and a very low opacity (6%) shadow tinted with the `on_surface` color (#171d1a). Never use pure black shadows.
*   **The "Ghost Border" Fallback:** If a layout requires a boundary for accessibility, use the `outline_variant` (#c1c8c2) at **20% opacity**. It should be felt, not seen.
*   **Glassmorphism:** Use it to "nest" technical data over organic imagery or maps. A `surface_variant` container with a 10px blur allows the colors of the "field" to bleed through, softening the technical edge of the UI.

## 5. Components

### Buttons
*   **Primary:** `primary` background with `on_primary` text. Use the `md` (0.375rem) corner radius for a "precision-tooled" look.
*   **Secondary:** `secondary_container` background with `on_secondary_container` text. This provides a softer, emerald-toned alternative for secondary actions.
*   **Tertiary:** Text-only using `primary` color, strictly reserved for low-priority actions like "Cancel" or "Back."

### Input Fields
*   **Styling:** Use a `surface_container_high` background. Instead of a full border, use a 2px bottom stroke in `outline` (#717973) that transitions to `primary` (#012d1d) on focus.
*   **Readability:** Labels must use `label-md` in `on_surface_variant` for high contrast against the minty surface.

### Cards & Lists
*   **Rule:** Forbid the use of divider lines. 
*   **Separation:** Use 24px or 32px of vertical white space (from the Spacing Scale) to separate list items. For complex data lists, alternate background colors between `surface` and `surface_container_low`.
*   **Interaction:** Cards should have a subtle "lift" on hover, achieved by swapping the background from `surface_container_low` to `surface_container_lowest`.

### Data Visualization (Agricultural Context)
*   **The Growth Chart:** Use `primary` for historical data and `secondary` (emerald) for projected growth. 
*   **Status Chips:** Use `tertiary_container` for "Healthy/Active" states to introduce the darker, technical emerald tone.

## 6. Do's and Don'ts

### Do
*   **Do** embrace asymmetry. Align a large `display-sm` headline to the left and offset the body text to the right to create an editorial flow.
*   **Do** use high-contrast combinations (e.g., `primary_fixed` text on `primary` background) for critical outdoor alerts.
*   **Do** leverage the `xl` (0.75rem) roundedness for large containers to soften the "industrial" feel of the app.

### Don't
*   **Don't** use 100% opaque borders. They clutter the UI and break the "Clear" aesthetic.
*   **Don't** use slate or blue-grey tones. Every neutral in this system is "green-tinted" (e.g., `surface_dim` is a warm, desaturated mint) to maintain brand cohesion.
*   **Don't** crowd the layout. If a screen feels "busy," increase the padding to the next step in the spacing scale rather than adding lines or dividers.