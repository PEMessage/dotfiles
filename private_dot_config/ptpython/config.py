from prompt_toolkit.filters import ViInsertMode
from prompt_toolkit.key_binding.key_processor import KeyPress
from prompt_toolkit.keys import Keys
from prompt_toolkit.styles import Style

from ptpython.layout import CompletionVisualisation
# import pudb
from textwrap import dedent
from ptpython.style import get_all_styles

__all__ = ["configure"]


def configure(repl):
    repl.enable_mouse_support = True
    repl.enable_auto_suggest = True
    repl.color_depth = "DEPTH_24_BIT"
    repl.min_brightness = 0.4
    repl.max_brightness = 1.0

    @repl.add_key_binding(Keys.ControlB)
    def _(event):
        ' Pressing Control-B will insert "pdb.set_trace()" '
        event.cli.current_buffer.insert_text('\nimport pdb; pdb.set_trace()\n')

    try:
        # Debug Only
        import pudb

        @repl.add_key_binding(Keys.ControlQ)
        def _(event):
            # a = repl
            pudb.set_trace()
    except:  # noqa E261
        # print("pudb not load")
        pass
    else:
        # print("pudb is load, your could use CtrlQ to call it")
        pass

    @repl.add_key_binding(Keys.ControlT)
    def _(event):
        repl.enter_history()

    repl.eval(dedent('''
    def q_bread(file_path):
        """Quick binary read from a file."""
        with open(file_path, 'rb') as f:
            return f.read()

    def q_bwrite(file_path, data, ensure_dir=False):
        """Quick binary write to a file."""
        if ensure_dir:
            dir_path = os.path.dirname(file_path)
            if dir_path and not os.path.exists(dir_path):
                os.makedirs(dir_path)
        with open(file_path, 'wb') as f:
            f.write(data)
    globals().update({
        'q_bread': q_bread,
        'q_bwrite': q_bwrite,
    })
    '''))

    def style_cycler():
        """Generator that cycles through all available ptpython styles."""

        # all_styles = list(get_all_styles())
        all_styles = ['paraiso-dark', 'native', 'rainbow_dash', 'stata-dark']
        index = 0

        while True:
            style_name = all_styles[index]
            yield style_name

            # Move to next index, wrap around if needed
            index = (index + 1) % len(all_styles)

    style_generator = style_cycler()

    def next_style():
        """Apply the next color scheme in the cycle."""
        style = next(style_generator)
        repl.use_code_colorscheme(style)
        print(f"Applied style: {style}")

    # Your could use CtrlQ using pudb, to play with repl
    repl.get_globals().update({
        'ptpython_self_repl': repl,
        'ptpython_next_style': next_style
        })

    # https://github.com/prompt-toolkit/ptpython/issues/45
    # list(ptpython.style.get_all_styles())
    repl.use_code_colorscheme('native')



