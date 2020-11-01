# studentlife 1.1.0
Bug fixes and updates:
  
  * fixes timezone bug so that dates and times are correct
  * introduces PAM_quadrant function
  * load_SL_tibble will automatically call PAM_quadrant on PAM picture_idx
  * block name "hour" changes to "hour-in-day" to avoid conflict
  * vis_response_counts returns named counts vector
  * vis_response_counts plots in decreasing order
  * Adds RData format download link to download_studentlife
  * Updates documentation to explain RData download and usage from Zenodo
  * Updates dependency to skimr >= 1.0.7
  * Corrects regularise_time output for "day" and "hour"
  * Makes sure reg_SL_tbl class is returned by regularise_time
  * Add blocks to default title of vis_NAs plot
  * SL_tbl_load now guesses schema from table
  * removes pesky class-dropping tamper generics
  * provide option to remove safety checks in tibble transforms
  
# studentlife 1.0.3
This release only updates the authorship to give
correct authorship information.

  * Updated authorship information in DESCRIPTION

# studentlife 1.0.1
This release includes changes recommended by 
reviewers at the Journal of Open Source Software.

  * Fixed typos in documentation.
  * Include community guidelines in the README.md

# studentlife 1.0.0 (current version on CRAN)
This is the first release.
