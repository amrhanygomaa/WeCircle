# WeCircle — Documentation Package (README)

This folder contains the official graduation-project documentation for **WeCircle — School
Management System**, written from a direct analysis of the actual source code in this repository.

## 1. Contents & reading order

| File | Purpose |
|------|---------|
| `00-analysis.md` | **Phase 1** — system & codebase analysis (input/working document; not part of the report body) |
| `outline.md` | **Phase 2** — the confirmed documentation outline / table of contents |
| `01-front-matter.md` | Title page, abstract (EN), الملخص (AR), acknowledgments, lists of figures/tables/abbreviations |
| `02-chapter1-introduction.md` | Chapter 1 — Introduction |
| `03-chapter2-background.md` | Chapter 2 — Background & Literature Review |
| `04-chapter3-analysis.md` | Chapter 3 — System Analysis |
| `05-chapter4-design.md` | Chapter 4 — System Design (architecture, ERD, sequence/activity/DFD diagrams) |
| `06-chapter5-implementation.md` | Chapter 5 — Implementation (annotated code) |
| `07-chapter6-testing.md` | Chapter 6 — Testing & Evaluation |
| `08-chapter7-conclusion.md` | Chapter 7 — Conclusion & Future Work |
| `09-back-matter.md` | References (IEEE) + Appendices A–E (incl. full API reference) |
| `WeCircle-Documentation.md` | **Single assembled document** (chapters 01→09 concatenated) |
| `diagrams/` | Destination for exported diagram images (created when you run the Mermaid export below) |

All diagrams are embedded as **Mermaid code blocks** inside the chapters. They render automatically
on GitHub and in any Mermaid-aware Markdown viewer (VS Code with a Mermaid extension, Obsidian, Typora,
etc.).

## 2. How to regenerate the single document

The assembled `WeCircle-Documentation.md` is produced by concatenating the front matter, chapters,
and back matter in order. To rebuild it (PowerShell, from the `docs/` folder):

```powershell
$order = @(
  '01-front-matter.md','02-chapter1-introduction.md','03-chapter2-background.md',
  '04-chapter3-analysis.md','05-chapter4-design.md','06-chapter5-implementation.md',
  '07-chapter6-testing.md','08-chapter7-conclusion.md','09-back-matter.md'
)
($order | ForEach-Object { (Get-Content $_ -Raw) + "`r`n`r`n" }) -join '' |
  Set-Content 'WeCircle-Documentation.md' -Encoding utf8
```

## 3. How to convert to DOCX / PDF (with a table of contents & page numbers)

> **Note:** `pandoc`, `mermaid-cli` (`mmdc`), and LibreOffice were **not installed** on the machine
> used to generate this package, so DOCX/PDF were not compiled automatically. Install the tools
> below, then run the commands. (`Node.js`/`npx` *is* available, which `mermaid-filter`/`mmdc` rely on.)

### 3.1 Install the tools

- **Pandoc** — https://pandoc.org/installing.html (or `winget install --id JohnMacFarlane.Pandoc`)
- **A PDF engine** — e.g. MiKTeX/TeX Live for `xelatex` (recommended for Arabic), or `wkhtmltopdf`.
- **Mermaid CLI** (to turn Mermaid blocks into images) — `npm install -g @mermaid-js/mermaid-cli`
  and the Pandoc filter `npm install -g mermaid-filter`.

### 3.2 Export diagram images (optional but recommended for print)

Mermaid code blocks render in viewers but not in a plain Pandoc PDF unless converted to images. The
simplest route is the `mermaid-filter` Pandoc filter (it auto-renders fenced ```mermaid blocks):

```powershell
# DOCX with auto-rendered Mermaid diagrams + auto TOC
pandoc WeCircle-Documentation.md -o WeCircle-Documentation.docx `
  --toc --toc-depth=3 -F mermaid-filter

# PDF (xelatex recommended for Arabic abstract), numbered sections + TOC + page numbers
pandoc WeCircle-Documentation.md -o WeCircle-Documentation.pdf `
  --toc --toc-depth=3 --number-sections -F mermaid-filter `
  --pdf-engine=xelatex -V mainfont="Times New Roman" -V geometry:margin=1in
```

> For correct Arabic shaping in the PDF, use `xelatex` with a font that covers Arabic (e.g.,
> "Amiri" or "Times New Roman") and consider `-V dir=rtl` only on the Arabic section if you split it.

### 3.3 Reaching the 70–100 page target

The body is ~16k words plus 18 diagrams and 8 tables. With the standard academic template
(12 pt, 1.5 line spacing, 1-inch margins) and the diagrams/screenshots rendered at full size, the
converted document lands in the target range. To increase spacing/page count, add
`-V linestretch=1.5` (LaTeX) or apply your faculty's Word template, and insert the Appendix A
screenshots.

## 4. Diagram inventory (all Mermaid)

Figures 3.1–3.5 (use cases), 4.1 (architecture), 4.2 (ERD), 4.3 (class), 4.4–4.9 (sequence),
4.10–4.11 (activity), 4.12–4.13 (DFD). Tables 2.1, 3.1, 3.2, 4.1, 5.1, 6.1, 7.1, B.1.

## 5. Fidelity statement

Every feature, endpoint, entity, technology, and version in this document was taken from the actual
source code (backend `dashboard/backend`, frontend `dashboard/frontend`, mobile `mobile/`) as of
2026-05-31. Where the repository's own `README`/`CLAUDE.md` disagreed with the code, the code was
treated as ground truth; those corrections are recorded in `00-analysis.md` §10.

---

## 6. ✅ Resolved inputs (provided by the author)

- **University / Faculty:** International Academy for Engineering and Media Science (IAEMS) / Mass
  Communication.
- **Degree:** Bachelor's in Mass Communication — Major in Multimedia and Web/Mobile App Development.
- **Term:** Senior Year / Spring 2026.
- **Team:** Maryam Khamis, Karim El-Saeed, Fadi Emad, Adham El-Shater, Jihad Haggag, Sandy Tharwat.
- **Supervisor:** Dr. Nabil Al-Ghamry.
- **Language:** Bilingual (English body + Arabic abstract). **Citations:** IEEE. **Length:** 70–100 pp.
- **Chapter 2 focus:** Egyptian/Arabic systems. **Screenshots & IDs:** placeholders throughout.

## 7. ⚠️ Open questions & placeholders still to resolve before submission

**Placeholders embedded in the document (search for `[`):**
1. **Student ID numbers** — six `[ID: __________]` slots on the title page (`01-front-matter.md`).
2. **Acknowledgments** — optional additional names / participating school (`01-front-matter.md`).
3. **Appendix A screenshots** — 11 `[Figure: screenshot placeholder]` slots (`09-back-matter.md`).
4. **§6.6 User feedback** — UAT/stakeholder feedback summary and sign-off (`07-chapter6-testing.md`).
5. **References** — optional additional cited sources (`09-back-matter.md`).
6. **Test cases TC-14 & TC-20** — re-verify the timed overdue sweep and AI tenant-isolation prompt
   live during the demo, then update "Actual/Status."

**Facts to confirm with the team (currently stated cautiously in the text):**
7. **Product name** on the title page is **WeCircle** (the Flutter package is internally named
   `wesal`); confirm this is the intended public name.
8. **Notification channels** — SMS/WhatsApp/email are described as *modelled but not yet wired to a
   provider*. Confirm; if a provider was integrated, tell me and I'll update Chapters 1, 5, and 7.
9. **Hosting** — described as a single EC2 instance with pm2 + nginx + Certbot, with ECS/Redis as a
   scaling path. Confirm whether Redis/multi-instance is actually live.
10. **Competitor specifics (Chapter 2 / Table 2.1)** — the comparison reflects publicly described
    capabilities. If you want named Egyptian products with exact, citable feature claims, provide the
    product names/links and I will tighten the table and references.

**Optional enhancements I can do on request:**
- Expand any chapter for more depth/page count (e.g., richer requirement descriptions, more sequence
  diagrams, a fuller field-by-field data dictionary in Appendix E).
- Split the Arabic abstract into a fully mirrored bilingual layout, or translate additional sections.
- Render all Mermaid diagrams to PNG/SVG into `diagrams/` and reference them as images (needs
  `mermaid-cli` installed — say the word and I'll provide a one-shot script).
