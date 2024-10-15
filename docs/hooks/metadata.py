# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# NOTES:
# This file implements loading of external metadata for pages.

import logging
import os
import json

from mkdocs.config.defaults import MkDocsConfig
from mkdocs.structure.files import File, Files
from mkdocs.structure.pages import Page

log = logging.getLogger(f"mkdocs")

#
# Hooks
#

def on_pre_page(page: Page, config: MkDocsConfig, files: Files) -> Page:
    '''Hook on_pre_page event.'''

    return load_metadata(page)


def on_page_markdown(markdown: str, *, page: Page, config: MkDocsConfig, files: Files) -> str:
    '''Hook on_page_markdown event.'''

    read_from_page(markdown, page)
    return markdown


#
# Supporting functions
#

def load_metadata(page: Page) -> Page:
    '''Load built metadata for a page from JSON.'''

    if page.canonical_url.__contains__('/rules/'):
        name = page.canonical_url.split("/")[-2]
        if name != None:
            return read_metadata(page, name)

    return page


def read_metadata(page: Page, name: str) -> Page:
    '''Read the metadata for a rule.'''

    log.debug(f"Loading metadata for page: {page.abs_url}")

    meta = {}
    meta['rule'] = name

    file: str = os.path.join(os.path.dirname(page.file.abs_src_path), 'metadata.json')
    with open(file) as f:
        data = json.load(f)
        if data.get(name, None) != None and data[name].get('Ref', None) != None and data[name]['Ref'].get('Name', None) != None:
            meta['ref'] = data[name]['Ref']['Name']

        if data.get(name, None) != None and data[name].get('Release', None) != None:
            meta['release'] = data[name]['Release']

        if data.get(name, None) != None and data[name].get('RuleSet', None) != None:
            meta['ruleSet'] = data[name]['RuleSet']

        if data.get(name, None) != None and data[name].get('Level', None) != None:
            meta['level'] = data[name]['Level']

        if data.get(name, None) != None and data[name].get('Synopsis', None) != None:
            description = data[name]['Synopsis']
            meta['description'] = description

        if data.get(name, None) != None and data[name].get('Source', None) != None:
            meta['source'] = data[name]['Source']

        if data.get(name, None) != None and data[name].get('Alias', None) != None and len(data[name]['Alias']) > 0:
            log.debug(f"Found page alias {data[name]['Alias']} for: {page.abs_url}")
            aliases = []
            for alias in data[name]['Alias']:
                aliases.append(alias)

            meta['alias'] = aliases

        if data.get(name, None) != None and data[name].get('Control', None) != None and len(data[name]['Control']) > 0:
            mcsb = []
            for control in data[name]['Control']:
                mcsb.append(control)

            meta['mcsb'] = mcsb

    page.__annotations__['__psrule__'] = meta
    return page

def read_from_page(markdown: str, page: Page):
    '''Read metadata from the markdown content.'''

    if markdown.__contains__("<!-- EXPERIMENTAL -->"):
        page.meta['experimental'] = 'true'

    if markdown.__contains__("<!-- OBSOLETE -->"):
        page.meta['obsolete'] = 'true'

    # Base on page location
    if page.canonical_url.__contains__("/baselines/"):
        page.meta['template'] = 'reference.html'
        page.meta['generated'] = 'true'
        page.meta['type'] = 'baseline'

    if page.canonical_url.__contains__("/rules/") and page.meta.get("pillar", "None") != "None":
        page.meta['type'] = 'rule'
