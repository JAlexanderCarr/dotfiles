Summarize a note or folder into a Research Note.

Usage: /summarize <path>

1. Read all markdown files at the given path (file or directory).
2. Produce a Research Note using this structure:
   - **Source:** the input path
   - **Summary:** 3-5 sentence synthesis of the content
   - **Key Quotes:** notable excerpts worth preserving verbatim
   - **Open Questions:** gaps or follow-up items that surfaced
3. Write the result to `Research/<derived-title>.md` (prompt for a title if the path is ambiguous).
4. Report the output path when done.
