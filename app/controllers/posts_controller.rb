class PostsController < ApplicationController
  def index
    @posts = Post.published
    @categories = @posts.map(&:category).compact_blank.uniq

    if params[:category].present?
      @active_category = params[:category]
      @posts = @posts.select { |p| p.category == @active_category }
    end

    @featured = @posts.first
    @rest     = @posts.drop(1)
  end

  def show
    @post = Post.published.find_by(slug: params[:slug])
    return redirect_to blog_path, alert: "That article isn't available." if @post.nil?

    @related = Post.published
                   .reject { |p| p.id == @post.id }
                   .select { |p| @post.category.present? && p.category == @post.category }
                   .first(3)
    @related = Post.published.reject { |p| p.id == @post.id }.first(3) if @related.empty?
  end
end
