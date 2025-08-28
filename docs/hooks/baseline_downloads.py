# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# NOTES:
# This file implements adding CSV download links to baseline documentation pages.

import logging
import os
import re

from mkdocs.config.defaults import MkDocsConfig
from mkdocs.structure.files import File, Files
from mkdocs.structure.pages import Page

log = logging.getLogger(f"mkdocs")

#
# Hooks
#

def on_page_markdown(markdown: str, *, page: Page, config: MkDocsConfig, files: Files) -> str:
    '''Hook on_page_markdown event to add CSV download links to baseline pages.'''
    
    if is_baseline_page(page):
        return add_csv_download_link(markdown, page)
    
    return markdown

#
# Supporting functions
#

def is_baseline_page(page: Page) -> bool:
    '''Check if the page is a baseline page.'''
    
    # Check if the page is in the baselines directory
    if page.file.src_path.startswith('en/baselines/') and page.file.src_path.endswith('.md'):
        return True
    
    return False

def add_csv_download_link(markdown: str, page: Page) -> str:
    '''Add CSV download link to baseline markdown.'''
    
    log.debug(f"Adding CSV download link for baseline page: {page.file.src_path}")
    
    # Extract baseline name from file path (e.g., en/baselines/Azure.GA_2025_06.md -> Azure.GA_2025_06)
    baseline_name = os.path.splitext(os.path.basename(page.file.src_path))[0]
    csv_filename = f"{baseline_name}.csv"
    
    # Find the pattern where we want to insert the download link
    # Look for the pattern: "This baseline includes a total of X rules."
    pattern = r'(This baseline includes a total of \d+ rules\.)'
    
    # Create the download link as a hyperlink (not a button as requested)
    download_link = f'\n\n[Download CSV]({csv_filename})'
    
    # Replace the pattern with the original text plus the download link
    result = re.sub(pattern, r'\1' + download_link, markdown)
    
    return result