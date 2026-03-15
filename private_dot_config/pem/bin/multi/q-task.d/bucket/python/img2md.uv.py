#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "ollama",
# ]
# ///

"""Convert images to Markdown using Ollama vision models."""

import argparse
import sys
from pathlib import Path

import ollama


DEFAULT_MODEL = "qwen3.5:4b"
DEFAULT_HOST = "http://localhost:11434"

PROMPT = """Extract all readable text from this image and format it as structured Markdown.

Requirements:
- Preserve the original text structure (headings, paragraphs, lists)
- Format tables properly using markdown table syntax
- Keep any code blocks with proper formatting
- Maintain the reading order from top to bottom, left to right
- If you see mathematical equations, format them using LaTeX within $$ or $"""


def list_models(host: str) -> None:
    """Display available Ollama models."""
    client = ollama.Client(host=host)
    try:
        models = client.list()
        print("Available models:")
        for model in models.models:
            print(f"  - {model.model}")
    except Exception as e:
        print(f"Error listing models: {e}", file=sys.stderr)
        sys.exit(1)


def image_to_markdown(image_path: Path, model: str, host: str):
    """Convert an image to Markdown using specified model."""
    client = ollama.Client(host=host)

    with open(image_path, "rb") as f:
        image_bytes = f.read()

    response = client.chat(
        model=model,
        messages=[{
            "role": "user",
            "content": PROMPT,
            "images": [image_bytes],
        }],
        stream=True,
    )

    for chunk in response:
        if chunk.message and chunk.message.content:
            yield chunk.message.content


def main():
    parser = argparse.ArgumentParser(
        description="Convert images to Markdown using Ollama vision models."
    )
    parser.add_argument(
        "images",
        type=Path,
        nargs="*",
        help="Path(s) to image file(s)",
    )
    parser.add_argument(
        "-m", "--model",
        default=DEFAULT_MODEL,
        help=f"Model to use (default: {DEFAULT_MODEL})",
    )
    parser.add_argument(
        "--host",
        default=DEFAULT_HOST,
        help=f"Ollama host URL (default: {DEFAULT_HOST})",
    )
    parser.add_argument(
        "--list-models",
        action="store_true",
        help="List available Ollama models and exit",
    )

    args = parser.parse_args()

    if args.list_models:
        list_models(args.host)
        return

    if not args.images:
        parser.error("image path(s) are required (unless using --list-models)")

    errors = []
    for i, image_path in enumerate(args.images):
        if not image_path.exists():
            errors.append(f"File not found: {image_path}")
            continue

        if i > 0:
            print(f"\n{'=' * 60}\n")

        print(f"<!-- Processing: {image_path} -->\n")

        try:
            for chunk in image_to_markdown(image_path, args.model, args.host):
                print(chunk, end="", flush=True)
            print()  # Final newline
        except Exception as e:
            errors.append(f"Error processing {image_path}: {e}")

    if errors:
        print("\n\n<!-- Errors: -->", file=sys.stderr)
        for error in errors:
            print(f"<!-- {error} -->", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
