#!/bin/bash

cat <<EOF
import playwright
from playwright.sync_api import sync_playwright
from playwright.async_api import async_playwright
from bs4 import BeautifulSoup

p = sync_playwright().start()
browser = p.chromium.launch(headless=False)
page = browser.new_page()
page.goto("https://www.baidu.com")
EOF

echo ================================

uv run --with playwright --with ptpython --with beautifulsoup4 \
    ptpython
