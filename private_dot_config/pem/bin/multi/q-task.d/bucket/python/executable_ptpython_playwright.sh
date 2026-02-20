#!/bin/bash

cat <<EOF
import playwright
from playwright.sync_api import sync_playwright
from playwright.async_api import async_playwright
from bs4 import BeautifulSoup
from objprint import op


p = sync_playwright().start()
browser = p.chromium.launch(headless=False)
page = browser.new_page()

# page.goto("https://www.baidu.com")
EOF

echo
echo ================================
echo


cat <<EOF
1. print all <a herf=*>
op(
    [{e.inner_text(), e.get_attribute('href') } for e in  page.query_selector_all('a')]
)

2. all button
    [ e.inner_text(), for e in  page.query_selector_all('button')]

3. print element it's html
    e.evaluate('el => el.outerHTML')

4.1 CSS attrbute selector `<div data-key="chapters">List</div>`
    page.query_selector('[data-key="chapters"]')

4.2 CSS attrbute include selector
    # 完全匹配onclick属性
    button = page.query_selector('button[onclick="getChapterList()"]')

    # 以特定值开头的onclick
    button = page.query_selector('button[onclick^="getChapterList"]')

    # 以特定值结尾的onclick
    button = page.query_selector('button[onclick$="getChapterList"]')

    # 组合其他属性
    button = page.query_selector('button[onclick*="getChapterList"].active')

EOF

uv run --with playwright --with ptpython --with beautifulsoup4 --with objprint \
    ptpython
