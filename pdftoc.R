#! /usr/bin/R

library(tidyverse)
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

  toc %>%
    select(file, title)
}

# Generate entries
wrap_entries <- function(toc){

  template <- '

\\clearpage\\phantomsection
\\addcontentsline{{toc}{{chapter}{{{title}}}
\\includepdf[pages=-,linktodoc,linktodocfit=/Fit]{{{file}}}

'

  toc %>%
    glue_data(template, sep = '\n')

}

preamble <- '\\documentclass{book}

\\usepackage{pdfpages}
\\usepackage{hyperref}

\\begin{document}

\\tableofcontents


'
postamble <- '\n\n\\end{document}\n'

output_file <- glue('pdf_toc_{as.numeric(Sys.time())}.tex')

toc <- read()

entries <- wrap_entries(toc)

output_file

cat(
  preamble,
  entries,
  postamble,
  file = output_file,
  sep = ''
)

Sys.sleep(1)

command_line <- glue('pdflatex {output_file}')

system(command_line)
