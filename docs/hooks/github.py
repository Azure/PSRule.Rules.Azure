# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# NOTES:
# This file implements links to GitHub users on enabled markdown pages.

import logging
import re

from mkdocs.config.defaults import MkDocsConfig
from mkdocs.structure.files import Files
from mkdocs.structure.pages import Page

log = logging.getLogger(f"mkdocs")

#
# Hooks
#

def on_page_markdown(markdown: str, *, page: Page, config: MkDocsConfig, files: Files) -> str:
    '''Hook on_page_markdown event.'''

    if page.meta.get('link_users', 'false') != 'false':
        return re.sub(r"\@([\w-]*)", r"[@\g<1>](https://github.com/\g<1>)", markdown)

    return markdown
