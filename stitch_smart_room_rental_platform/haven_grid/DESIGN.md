# Design System Strategy: The Curated Sanctuary

## 1. Overview & Creative North Star
This design system is built upon the "Curated Sanctuary" North Star. Unlike standard utility-first booking apps, this system treats digital real estate with the same reverence as a high-end physical space. We are moving away from the "data-grid" aesthetic and toward a "Digital Editorial" experience.

The core philosophy is **Soft Authority**. We build trust through spaciousness, intentional asymmetry, and a rejection of traditional UI "scaffolding" (like harsh borders and dividers). By using high-contrast typography and layered surfaces, we create an environment that feels less like a database and more like a concierge-led tour.

## 2. Colors & Surface Philosophy
The palette is anchored in deep, trust-inspiring teals and sophisticated neutrals. We do not use color merely for decoration; we use it to define architecture.

### The "No-Line" Rule
**Borders are prohibited for sectioning.** To separate content, you must use background color shifts or tonal transitions. For example, a room listing description should sit on a `surface-container-low` section, which itself sits on the main `background`. This creates a seamless, modern flow that mimics high-end interior design.

### Surface Hierarchy & Nesting
Treat the UI as physical layers of glass and fine paper. 
*   **Base:** `surface` (#f6fafa)
*   **Secondary Content:** `surface-container-low` (#f0f4f4)
*   **Elevated Components (Cards):** `surface-container-lowest` (#ffffff) for a "lifted" feel without heavy shadows.

### The "Glass & Gradient" Rule
To add soul to the "Modern" requirement:
*   **Glassmorphism:** For floating navigation or over-image overlays, use `primary` at 80% opacity with a 20px `backdrop-blur`.
*   **Signature Gradients:** For primary CTAs and hero backgrounds, use a subtle linear gradient from `primary` (#00686d) to `primary_container` (#0d8389). This prevents the UI from feeling "flat" or "stock."

## 3. Typography
We utilize a dual-font pairing to balance editorial elegance with functional clarity.

*   **Display & Headlines (Manrope):** This is our "Editorial Voice." Use `display-lg` and `headline-md` with tight letter-spacing to command attention. Manrope’s geometric yet warm nature provides the professional polish required.
*   **Body & Labels (Inter):** This is our "Utility Voice." Inter is used for all room details, descriptions, and system labels (`body-md`, `label-sm`). It ensures maximum legibility even in dense amenity lists.

**Pro-Tip:** Leverage the scale contrast. Pair a `headline-lg` room name with a `label-md` uppercase category tag (e.g., "PENTHOUSE") in `tertiary` (#8d4c20) for a premium, branded look.

## 4. Elevation & Depth: Tonal Layering
Traditional drop shadows are often a crutch for poor layout. In this system, depth is achieved through **Tonal Layering**.

*   **Layering Principle:** Place `surface-container-lowest` cards on a `surface-container-high` background. The shift in hex value provides all the "lift" needed.
*   **Ambient Shadows:** If a card must float over a photo, use an "Ambient Shadow": `48px blur`, `0px offset`, and `on-surface` color at only 4% opacity. It should be felt, not seen.
*   **The "Ghost Border" Fallback:** If accessibility requires a container edge, use a "Ghost Border": `outline-variant` (#bdc9c9) at 15% opacity. Never use 100% opaque lines.

## 5. Components

### Elegant Room Cards
*   **Structure:** No borders. Use `xl` (1.5rem) corner radius. 
*   **Imagery:** The image should occupy the top 60% of the card. 
*   **Content:** Avoid dividers. Use `body-md` for descriptions and `title-lg` for pricing. Use `surface-container-highest` as a subtle background for the entire card to make the white "Book" button pop.

### Amenities (Iconography)
*   **Visual Style:** Use thin-stroke (1.5px) icons. 
*   **Context:** Amenities like "Wifi" or "AC" should be housed in small `secondary_container` chips with `sm` (0.25rem) rounding.

### Buttons
*   **Primary (Book):** Gradient fill (`primary` to `primary-container`), `full` (pill) rounding, `title-sm` text.
*   **Secondary (Chat):** `outline` token ghost border with `on-surface` text.
*   **Floating Action:** Use Glassmorphism (Primary color with blur) for mobile "Map" toggles.

### Input Fields
*   **Style:** Use `surface-container-high` as the background fill. No bottom line.
*   **Focus State:** Transition the background to `surface-container-lowest` and add a 1px `primary` ghost border.

### Interactive Lists
*   **Rule:** Forbid divider lines. Separate list items using `1rem` of vertical white space and a very subtle background hover state using `surface-variant`.

## 6. Do's and Don'ts

### Do:
*   **Embrace Negative Space:** If a screen feels "empty," don't add a border. Add more padding.
*   **Use Imagery as Architecture:** Let the high-quality room photos define the color mood of the page.
*   **Prioritize Hierarchy:** Use the `tertiary` color (#8d4c20) sparingly for high-value alerts or "Luxury" badges to create a focal point.

### Don't:
*   **Don't use 1px Dividers:** Use a `8px` height `surface-container-low` block if you must separate large sections.
*   **Don't use Pure Black:** Use `on-surface` (#181c1d) for all text to maintain a softer, premium contrast.
*   **Don't Over-round Small Elements:** Use `sm` rounding for chips and `xl` for large cards to create a visual rhythm between "sharp" data and "soft" containers.