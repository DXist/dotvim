python << EOF
import os
import re
import sys
import vim

re_class_name = re.compile(r'class (\w+)')
re_method_name = re.compile(r'\s*def (test\w+)')


def get_test_name(lines):
    """
    >>> get_test_case_class(['class MyClass:', 'pass'])
    'MyClass'
    >>> get_test_case_class(['class MyClass():', 'pass'])
    'MyClass'
    >>> get_test_case_class(['', ''])
    >>> get_test_case_class(['class MyClass():', '', 'def test_foo():', 'pass'])
    'MyClass.test_foo'
    >>> get_test_case_class(['class MyClass():', '', '    def test_foo():', 'pass'])
    'MyClass.test_foo'
    >>> get_test_case_class(['class MyClass():', '',
    ...                      '    def test_foo():', 'pass',
    ...                      '    def test_bar():', 'pass'])
    'MyClass.test_bar'
    """
    methodname = None
    for line in reversed(lines):
        if line.startswith('class '):
            m = re_class_name.match(line)
            if m:
                if methodname:
                    return "{0}.{1}".format(m.group(1), methodname)
                else:
                    return m.group(1)
        elif not methodname and 'def test' in line:
            m = re_method_name.match(line)
            if m:
                methodname = m.group(1)
    return None


def vim_escape(str):
    """
    >>> print(vim_escape(r'python %'))
    python\ %
    """
    return str.replace('\\', r'\\').\
               replace(' ',  r'\ ').\
               replace('"',  r'\"')


def run_test(makeprg=None):
    if not makeprg:
        makeprg = vim.eval('&makeprg')

    errorformat = vim_escape(r' %#File "%f"\, line %l\, %m')
    for cmd in [
            'setlocal makeprg={0}'.format(vim_escape(makeprg)),
            'setlocal errorformat={0}'.format(errorformat),
            'silent! make!',
            'copen 25',
            'wincmd w',
            'redraw!',
        ]:
        vim.command(cmd)
    print(r'tested: {0}'.format(makeprg))


def RunUnitTestsUnderCursor():
    (row, col) = vim.current.window.cursor
    filename = vim.eval("bufname('%')")
    module_name = os.path.basename(filename).split('.py')[0]
    dirname = os.path.dirname(filename)
    testname = get_test_name(vim.current.buffer[0:row])

    if testname:
        test = '{0}.{1}'.format(module_name, testname)
    else:
        test = module_name

    exists = int(vim.eval('exists("b:lighthouse_make_prg")'))
    python_path = dirname
    extra_path = os.environ.get('PYTHONPATH')
    if extra_path:
        python_path = ':'.join((python_path, extra_path))

    if exists:
        makeprg = vim.eval('b:lighthouse_make_prg')
        makeprg = 'PYTHONPATH="{0}" {1} {2}'.format(python_path, makeprg, test)
    else:
        makeprg = 'PYTHONPATH="{0}" python -m unittest {1}'.format(python_path, test)

    run_test(makeprg)

EOF
" vim: et
