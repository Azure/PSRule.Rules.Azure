# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# NOTES:
# This module implements a pygments lexer for Bicep.

# Local testing:
# To test the lexer, you can use the following code snippet:
# pygmentize -l bicep docs/examples/resources/keyvault.bicep

import logging

from pygments.lexer import RegexLexer, bygroups, words, include
from pygments.token import Comment, Operator, Keyword, Name, String, Number, Punctuation, Whitespace

log = logging.getLogger(f"mkdocs")

__all__ = ['BicepLexer',]

BICEP_KEYWORDS = [
    'metadata', 'targetScope', 'for', 'in', 'if', 'existing', 'as', 'with', 'extends', 'assert', 'extension',
]
BICEP_DECLARATIONS = [
    'var', 'func', 'type'
]
BICEP_DECORATORS = [
    'secure', 'metadata', 'description', 'export', 'maxLength', 'minLength', 'allowed'
]

class BicepLexer(RegexLexer):
    '''A lexer for Bicep.'''
    name = 'Bicep'
    aliases = ['bicep']
    filenames = ['*.bicep']

    log.warning(f"Loading Bicep lexer")

    tokens = {
        'root': [
            (words(['import', 'using'], suffix=' '), Keyword.Namespace),

            (r'^(param)(\s)(\w+)(\s)(\w+)', bygroups(Keyword.Declaration, Whitespace, Name.Symbol, Whitespace, Name.Type), 'param'),
            (r'^(output)(\s)(\w+)(\s)(\w+)', bygroups(Keyword.Declaration, Whitespace, Name.Symbol, Whitespace, Name.Type), 'output'),

            (r'^(resource)(\s)(\w+)', bygroups(Keyword.Declaration, Whitespace, Name.Symbol), 'resource'),
            (r'^(module)(\s)(\w+)', bygroups(Keyword.Declaration, Whitespace, Name.Symbol), 'module'),

            (words(BICEP_DECLARATIONS, suffix=' ', prefix='\n'), Keyword.Declaration),
            (r'^(\@)(secure|metadata|description|export|maxLength|minLength|allowed)(\()', bygroups(Keyword.Decorator, Keyword.Decorator, Punctuation), 'decorator'),
            (words(BICEP_KEYWORDS, suffix=r'\b'), Keyword),

            include('core'),
        ],
        'core': [
            (r'(\[)(for)', bygroups(Punctuation, Keyword), 'loop'),
            include('comments'),
            include('complex'),
            include('literal'),
            (r'\n', Whitespace),
            (r'\s+', Whitespace),
            (r'\=|\+|\-', Operator),
        ],
        'numbers': [
            (r"\d+[.]\d*|[.]\d+", Number.Float),
            (r"\d+", Number.Integer),
        ],
        'literal': [
            include('numbers'),
            (r"'", String, 'single_string'),
            (r'(true|false|null)\b', Keyword.Constant),
        ],
        'complex': [
            (r'\{', Punctuation, 'object'),
            (r'\[', Punctuation, 'array'),
        ],
        'comments': [
            (r'//.*?$', Comment.Single),
            (r'/\*', Comment.Multiline, 'multiline-comments'),
        ],
        'multiline-comments': [
            (r'.*?\*/', Comment.Multiline, '#pop'),
            (r'.+', Comment.Multiline),
        ],
        'decorator': [
            (r'\)', Punctuation, '#pop'),
            (r'\n', Whitespace, '#pop'),
            (r'\s+', Whitespace),
            include('literal'),
            include('complex'),
            include('comments'),
        ],
        'single_string': [
            (r"'", String, "#pop"),
            (r"\\.", String.Escape),
            (r"[^'\\]+", String),
        ],
        'array': [
            (r',', Punctuation),
            (r'\]', Punctuation, '#pop'),
            include('core'),
        ],
        'object': [
            (r'(\s+)(\w+)(\:)', bygroups(Whitespace, Name.Property, Punctuation)),
            (r'\s+', Whitespace),
            (r'\}', Punctuation, '#pop'),
            include('core'),
        ],
        'param': [
            (r'\n', Whitespace, '#pop'),
            (r'\=', Operator, '#pop'),
        ],
        'output': [
            (r'\n', Whitespace, '#pop'),
            (r'\=', Operator, '#pop'),
        ],
        'resource': [
            (r"'", String, 'single_string'),
            (words(['existing']), Keyword),
            (r'\n', Whitespace, '#pop'),
            (r'\=', Operator, '#pop'),
        ],
        'module': [
            (r"'", String, 'single_string'),
            (r'\n', Whitespace, '#pop'),
            (r'\=', Operator, '#pop'),
        ],
        'loop': [
            (words(['in', 'range', 'items']), Keyword),
            (r'\(|\)|\,', Punctuation),
            (r'\:', Punctuation, '#pop'),
            include('core'),
        ],
        'condition': [
            (r'\)', Punctuation, '#pop'),
            include('literal'),
        ]
    }
