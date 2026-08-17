module Admin
  class PostsController < BaseController
    before_action :set_post, only: [:edit, :update, :destroy]

    def index
      @posts = Post.recent
    end

    def new
      @post = Post.new(published: false, author: "The Schools of India")
    end

    def create
      @post = Post.new(post_params)
      @post.published_at ||= Time.current if @post.published?
      if @post.save
        redirect_to admin_posts_path, notice: "Post created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      attrs = post_params
      # Stamp the publish date the first time a post goes live.
      if attrs[:published] == "1" && @post.published_at.blank?
        attrs = attrs.merge(published_at: Time.current)
      end

      if @post.update(attrs)
        redirect_to admin_posts_path, notice: "Post updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy
      redirect_to admin_posts_path, notice: "Post deleted."
    end

    private

    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(
        :title, :slug, :author, :category, :cover_image,
        :excerpt, :body, :published, :published_at
      )
    end
  end
end
