"""Input takes care of reading the input"""

from e_error import ParseError

class Input(object):
    """The Input class is the one responsible for reading the input"""
    str_idx = 0
    col_no = 1
    row_no = 1
    def __init__(self, file_name, file_content):
        self.src_name = file_name
        self.str_in = file_content
    def peek_ch(self):
        """Peek a character from the input"""
        if self.str_idx >= len(self.str_in):
            return '\0'
        return self.str_in[self.str_idx]
    def read_ch(self):
        """Read a char from the input"""
        ch = self.peek_ch()
        if (ord(ch) < 0x20 or ord(ch) > 0x7E) and ch != '\n' and ch != '\t' and ch != '\r':
            hex_str = hex(ord(ch))
            raise ParseError(self, "invalid character: " + hex_str)
        self.str_idx += 1
        if ch == '\n':
            self.row_no += 1
            self.col_no = 1
        else:
            self.col_no += 1
        return ch
    def eof(self):
        """Check if we are at the end of the input"""
        return self.peek_ch() == '\0'
    def next(self, string):
        """Peek to check if a string is next in the input"""
        if len(self.str_in) - (self.str_idx + len(string)) < 0:
            return False
        for idx in range(len(string)):
            if string[idx] != self.str_in[self.str_idx + idx]:
                return False
        return True
    def match(self, string):
        """Check if the string is next in the input. If yes, consume it"""
        assert len(string) > 0, "Trying to match empty string"
        if self.next(string):
            for _ in string:
                self.read_ch()
            return True
        return False
    def expect(self, string):
        "Try to match a string in the input. If it fails raise a ParseError"
        if not self.match(string):
            raise ParseError(self, "Expected to find: " + string)
    def eat_ws(self):
        """Consume whitespace in the input"""
        while True:
            if self.eof():
                return
            if self.peek_ch().isspace():
                self.read_ch()
                continue
            if self.match("//"):
                while True:
                    if self.eof():
                        return
                    if self.read_ch() == '\n':
                        break
                continue
            break
    def next_ws(self, string):
        """Version of next that consumes preceding whitespace"""
        self.eat_ws()
        return self.next(string)
    def match_ws(self, string):
        """Version of match that consumes preceding whitespace"""
        self.eat_ws()
        return self.match(string)
    def expect_ws(self, string):
        """Version of expect that consumes preceding whitespace"""
        self.eat_ws()
        self.expect(string)
    def match_kw(self, string):
        """Match a keyword"""
        self.eat_ws()
        if not self.next(string):
            return False

        length = len(string)

        # If we're at the end of the string, this is a match
        if self.str_idx + length >= len(self.str_in):
            self.match(string)
            return True
        post_ch = self.str_in[self.str_idx + length]

        # If the next character is valid in an identifier, then
        # this is not a real match
        if post_ch.isalnum() or post_ch == '_':
            return False

        self.match(string)
        return True

    