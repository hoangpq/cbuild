# xfun::read_utf8(), also used by reprex
read_lines <- function(con, error = TRUE) {
  opts = options(encoding = "native.enc")
  on.exit(options(opts), add = TRUE)
  x = readLines(con, encoding = "UTF-8", warn = FALSE)
  i = which(!is.na(x) & is.na(iconv(x, "UTF-8", "UTF-8")))
  n = length(i)
  if (n > 0)
    (if (error)
      stop
     else warning)(if (is.character(con))
       c("The file ", con, " is not encoded in UTF-8. "),
       "These lines contain invalid UTF-8 characters: ",
       paste(c(utils::head(i), if (n > 6) "..."), collapse = ", "))
  x
}

write_lines <- function(file, lines, sep = "") {
  writeLines(lines, file, sep = sep)
  invisible(file)
}

new_signature_df <- function(loc = integer(), attribute = character(), args = list(), signature = list()) {
  data_frame(loc = loc, attribute = attribute, args = args, signature = signature)
}

new_attribute_df <- function(loc = integer(), attribute = character(), args = list()) {
  data_frame(loc = loc, attribute = attribute, args = args)
}

new_argument_df <- function(attribute = character(), args = list()) {
  data_frame(attribute = attribute, args = args)
}

new_data_frame <- function(x = list(), n = NULL) {
  is_empty <- length(x) == 0L

  if (is.null(n)) {
    if (is_empty) {
      n <- 0L
    } else {
      n <- length(x[[1L]])
    }
  }

  n <- as.integer(n)

  if (is_empty) {
    names(x) <- character()
  }

  new_attributes <- list(
    names = names(x),
    class = "data.frame",
    row.names = .set_row_names(n)
  )

  attributes(x) <- new_attributes

  x
}

data_frame <- function(...) {
  x <- list(...)
  new_data_frame(x)
}

abort <- function(...) {
  stop(..., call. = FALSE)
}

abort_problem_parsing <- function(what, problem) {
  msg <- paste0(
    problem,
    "\n",
    "Problem parsing: `", what, "`."
  )

  abort(msg)
}

grepl_fixed <- function(x, pattern) {
  grepl(pattern, x, fixed = TRUE)
}

double_quote <- function(x) {
  encodeString(x, quote = "\"", na.encode = FALSE)
}

unnest_args <- function(attributes) {
  args <- attributes$args
  attributes$args <- NULL

  if (nrow(attributes) == 0L) {
    return(attributes)
  }

  lst_of_one_row_arg_dfs <- map(
    args,
    as.data.frame,
    stringsAsFactors = FALSE
  )

  arg_df <- do.call(rbind, lst_of_one_row_arg_dfs)

  if (nrow(arg_df) == 0L) {
    attributes
  } else {
    cbind(attributes, arg_df)
  }
}
