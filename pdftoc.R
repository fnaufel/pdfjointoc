library(readr)
library(dplyr)
library(glue)

# Read the .org file
read <- function(filename = 'toc.org') {

  toc <- read_delim(
    filename,
    delim = '|',
    escape_backslash = FALSE,
    escape_double = FALSE,
    col_names = c('x', 'file', 'title', 'y'),
    col_types = 'cccc',
    trim_ws = TRUE,
  )

  select(toc, file, title)
}

# Generate entries
wrap_entries <- function(toc){

  template <- '

\\clearpage\\phantomsection
\\addcontentsline{{toc}{{chapter}{{{title}}}
\\includepdf[pages=-,linktodoc,linktodocfit=/Fit]{{{file}}}

'
  glue_data(toc, template, sep = '\n')

}

preamble <- '\\documentclass{book}
\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{pdfpages}
\\usepackage{hyperref}

\\begin{document}

\\tableofcontents


'
postamble <- '\n\n\\end{document}\n'

output_file <- 'pdf_toc.tex'

toc <- read()

entries <- wrap_entries(toc)

cat(
  preamble,
  entries,
  postamble,
  file = output_file,
  sep = ''
)

# invisible(
#   readline(prompt="TOC file generated. \nPress [enter] to compile: ")
# )

Sys.sleep(1)

command_line <- 'pdflatex'

system2(
  command_line,
  output_file
)

Sys.sleep(1)

system2(
  command_line,
  output_file
)

