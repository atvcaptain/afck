# Text output coloring

# ANSI colors for coloring terminal output
ifeq ($(ANSI),1)
C.RST      = [0m
C.WHITE    = [1;37m
C.LCYAN    = [1;36m
C.LMAGENTA = [1;3m
C.LBLUE    = [1;34m
C.YELLOW   = [1;33m
C.LGREEN   = [1;32m
C.LRED     = [1;31m
C.DGRAY    = [1;30m
C.GRAY     = [0;37m
C.CYAN     = [0;36m
C.MAGENTA  = [0;3m
C.BLUE     = [0;34m
C.BROWN    = [0;33m
C.GREEN    = [0;32m
C.RED      = [0;31m
C.BLACK    = [0;30m
endif

# Color palette - use them instead of direct reference to colors

# Dividers
C.SEP = $(C.DGRAY)
# Titles
C.HEAD = $(C.LGREEN)
# "Underlined" text
C.EMPH = $(C.LBLUE)
# "Highlighted" text
C.BOLD = $(C.WHITE)
# The text of the error message
C.ERR = $(C.LRED)
