class CommentController < ApplicationController
  
  def new
    @comment = Comment.fromParams(params["path"], session[:user_id] ? session[:user_id].to_author_hash : {} )
    @captcha = session[:captcha] = Captcha.new
    render :layout => false
  end
  
  def save
    @comment = Comment.fromParams(params["path"], params["comment"])
  
    if check_captcha & @comment.validate
      @comment.store
      @numcomments = Comment.allFromPath(params["path"], false).size
      render :layout => false
    else
      render(:layout => false , :action => 'new')
    end
  end
  
  def check_captcha
    valid_captcha = false
    if session[:captcha]
      (@captcha = session[:captcha]).actualValue = params["captcha"]["actualValue"]
      valid_captcha = @captcha.validate
    end
    return valid_captcha    
  end
  private :check_captcha
  
end
