" File: py-test-runner.vim
" Author: Mantas Zimnickas <sirexas@gmail.com>
" Version: 0.1
" Created: 2011-01-25
" Last Modified: 2011-01-27
"
" This script runs current python file and shows output in quickfix window.
"
" If a file is Django tests file, then Django tests for this file, test case
" class or method will be run. Script detects what tests should be run, by
" current cursor position.
"
" Script also detects what python should be run. If your vim's CWD is set to an
" virtualent, that has bin/python, then bin/python will be used instead global
" python.
"
" Install
" =======
"
" Copy py-test-runner.vim to your ~/.vim/plugin/ and restart vim or::
"
"   :source ~/.vim/plugin/py-test-runner.vim
"
" Usage
" =====
"
" In your .vimrc add::
"
"   map     <F8> :python RunUnitTestsUnderCursor()<CR>
"
" Open any python file, specify how that file should be tested::
"
"   if __name__ == '__main__':
"       unittest.main()
"
" or::
"
"   if __name__ == '__main__':
"       doctest.testmod()
"
" And press <F8>.

python << EOF
import os
import re
import vim

re_class_name = re.compile(r'class (\w+)')
re_method_name = re.compile(r'\s*def (test\w+)')


def get_django_appname(filename):
    """
    >>> get_django_appname('~/devel/django-plugins/plugins/tests.py')
    'payment'
    >>> get_django_appname('~/devel/django-plugins/setup.py')
    """
    filename = os.path.expanduser(filename)
    filename = os.path.abspath(filename)
    dirs = os.path.dirname(filename).split(os.path.sep)
    while dirs:
        path = os.path.sep.join(dirs)
        if os.path.exists(os.path.join(path, 'models.py')):
            return os.path.basename(path)
        dirs.pop()
    return None


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


def get_prg(prgs, default=None):
    cwd = vim.eval('getcwd()')
    for prg in prgs:
        full_prg_path = os.path.join(cwd, prg)
        if os.path.exists(full_prg_path):
            return prg
    return default


def RunUnitTestsUnderCursor():
    (row, col) = vim.current.window.cursor
    filename = vim.eval("bufname('%')")
    appname = get_django_appname(filename)
    pythonprg = get_prg(('bin/python',), default='python')
    djangoprg = '%s %s' % (pythonprg, get_prg(('manage.py', 'bin/django')))

    if appname and djangoprg:
        from django.conf import settings
        options = "--verbosity=0 --noinput"
        try:
            options += " --settings=%s" % os.environ['DJANGO_SETTINGS_MODULE']
        except KeyError:
            pass

        use_nose = settings.TEST_RUNNER.startswith('django_nose')

        testname = get_test_name(vim.current.buffer[0:row])
        test_suffix = testname
        test_prefix = appname + '.tests' if use_nose else appname
        delimiter = ':' if use_nose else '.'

        if testname:
            teststring = test_prefix + delimiter + test_suffix
        else:
            teststring = test_prefix

        makeprg = '{0} test {1} {2}'.\
                      format(djangoprg, options, teststring)
    else:
        makeprg = '{0} {1}'.format(pythonprg, filename)
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
EOF
" vim: et
