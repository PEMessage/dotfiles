from prompt_toolkit.filters import ViInsertMode
from prompt_toolkit.key_binding.key_processor import KeyPress
from prompt_toolkit.keys import Keys
from prompt_toolkit.styles import Style

from ptpython.layout import CompletionVisualisation
# import pudb
from textwrap import dedent

__all__ = ["configure"]


def configure(repl):
    repl.enable_mouse_support = False
    repl.enable_auto_suggest = True
    repl.color_depth = "DEPTH_24_BIT"
    repl.min_brightness = 0.4
    repl.max_brightness = 1.0

    @repl.add_key_binding(Keys.ControlB)
    def _(event):
        ' Pressing Control-B will insert "pdb.set_trace()" '
        event.cli.current_buffer.insert_text('\nimport pdb; pdb.set_trace()\n')

    # Debug Only
    # @repl.add_key_binding(Keys.ControlQ)
    # def _(event):
    #     a = repl
    #     pudb.set_trace()

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



