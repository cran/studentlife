#' download_studentlife
#'
#' Download the entire StudentLife dataset or
#' a smaller sample dataset for testing.
#'
#' If \code{url = "rdata"} then data will be downloaded
#' from <https://zenodo.org/record/3529253>
#' If \code{url = "dartmouth"} then data will be downloaded
#' from <https://studentlife.cs.dartmouth.edu/dataset/dataset.tar.bz2>
#' If \code{url = "testdata"} then data will be downloaded
#' from the test data at the studentlife GitHub repository
#' <https://github.com/frycast/studentlife>
#'
#'
#'@param url A character string. Either
#'"rdata" for the URL to the (more efficient)
#'RData format version hosted on Zenodo, or
#'"dartmouth" for the (original) Dartmouth URL, or
#'"testdata" for a small sample dataset. Otherwise
#'a full URL of your choice can be specified leading to
#'the StudentLife dataset as a \code{.tar.gz} file.
#'@param location The destination path. If the path does
#'not exist it is created with \code{\link{dir.create}}
#'@param unzip Logical. If \code{TRUE} then the
#'dataset will be unzipped with \code{\link[R.utils]{bunzip2}}.
#'Leave as default unless you plan to do it manually.
#'@param untar Logical. If \code{TRUE} then the
#'dataset will be untarred with \code{\link[utils]{untar}}.
#'Leave as default unless you plan to do it manually.
#'
#'@examples
#'d <- tempdir()
#'download_studentlife(location = d, url = "testdata")
#'
#'\dontrun{
#'## With menu
#'load_SL_tibble(location = d)
#'}
#'
#'## Without menu
#'SL_tables
#'load_SL_tibble(schema = "EMA", table = "PAM", location = d)
#'
#'@export
download_studentlife <- function(
  url = "dartmouth",
  location = ".",
  unzip = TRUE,
  untar = TRUE) {

  zip <- FALSE
  if (tolower(url) == "dartmouth") {

    url <- paste0("https://studentlife.cs.dartmouth.edu",
                  "/dataset/dataset.tar.bz2")

    mes1 <- "Downloading the original StudentLife dataset..."
    f <- "dataset.tar.bz2"

  } else if (tolower(url) == "testdata") {

    url <- paste0("https://raw.githubusercontent.com/",
                  "frycast/studentlife/master/tests/",
                  "testthat/testdata/sample/sample_dataset.tar.bz2")

    mes1 <- "Downloading the small sample dataset..."
    f <- "dataset.tar.bz2"

  } else if (tolower(url) == "rdata") {

    url <- paste0("https://zenodo.org/record/3529253/",
                  "files/dataset_rds.zip?download=1")

    mes1 <- "Downloading the RData studentlife dataset..."
    f <- "dataset_rds.zip"
    untar <- FALSE
    zip <- TRUE

  } else {

    mes1 <- "Downloading from user specified url..."
    f <- "dataset.tar.bz2"

  }

  message(mes1)
  p <- paste0(location, "/", f)
  if (!dir.exists(location)) dir.create(location)
  if (!zip) {utils::download.file(url = url, destfile = p, cacheOK = FALSE)}
  if (zip) {utils::download.file(url = url, destfile = p, method = 'curl')}
  message("Download complete")

  if (zip && unzip) {
    message("Unzipping the dataset...")
    utils::unzip(p, exdir = location)
    message("Unzip complete")
  } else if (unzip) {
    message("Unzipping the dataset...")
    R.utils::bunzip2(p, remove = FALSE, skip = TRUE)
    message("Unzip complete")
  }
  if (untar) {
    f <- "dataset.tar"
    p <- paste0(location, "/", f)
    message("Untarring the dataset...")
    utils::untar(p, exdir = location)
    message("Untar complete")
  }
}


#' load_SL_tibble
#'
#' Import a chosen StudentLife table as
#' a tibble. Leave \code{schema} and \code{table}
#' unspecified to choose interactively via a
#' menu. This function is only intended for use
#' with the studentlife dataset in it's original
#' format, with the original directory structure.
#' See the examples below for the recommended alternative approach
#' to loading tables when the RData format is used.
#'
#' @param schema A character string. The menu 1 choice. Leave
#' blank to choose interactively.
#' @param table A character string. The menu 2 choice. Leave
#' blank to choose interactively.
#' @param location The path to a copy of the StudentLife dataset.
#' @param time_options A character vector specifying which
#' table types (out of "interval", "timestamp", "dateonly" and "dateless")
#' to include in the menu. This allows you to restrict menu options
#' according to the amount of date-time information present in the data.
#' The default includes all data. Note
#' this parameter only has an effect when used with the interactive menu.
#' @param vars Character vector of variable
#' names to import for all students. Leave
#' blank and this will be chosen interactively
#' if necesssary. If \code{vars} contains
#' "timestamp" then effort will be made
#' to convert "timestamp" to appropriate
#' variable name(s) for the target table.
#' @param csv_nrows An integer specifying the number of rows to read
#' per student if the target is a csv. The largest files in StudentLife are csv
#' files, so this allows code testing with less overhead.
#' @param datafolder Specifies the subfolder of \code{location}
#' that contains the relevant data. This should normally
#' be left as the default.
#' @param uid_range An integer vector. The range of uids in
#' the StudentLife study.
#'
#' @return
#' An object of class \code{SL_tibble} is returned. These inherit
#' properties from class \code{\link[tibble]{tibble}} and
#' class \code{\link{data.frame}}.
#' Depending on the date-time information available, the object
#' may also be a \code{timestamp_SL_tibble},
#' \code{interval_SL_tibble} or
#' \code{dateonly_SL_tibble} (which are all
#' subclasses of \code{SL_tibble}).
#'
#'@examples
#'## Example that uses RData format to efficiently
#'## download and load tables, as an alternative
#'## to using this function.
#'\dontrun{
#' d <- tempdir()
#' download_studentlife(location = d, url = "rdata")
#'
#' # Choose the schema and table from the list SL_tables:
#' SL_tables
#'
#' # Example with activity table from sensing schema
#' schema <- "sensing"
#' table <- "activity"
#' act <- readRDS(paste0(d, "/dataset_rds/", schema, "/", table, ".Rds"))
#' act
#'}
#'
#'## Example that uses the studentlife dataset in
#'## its original format.
#'
#'# Use url = "dartmouth" for the full original dataset
#'d <- tempdir()
#'download_studentlife(location = d, url = "testdata")
#'
#'\dontrun{
#'## With menu
#'load_SL_tibble(location = d)
#'}
#'
#'## Without menu
#'SL_tables
#'PAM <- load_SL_tibble(schema = "EMA", table = "PAM", location = d)
#'
#'## Load less data for testing with less overhead
#'act <- load_SL_tibble(schema = "sensing", table = "activity",
#'                      location = d, csv_nrows = 10)
#'
#'\dontrun{
#'## Browse all tables with timestamps (non-interval)
#'load_SL_tibble(location = d, time_options = "timestamp")
#'
#'## Browse all tables with intervals
#'load_SL_tibble(location = d, time_options = "interval")
#'
#'## Browse all dateless tables
#'load_SL_tibble(location = d, time_options = "dateless")
#'}
#' @export
load_SL_tibble <- function(
  schema, table, location = ".",
  time_options = c("interval", "timestamp", "dateonly", "dateless"),
  vars, csv_nrows, datafolder = "dataset",
  uid_range = getOption("SL_uids")) {

  time_options <- tolower(time_options)
  datafolder <- paste0("/", datafolder)

  opt <- c("interval", "timestamp", "dateonly", "dateless")
  options_check(par = time_options, opt = opt)

  if ( !dir.exists(location) )
    stop("the directory specified by location parameter does not exist")

  if ( !dir.exists(paste0(location, datafolder)) )
    stop(paste0("the location does not have a subfolder named ", datafolder))

  if (!missing(vars)) {
    if( !("uid" %in% vars ) ) vars <- c("uid", vars)
  }

  if ( missing(schema) & !missing(table) ) {

    guess_schema <- names(
      unlist(lapply(studentlife::SL_tables, function(x){which(x == table)})))
    if (length(guess_schema) != 1) {
      stop(paste0("Had trouble determining the schema, ",
                  "try specifying it with the schema argument"))
    } else {
      schema <- guess_schema
    }

  }

  if (!missing(schema))
    schema <- pmatch(tolower(schema), tolower(menu_data$menu1_choices))

  if (!missing(table))
    table <- pmatch(tolower(table), tolower(menu_data$menu2_list[[schema]]))

  location <- paste0(location, datafolder)

  path <- get_path(location, schema, table, time_options)

  if ( path %in% menu_data$EMA_json ) {

    tab <- get_EMA_tab(path, location, vars)

  } else if ( path %in% menu_data$long_csv ) {

    tab <- get_long_csv_tab(path, location, vars, csv_nrows)

  } else if ( path %in% menu_data$wide_csv ) {

    tab <- get_wide_csv_tab(path, location, vars, csv_nrows)

  } else if ( path %in% menu_data$txt ) {

    tab <- get_txt_tab(path, location, vars)

  }

  tab$uid <- factor(tab$uid, levels = uid_range)

  tab <- structure(
    tab, schema = attr(path, "schema"),
    table = attr(path, "table"))

  if ( attr(tab, "table") == "PAM" && ("picture_idx" %in% names(tab)) ) {
    tab <- PAM_categorise(tab, pam_name = "picture_idx")
  }

  names(tab) <- clean_strings(names(tab))

  return(tab)
}


############################################################################
############################################################################
# Helper functions ---------------------------------

get_path <- function(location, menu1, menu2, time_options) {


  # Present interactive menu 1
  menu1_restrict <- unlist(
    menu_data$time_opt_list1[time_options], use.names = FALSE)
  menu1_choices <- menu_data$menu1_choices[
    which(menu_data$menu1_choices %in% menu1_restrict)]
  if ( missing(menu1) ) {

    menu1 <- menu1_choices[[utils::menu(
      choices = menu1_choices,
      title = "Choose Menu 1 option:")]]
  } else {

    menu1 <- menu1_choices[[menu1]]
  }

  schema <- menu1

  if (menu1 == "EMA") menu1 <- "EMA/response"

  # Present interactive menu 2
  menu2_choices <- menu_data$menu2_list[[menu1]]
  menu2_restrict <- unlist(
    menu_data$time_opt_list2[time_options], use.names = FALSE)
  menu2_choices <- menu2_choices[
    which(menu2_choices %in% menu2_restrict)]
  if ( missing(menu2) ) {

    menu2 <- utils::menu(
      choices = menu2_choices,
      title = "Choose Menu 2 option:")
  }

  if (is.null(menu2_choices))
    stop("No tables found in specified schema")

  menu2 <- menu2_choices[[menu2]]
  table <- menu2

  result <- paste0(menu1, "/", menu2)
  result <- get_name_from_path(result, split = 'other/')

  if ( result == "dining" ) result <- "dinning"

  result <- structure(result, schema = schema, table = table)

  return(result)
}

get_txt_tab <- function(path, location, vars) {

  `%>%` <- dplyr::`%>%`

  if ( !missing(vars) )
    if ( "timestamp" %in% vars )
      vars[pmatch("timestamp", vars)] <- "date-time"


  pr <- paste0(location, "/", path, "/", "u")
  paths <- c(paste0(pr, "0", seq(0,9), ".txt"),
             paste0(pr, seq(10,59), ".txt"))

  readr::read_csv(paths[2],
                  col_names = c("date-time","location","type"))
  tab <- list()
  missing_tab <- 0
  for (i in 1:60) {
    if(file.exists(paths[i])) {
      this_stud <- suppressMessages(
        readr::read_csv(paths[i], progress = FALSE,
                        col_names = c("date-time","location","type")))
      this_stud$uid <- i - 1
      tab[[length(tab)+1]] <- this_stud
    } else {
      missing_tab <<- missing_tab + 1
    }
  }

  # Bind students
  tab <- tab %>%
    dplyr::bind_rows() %>%
    tibble::as_tibble()

  if ( !missing(vars) ) tab <- dplyr::select(tab, vars)

  class(tab) <- c("SL_tbl", class(tab))

  if ( "date-time" %in% names(tab) ) {
    names(tab)[pmatch("date-time", names(tab))] <- "timestamp"
    tab$timestamp <- as.numeric(
      as.POSIXct(tab$timestamp, origin="1970-01-01",
                 tz = getOption("SL_timezone")))
    class(tab) <- c("timestamp_SL_tbl", class(tab))
  }

  return(tab)
}


get_wide_csv_tab <- function(path, location, vars, csv_nrows) {

  full_path <- paste0(location, "/", path, ".csv")
  name <- get_name_from_path(path)

  args <- list(file = full_path, na.strings = c("NA",""), check.names = FALSE)
  cn <- c("uid", "class1", "class2", "class3", "class4")
  if (name == "class") {args$col.names <- cn; args$header <- FALSE}
  if (name == "deadlines") {args$check.names <- TRUE}
  tab <- do.call(utils::read.csv, args)

  if ( name %in% menu_data$survey ) {
    exc <- which(names(tab) %in% c("uid","type"))
    q_text <- names(tab[,-exc])
    names(tab) <- c(names(tab[,exc]), paste0("Q", 1:length(names(tab[,-exc]))))
    attr(tab, "survey_questions") <- q_text
  }

  tab$uid <- as.integer(substr(tab$uid, 2, 3))
  tab <- tibble::as_tibble(tab)
  if(!missing(vars)) tab <- dplyr::select(tab, vars)


  if ( name %in% menu_data$dateonly ) {

    tab <- tidyr::gather(tab, "date", "deadlines", -c("uid"))
    tab$date <- as.Date(
      as.POSIXct(substr(tab$date,2,11), format = "%Y.%m.%d",
                 tz = getOption("SL_timezone")),
      tz = getOption("SL_timezone"))

    class(tab) <- c("SL_tbl", class(tab))

    class(tab) <- c("dateonly_SL_tbl", class(tab))

  } else {

    class(tab) <- c("SL_tbl", class(tab))

    class(tab) <- c("dateless_SL_tbl", class(tab))

  }

  return(tab)
}



get_long_csv_tab <- function(path, location, vars, csv_nrows) {

  `%>%` <- dplyr::`%>%`

  name <- get_name_from_path(path)
  if( name == "app_usage" ) name <- "running_app"
  if( name == "bluetooth" ) name <- "bt"
  paths <- generate_paths(location, path, name)

  if( !missing(vars) )
    if( "timestamp" %in% vars ) {
      if( name %in% menu_data$interval ) {
        if ( name == "conversation" ) {
          vars[pmatch("timestamp", vars)] <- "start_timestamp"
          vars <- c(vars, "end_timestamp")
        } else {
          vars[pmatch("timestamp", vars)] <- "start"
          vars <- c(vars, "end")
        }
      } else if ( name %in% c("bt","gps","wifi","wifi_location") ) {
        vars[pmatch("timestamp", vars)] <- "time"
      }
    }

  args <- list()
  if ( !missing(csv_nrows) ) args$nrows <- csv_nrows

  tab <- list()
  missing_tab <- 0
  if ( name == "wifi_location" || name == "gps" ) {
    args2 <- c(args, list(skip = 1, header = FALSE,
      stringsAsFactors = FALSE))
    for (i in 1:60) {
      if(file.exists(paths[i])) {
        args2$file <- paths[i]
        col_names <- as.character(
          utils::read.csv(file = paths[i], nrows = 1,
                          stringsAsFactors = FALSE,
                          header = FALSE))
        args2$col.names <- c(col_names, "to_drop")
        this_stud <- suppressMessages(
          do.call(utils::read.csv, args2))
        this_stud$to_drop <- NULL
        this_stud$uid <- i - 1
        tab[[length(tab)+1]] <- this_stud
      } else {
        missing_tab <<- missing_tab + 1
      }
    }
  } else {
    if ( missing(csv_nrows) ) csv_nrows <- Inf
    for (i in 1:60) {
      if(file.exists(paths[i])) {
        this_stud <- suppressMessages(
          readr::read_csv(
            file = paths[i], progress = FALSE, n_max = csv_nrows))
        this_stud$uid <- i - 1
        tab[[length(tab)+1]] <- this_stud
      } else {
        missing_tab <<- missing_tab + 1
      }
    }
  }

  if ( path == "sms" && missing(vars) ) {
    tab <- lapply(tab, function(x){
      x <- dplyr::select(
        as.data.frame(x), "id", "device", "timestamp", "uid")
    })
  }

  # Bind students
  tab <- tab %>%
    dplyr::bind_rows() %>%
    tibble::as_tibble()

  if ( !missing(vars) ) tab <- dplyr::select(tab, vars)

  if( name %in% menu_data$interval ) {
    if ( !(name == "conversation") ) {
      if ( "start" %in% names(tab) )
        names(tab)[pmatch("start", names(tab))] <- "start_timestamp"
      if ( "end" %in% names(tab) )
        names(tab)[pmatch("end", names(tab))] <- "end_timestamp"
    }
  } else if ( name %in% c("bt","gps","wifi","wifi_location") ) {
    if ( "time" %in% names(tab) )
      names(tab)[pmatch("time", names(tab))] <- "timestamp"
  }

  class(tab) <- c("SL_tbl", class(tab))

  if ("timestamp" %in% names(tab))
    class(tab) <- c("timestamp_SL_tbl", class(tab))

  if ("start_timestamp" %in% names(tab) && "end_timestamp" %in% names(tab))
    class(tab) <- c("interval_SL_tbl", class(tab))

  return(tab)
}



get_EMA_tab <- function(path, location, vars) {

  if (!missing(vars) ) {
    vars[pmatch("timestamp", vars)] <- "resp_time"
  }

  tab <- EMA_to_list(location, path)

  if ( missing(vars) ) {
    # Create a graphical menu to choose vars

    vars_list <- attributes(tab)$vars_present

    vars_opt <- unlist(lapply(vars_list, function(x) {
      vec <- unlist(x)
      vec[pmatch("resp_time", vec)] <- "timestamp"
      sort(paste0(vec, collapse = ", "))
    }))

    vars_opt <- vars_opt[order(nchar(vars_opt), decreasing = TRUE)]

    if ( length(vars_opt) > 1 ) {

      t <- paste0("Choose variables. ",
                  "Only students who share all chosen variables ",
                  "will be loaded. Choosing more variables usually ",
                  "implies more students will be discarded.")

      choice <- utils::menu(choices = vars_opt,
                     title = t,
                     graphics = FALSE)
      vars <- vars_list[[choice]]
    } else {

      vars <- vars_list[[1]]
    }
  }

  tab <- EMA_list_to_tibble(tab, vars)

  vars[pmatch("resp_time", vars)] <- "timestamp"
  for (v in vars) {
    if (all(strings_are_numeric(tab[[v]])))
      tab[[v]] <- as.numeric(tab[[v]])
  }

  ds <- attributes(tab)$dropped_students
  ds <- paste0(ds, collapse = ", ")

  if (ds > 0) {
    message(paste0("The students dropped ",
                   " with the choice of vars were numbers ", ds, "."))
  }

  class(tab) <- c("SL_tbl", class(tab))

  if ("timestamp" %in% names(tab)) {
    class(tab) <- c("EMA_SL_tbl", "timestamp_SL_tbl", class(tab))
  }

  return(tab)
}

EMA_to_list <- function(location, path) {

  `%>%` <- dplyr::`%>%`

  name <- get_name_from_path(path)
  if (name == "QR_Code") name <- "QR"
  paths <- generate_paths(location, path, name, ext = ".json")

  tab <- list()
  missing_tab <- 0
  for (i in 1:60) {
    if( file.exists(paths[i])
        && readLines(paths[i], 1, warn = FALSE) != "[]") {
      this_stud <- jsonlite::fromJSON(paths[i])
      this_stud$uid <- i - 1
      tab[[length(tab)+1]] <- this_stud
    } else {
      missing_tab <<- missing_tab + 1
    }
  }

  vars_present <- unique(lapply(tab, function(x){sort(names(x))} ))

  if ( length(vars_present) == 0 ) {
    stop(paste0("There was an error finding data. ",
                "Perhaps Check the location to ensure ",
                "it points to the top level of the StudentLife ",
                "dataset directory"))
  }

  for (i in 1:length(vars_present)) {
    if ( is.null(vars_present[[i]]) ) {
      vars_present[[i]] <- NULL; break
    }
  }

  ## Get EMA definition information
  if (name == "PAM") {

    EMA_questions <-
      paste0("Refer to: Pollak, J. P., Adams, P., & Gay, G.",
             " (2011, May). PAM: a photographic affect meter",
             " for frequent, in situ measurement of affect.",
             " In Proceedings of the SIGCHI conference on Human",
             " factors in computing systems (pp. 725-734). ACM.")

  } else if (name == "QR") {

    name <- "QR_Code"
    EMA_questions <- paste0(
                     "Classroom seating positions. See the layout at ",
                     "https://studentlife.cs.dartmouth.edu/dataset.html")

  } else {
    EMA_definition <- jsonlite::fromJSON(
      paste0(location,"/EMA/EMA_definition.json"), flatten = TRUE)
    EMA_names <- gsub("\\?", "_", EMA_definition$name)
    EMA_questions <- EMA_definition[
      pmatch(name, EMA_names),2][[1]]
    EMA_questions <- tibble::as_tibble(EMA_questions)
    EMA_questions <- EMA_questions[
      -pmatch("location", EMA_questions$question_id),]
  }

  tab <- structure(
    tab,
    vars_present = vars_present,
    EMA_name = name,
    EMA_questions = EMA_questions)

  return(tab)
}

EMA_list_to_tibble <- function(tab, vars = "resp_time") {

  tab_list <- tab

  # Drop lists not sharing variable names specified by parameter 'vars'
  null_ind <- c()
  for (i in 1:length(tab)) {
    if ( !all(vars %in% names(tab[[i]]) )) {
      null_ind <- c(null_ind, i)
    }
  }
  tab[null_ind] <- NULL

  # Drop all columns other than those specified by parameter 'vars'
  tab <- lapply(tab, function(x){
    dplyr::select(as.data.frame(x), vars)
  })

  `%>%` <- dplyr::`%>%`

  # Bind and make tibble
  tab <- tab %>%
    dplyr::bind_rows() %>%
    tibble::as_tibble()

  if ( "resp_time" %in% names(tab) )
    names(tab)[pmatch("resp_time", names(tab))] <- "timestamp"

  attr(tab_list, "dropped_students") <- null_ind - 1
  transfer_EMA_attrs(tab) <- tab_list

  return(tab)
}
