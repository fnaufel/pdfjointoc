library(readr)
library(dplyr)
library(tidyr)
library(glue)
library(stringr)


####################################################
# Functions
####################################################


strip_extension <- function(filename) {

  return(str_remove(filename, '\\.[^.]+$'))

}


# Read and process the toc.txt file
# Return tbl
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

  # return tbl
  return(toc)

}


escape_latex <- function(s) {

  str_replace_all(
    s,
    '[_^%$]',
    '-'
  )

}


# Generate LaTeX code for each entry
# Parameter is tbl
# Returns string
wrap_entries <- function(toc){

  # Title string must not have unescaped LaTeX characters
  toc <- mutate(toc, title = escape_latex(title))

  template <- '

\\clearpage\\phantomsection
\\addcontentsline{toc}{chapter}{<title>}
\\includepdf[pages=-]{<filename>}

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


# Write .tex file
# Param is string: toc
# Returns string: filename
write_tex_file <- function(toc) {

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

  cat(
    preamble,
    toc,
    postamble,
    file = output_file,
    sep = ''
  )

  return(output_file)

}


# Compile LaTeX file
# Param: tex file name
compile <- function(filename) {

  command_line <- 'pdflatex'

  Sys.sleep(1)

  # Compile
  system2(
    command_line,
    filename
  )

  # Wait...
  Sys.sleep(1)

  # And compile again
  system2(
    command_line,
    filename
  )

}


####################################################
# Main
####################################################

get_toc_specs() %>%
  wrap_entries() %>%
  write_tex_file() %>%
  compile()
