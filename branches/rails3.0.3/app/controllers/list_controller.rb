class ListController < ApplicationController
  
  def list
    # non-recursive listing
    @pages = Page.allFromPath(path_from_params, false).each { |page| page.summarize }
  end
    
  def blog
    path = [] << params["year"] << params["month"] << params["day"]
    params[:path] = path.compact
    
    # recursive listing
    @pages = get_blog_pages
    
    render :action => "list"
  end
    
  def welcome
    @welcome = Page.fromPath(["index.html"])
    params[:path] =  [ Time.now.year.to_s ]
    
    @pages = get_blog_pages[0..9] # only 10 items in the homepage
    render :action => "list"
  end
  
  def comment
    # recursive listing of comments ( but show only the last 20 )
    @comments = Comment.allFromPath(path_from_params)[0..19]
  end
  
  def get_blog_pages
    pages = Page.allFromPath(path_from_params).each { |page| page.summarize }
    
    if yearly_path? && path_from_params[0].to_i < Time.now.year
      return pages
    end
    
    # If a year-like path has been requested (like /2009 ) and not enough
    # pages where returned, fall back to the previous year.
    #
    # This is a dirty trick to avoid having the homepage and blog sections
    # empty at the beginning of every new year.
    year = (yearly_path? ? path_from_params[0].to_i : Time.now.year) - 1
    while pages.size < 10 && yearly_path? do
      pages << Page.allFromPath([ year.to_s ]).each { |page| page.summarize }
      pages.flatten!
      year -= 1
    end
    apply_blog_time_ordering(pages)
    return pages
  end
  private :get_blog_pages
  
  # For blog entries, order items by blog folder (aka, blog entry time)
  # rather than modification date  
  def apply_blog_time_ordering(pages)
    pages.sort_by { |page| page.path.join('/') }.reverse
  end
  private :apply_blog_time_ordering
  
  def yearly_path?
    path_from_params.size == 1 && path_from_params[0] =~ /(19|20)\d\d/
  end
  private :yearly_path?
  
end