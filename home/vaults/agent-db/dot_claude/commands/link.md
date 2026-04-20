Suggest wikilinks for the specified note.

Usage: /link <note path>

1. Read the note at the given path.
2. Scan all other notes in the vault for titles, headings, and concepts that are semantically related to the note's content.
3. Return a ranked list of suggested wikilinks in the format `[[Note Title]]` with a one-line reason for each suggestion.
4. Do not modify the note — output suggestions only.
