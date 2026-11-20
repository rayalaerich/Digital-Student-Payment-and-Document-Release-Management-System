# Style Guide

## 1. Colors

| Role | Name | Hex | Used for |
|------|------|-----|----------|
| Primary | Navy | `#1e3a5f` | Header bar, primary buttons, headings, links |
| Background | Light blue-grey | `#f4f6fa` | Page background |
| Text | Ink | `#1f2937` | Body text |
| Success | Green | `#1b6b3a` | Confirm buttons, success messages, RELEASED badge |
| Error | Red | `#b3261e` | Error messages, Cancel/Delete buttons, logout |
| Accent (optional) | Gold | `#dba340` | Small header label and dialog icon only (never for text on light backgrounds) |
| Muted text | Grey | `#5b6678` | Secondary text, table headings, captions |

## 2. Contrast check (WCAG AA needs 4.5:1 or higher)

| Text color | Background | Ratio | Result |
|------------|------------|-------|--------|
| Text `#1f2937` | Background `#f4f6fa` | **13.57:1** | Pass |
| Text `#1f2937` | White `#ffffff` (cards) | 14.68:1 | Pass |
| Primary `#1e3a5f` | Background `#f4f6fa` | 10.63:1 | Pass |
| Muted `#5b6678` | Background `#f4f6fa` | 5.37:1 | Pass |
| White | Primary button `#1e3a5f` | 11.50:1 | Pass |
| White | Success button `#1b6b3a` | 6.54:1 | Pass |
| White | Error button `#b3261e` | 6.54:1 | Pass |
| Error `#b3261e` | Background `#f4f6fa` | 6.04:1 | Pass |
| Gold `#dba340` | Navy header `#1e3a5f` | 5.11:1 | Pass (only on navy) |

Gold on a light background is only 2.08:1, so it is never used for text there.

## 3. Fonts

- **Headings:** Roboto, bold, with Segoe UI and Arial as fallbacks
- **Body:** Roboto, regular, with Segoe UI and Arial as fallbacks
- **Base font size:** 16px (headings: page title 26px, card title 18px)
- **Small text:** 13 to 14px for captions, table headings and badges

## 4. Components

**Primary button:** Navy background, white bold text, no border, 12px corner radius, padding 12px 18px. It is used for the main action on a page ("Register payment", "Search"). Green is used for confirming money or releases ("Confirm cash received", "Verify and record release").

**Secondary button:** White background, navy bold text, 2px navy border, same radius and padding. It is used for less important actions ("Edit", "View receipt", "Cancel" in a dialog).

**Text input:** White background, 1.5px grey-blue border (`#a5b0c0`), 12px corner radius, 12px padding, full width, with a bold label above it. On error, the border changes to the error color.

**Error message:** Red text (`#b3261e`), bold, 14px, placed directly under the field it belongs to, with a ⚠ icon in front. For page-level errors, a red toast box with white text appears at the top of the page.

**Status badges:** Rounded pill, 12px bold text. PENDING is amber on cream, PAID is navy on light blue, RELEASED is green on light green.

## 5. CSS variables

```css
:root {
  /* colors */
  --color-primary: #1e3a5f;   /* header, primary buttons, headings, links */
  --color-bg: #f4f6fa;        /* page background */
  --color-text: #1f2937;      /* body text. Contrast on bg: 13.57:1 ✓ */
  --color-success: #1b6b3a;   /* confirm buttons, success messages */
  --color-error: #b3261e;     /* error messages, cancel/delete */
  --color-accent: #dba340;    /* gold, use only on navy backgrounds */
  --color-muted: #5b6678;     /* secondary text. Contrast on bg: 5.37:1 ✓ */
  --color-surface: #ffffff;   /* cards and inputs */
  --color-border: #a5b0c0;    /* input borders */

  /* fonts */
  --font-heading: Roboto, "Segoe UI", Arial, sans-serif;
  --font-body: Roboto, "Segoe UI", Arial, sans-serif;
  --font-size-base: 16px;

  /* shape */
  --radius: 12px;
}
```
