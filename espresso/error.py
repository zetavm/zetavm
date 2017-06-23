"""Errors used in Espresso front-end"""

class Error(Exception):
    """Base error class"""
    pass

class ParseError(Error):
    """Error that occurs at parsing time"""
    def __init__(self, input_obj, msg):
        new_msg = "A parsing error occured in the file: " + input_obj.src_name \
        + "at: " + input_obj.row_no + ":" + input_obj.col_no + "\n" + msg
        super(ParseError, self).__init__(new_msg)
        