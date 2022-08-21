bow <- function(url,
                user_agent = "polite R package",
                delay = 5,
                force = FALSE, verbose=FALSE,
                ...){
  
  stopifnot(is.character(user_agent), length(user_agent) == 1) # write meaningful error ref Lionel talk
  stopifnot(is.character(url), length(url) == 1) # write meaningful error ref Lionel talk
  
  #if(force) memoise::forget(scrape)
  
  url_parsed <- httr::parse_url(url)
  url_subdomain <- paste0(url_parsed$scheme, "://", url_parsed$hostname)
  rt <- robotstxt::robotstxt(domain = paste0(url_subdomain, '/'),
                             user_agent = user_agent,
                             warn = verbose, force = force)
  
  delay_df <- rt$crawl_delay
  delay_rt <- as.numeric(delay_df[with(delay_df, useragent==user_agent), "value"]) %otherwise%
    as.numeric(delay_df[with(delay_df, useragent=="*"), "value"]) %otherwise% 0
  
  # define object
  self <- structure(
    list(
      handle   = httr::handle(url),
      config   = c(httr::config(autoreferer = 1L),
                   httr::add_headers("user-agent"=user_agent),...),
      url      = url,
      back     = character(),
      forward  = character(),
      response = NULL,
      html     = new.env(parent = emptyenv(), hash = FALSE),
      user_agent = user_agent,
      domain   =  url_subdomain,
      robotstxt= rt,
      delay  = max(delay_rt, delay)
    ),
    class = c("polite", "session")
  )
  
  if(verbose && !is_scrapable(self))
    warning("Psst!...It's not a good idea to scrape here!", call. = FALSE)
  
  if(self$delay<5)
    if(grepl("polite|dmi3kno", self$user_agent)){
      stop("You cannot scrape this fast. Please reconsider delay period.", call. = FALSE)
      warning("This is a little too fast. Are you sure you want to risk being banned?", call. = FALSE)
    }
  
  # set new rate limits
  if(self$delay != ratelimitr::get_rates(httr_get_ltd)[[1]]["period"]){
    set_scrape_delay(self$delay)
  }
  
  if(self$delay != ratelimitr::get_rates(download_file_ltd)[[1]]["period"]){
    set_rip_delay(self$delay)
  }
  
  self
}




usethis::use_git_config(user.name = "Johan-rosa", user.email = "johan.rosaperez@gmail.com")

## create a personal access token for authentication:
usethis::create_github_token() 
## in case usethis version < 2.0.0: usethis::browse_github_token() (or even better: update usethis!)

## set personal access token:
credentials::set_github_pat("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")
