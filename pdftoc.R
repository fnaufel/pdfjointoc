library(readr)
library(dplyr)
library(tidyr)
library(glue)
library(stringr)


######### Functions

escape_latex <- function(s) {

  # TODO

}

strip_extension <- function(filename) {

  return(str_remove(filename, '\\.[^.]+$'))

}

# Read and process the toc.txt file
get_toc_specs <- function() {

  toc_filename <- 'toc.txt'
  toc <- read_delim(
    toc_filename,
    delim = '|',
    escape_backslash = FALSE,
    escape_double = FALSE,
    trim_ws = TRUE,
    col_names = c('filename', 'title')
  )

  # Replace NAs in title column with corresponding filename
  # (without the extension)
  toc <- toc %>%
    mutate(title = coalesce(title, strip_extension(filename)))

  return(toc)

}

# Generate LaTeX code for each entry
wrap_entries <- function(toc){

  # Title string must not have unescaped LaTeX characters
  toc <- mutate(toc, title = escape_latex(title))

  template <- '

\\clearpage\\phantomsection
\\addcontentsline{toc}{chapter}{<title>}
\\includepdf[pages=-,linktodoc,linktodocfit=/Fit]{<filename>}

'
  retval <- glue_data(
    toc,
    template,
    sep = '\n',
    .open = '<',
    .close = '>'
  )

  return(retval)

}

####### Main

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

toc <- get_toc_specs()
entries <- wrap_entries(toc)
cat(
  preamble,
  entries,
  postamble,
  file = output_file,
  sep = ''
)

command_line <- 'pdflatex'

Sys.sleep(1)

# Compile
system2(
  command_line,
  output_file
)

# Wait...
Sys.sleep(1)

# And compile again
system2(
  command_line,
  output_file
)

