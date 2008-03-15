class TagsController < ApplicationController
  before_filter :load_tags, :load_search
  
  def index
  end
  
  def show
    @tag = Tag.find_by_name(params[:id])
    @actions = Action.paginate(:all, :page => params[:page], :include => 'taggings', :conditions => ['taggings.tag_id = ?', @tag.id], :order => 'actions.created_at DESC')
  end

private
  def load_tags
    @tags = Action.tag_counts
  end
  
  def load_search
    @search = Search.new(params[:search])
  end
end