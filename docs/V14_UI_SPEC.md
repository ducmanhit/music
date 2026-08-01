# V14 Dark Rounded Premium — UI specification

## Principles

- Dark mode is the default; light mode uses the same layout.
- No gradients, glass blur, neon, or decorative color washes.
- Artwork is the main visual focus.
- Surfaces are flat, rounded, and separated by thin borders/dividers.
- All primary pages respect Safe Area and Dynamic Island.

## Core dimensions

- Screen horizontal padding: 20 px
- Large artwork radius: 28 px
- Large surface radius: 26 px
- Mini Player: 68 px high, radius 24 px
- Bottom navigation: 66 px high, radius 28 px
- Search field: 50 px high, radius 18 px
- Song artwork: 52 px, radius 14 px
- Dialog radius: 24 px
- Bottom sheet top radius: 30 px

## Navigation

Four tabs: Home, Search, Library, Settings. Mini Player sits 8 px above the navigation bar. Both components reserve layout space and never overlay list content.

## Now Playing

The main layout uses `LayoutBuilder` and does not scroll. Artwork scales using available height. Track text has fixed line limits. Transport controls always stay inside Safe Area.

## Modals

Bottom sheets use `isScrollControlled`, `useSafeArea`, an 82% height cap, and `MediaQuery.viewInsets.bottom`. Short destructive confirmations use a centered dialog with a 320 px maximum width.
