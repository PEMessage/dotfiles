# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "pymupdf",
# ]
# ///

import sys
import fitz

def main() -> None:
    pdf_file = sys.argv[1]
    doc = fitz.open(pdf_file)
    for i, page in enumerate(doc):
        pix = page.get_pixmap()
        pix.save(f"page_{i+1}.png")


if __name__ == "__main__":
    main()
