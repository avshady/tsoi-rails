module Admin
  class PostsController < BaseController
    before_action :set_post, only: [ :edit, :update, :destroy ]

    def index
      @posts = Post.recent
    end

    def new
      @post = Post.new(published: false, author: "The Schools of India")
    end

    def create
      @post = Post.new(post_params)
      # Publish timestamps are set by Post#apply_publish_schedule on save.
      if @post.save
        redirect_to admin_posts_path, notice: create_notice(@post)
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @post.update(post_params)
        redirect_to admin_posts_path, notice: "Post updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # POST /admin/posts/preview — renders Body markdown through the same
    # pipeline as the public page, without saving. Used by the form's Preview
    # button. Returns JSON so the form can inject the HTML inline.
    def preview
      post = Post.new(preview_params)
      render json: {
        html: view_context.post_body_html(post),
        title: post.seo_title,
        description: post.seo_description
      }
    end

    def destroy
      @post.destroy
      redirect_to admin_posts_path, notice: "Post deleted."
    end

    private

    # Post#to_param is the slug, so admin URLs carry the slug, not the id.
    def set_post
      @post = Post.find_by(slug: params[:id]) || Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(
        :title, :slug, :author, :category, :cover_image, :cover_image_alt,
        :excerpt, :body, :published, :published_at, :publish_at,
        :meta_title, :meta_description, :json_ld
      )
    end

    def preview_params
      params.permit(:body, :title, :excerpt, :meta_title, :meta_description)
    end

    def create_notice(post)
      if post.scheduled?
        "Post scheduled for #{post.publish_at.strftime('%-d %b %Y, %-l:%M %p')}."
      else
        "Post created."
      end
    end
  end
end
