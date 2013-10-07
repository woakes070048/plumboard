require 'will_paginate/array' 
class PostsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_data, only: [:index, :unread, :sent, :reply, :show]
  before_filter :mark_post, only: [:reply]
  respond_to :html, :js, :json, :mobile
  layout :page_layout

  def index
    @posts = @user.incoming_posts.paginate(page: @page, per_page: @per_page)
  end

  def reply
    @post = Post.new params[:post]
    if @post.save
      flash.now[:notice] = "Successfully sent post."
      @posts = @user.reload.incoming_posts.paginate(page: @page, per_page: @per_page)
    end
  end

  def show
    @posts = @user.incoming_posts.paginate(page: @page, per_page: @per_page)
  end

  def mark
    Post.mark_as_read! :all, :for => @user
    render :nothing => true
  end

  def sent
    @posts = @user.posts.paginate(page: @page, per_page: @per_page)
  end

  def create
    @listing = Listing.find_by_pixi_id params[:post][:pixi_id]
    @post = Post.new params[:post]
    if @post.save
      @post = Post.load_new @listing
    end
  end

  def destroy
    @post = Post.find params[:id]
  end
   
  private

  def page_layout
    mobile_device? && %w(index sent).detect{|x| action_name == x} ? 'form' : 'application'
    # mobile_device? && action_name == 'index' ? 'form' : 'application'
  end

  def mark_post
    @old_post = Post.find params[:id]
    @old_post.mark_as_read! for: @user if @old_post
  end

  def load_data
    @page = params[:page] || 1
    @per_page = params[:per_page] || 5
  end
end
