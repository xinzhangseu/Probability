#!/usr/bin/env python3
"""Build continuous PDF chapter sources from the HTML section pages."""

from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

CHAPTERS = (
    ("template_chapter1.qmd", "sections/elegantbook", "_pdf_template_chapter1.qmd"),
    ("chap1.qmd", "sections/test", "_pdf_chap1.qmd"),
    ("chap2.qmd", "sections/chapter2", "_pdf_chap2.qmd"),
)


def section_for_pdf(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or not lines[0].startswith("# "):
        raise ValueError(f"{path}: first line must be a level-one heading")

    title = lines[0][2:].strip()
    suffix = " {.unnumbered}"
    if title.endswith(suffix):
        title = title[: -len(suffix)].rstrip()

    first_word, separator, remainder = title.partition(" ")
    if separator and first_word.count(".") == 1:
        left, right = first_word.split(".")
        if left.isdigit() and right.isdigit():
            title = remainder

    body = "\n".join(lines[1:]).strip()
    return f"## {title}\n\n{body}\n"


def build_chapter(chapter_file: str, section_dir: str, output_file: str) -> None:
    chapter = (ROOT / chapter_file).read_text(encoding="utf-8").rstrip()
    sections = sorted((ROOT / section_dir).glob("*.qmd"))
    if not sections:
        raise ValueError(f"{section_dir}: no section files found")

    combined = [chapter]
    combined.extend(section_for_pdf(path).rstrip() for path in sections)
    (ROOT / output_file).write_text("\n\n".join(combined) + "\n", encoding="utf-8")


if __name__ == "__main__":
    for chapter_file, section_dir, output_file in CHAPTERS:
        build_chapter(chapter_file, section_dir, output_file)
