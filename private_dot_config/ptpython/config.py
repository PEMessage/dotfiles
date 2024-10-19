from prompt_toolkit.filters import ViInsertMode
from prompt_toolkit.key_binding.key_processor import KeyPress
from prompt_toolkit.keys import Keys
from prompt_toolkit.styles import Style

from ptpython.layout import CompletionVisualisation

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
