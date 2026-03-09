# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "pymupdf",
# ]
# ///

import sys
import fitz
from pathlib import Path

def main() -> None:
    pdf_file = sys.argv[1]

    # Use second argument if provided, otherwise default to "pdf_images"
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "pdf_images"
    Path(output_dir).mkdir(exist_ok=True)

    doc = fitz.open(pdf_file)
    total_pages = len(doc)
    padding = len(str(total_pages))  # Calculate padding based on total pages

    for i, page in enumerate(doc):
        pix = page.get_pixmap()
        page_num = str(i + 1).zfill(padding)
        pix.save(f"{output_dir}/page_{page_num}.png")


if __name__ == "__main__":
    main()
