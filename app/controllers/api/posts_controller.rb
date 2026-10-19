module Api
  # JSON API for the blog, meant for automated publishing pipelines.
  #
  # Every request must send the secret from ENV["BLOG_API_TOKEN"] as
  #   Authorization: Bearer <token>
  # If the variable isn't set, the API is disabled and answers 503.
  class PostsController < ActionController::API
    PERMITTED = %i[title slug author category cover_image excerpt body published published_at].freeze
    MAX_PER_PAGE = 100

    before_action :authenticate
    before_action :set_post, only: [ :show, :update, :destroy ]

    rescue_from ActiveRecord::RecordNotFound do
      render json: { error: "Post not found" }, status: :not_found
    end

    rescue_from ActionController::ParameterMissing do |e|
      render json: { error: e.message }, status: :bad_request
    end

    # GET /api/posts?published=true|false&page=1&per_page=20
    def index
      scope = Post.recent
      scope = scope.where(published: ActiveModel::Type::Boolean.new.cast(params[:published])) if params[:published].present?

      page     = [ params[:page].to_i, 1 ].max
      per_page = params[:per_page].to_i
      per_page = 20 if per_page <= 0
      per_page = [ per_page, MAX_PER_PAGE ].min

      total = scope.count
      posts = scope.limit(per_page).offset((page - 1) * per_page)

      render json: {
        posts: posts.map { |p| post_json(p, include_body: false) },
        page: page,
        per_page: per_page,
        total: total
      }
    end

    # GET /api/posts/:slug
    def show
      render json: { post: post_json(@post) }
    end

    # POST /api/posts
    def create
      @post = Post.new(author: "The Schools of India", published: false)
      save_post(:created)
    end

    # PATCH/PUT /api/posts/:slug
    def update
      save_post(:ok)
    end

    # DELETE /api/posts/:slug
    def destroy
      @post.destroy
      render json: { ok: true, slug: @post.slug }
    end

    private

    def authenticate
      expected = ENV["BLOG_API_TOKEN"].to_s
      if expected.blank?
        render json: { error: "Blog API is disabled (BLOG_API_TOKEN is not set)" }, status: :service_unavailable
        return
      end

      provided = request.authorization.to_s[/\ABearer\s+(.+)\z/i, 1].to_s.strip

      # Constant-time compare over fixed-length digests to avoid timing/length leaks.
      unless ActiveSupport::SecurityUtils.secure_compare(
        Digest::SHA256.hexdigest(provided),
        Digest::SHA256.hexdigest(expected)
      )
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def set_post
      @post = Post.find_by(slug: params[:slug]) || Post.find(params[:slug])
    end

    def save_post(success_status)
      attrs = post_params

      if attrs.key?(:category) && attrs[:category].present?
        category = Post::CATEGORIES.find { |c| c.casecmp?(attrs[:category].to_s.strip) }
        unless category
          return render json: { errors: [ "Category must be one of: #{Post::CATEGORIES.join(', ')}" ] },
                        status: :unprocessable_entity
        end
        attrs[:category] = category
      end

      @post.assign_attributes(attrs)
      # Stamp the publish date the first time a post goes live.
      @post.published_at = Time.current if @post.published? && @post.published_at.blank?

      if @post.save
        render json: { post: post_json(@post) }, status: success_status
      else
        render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # Accepts the fields either wrapped ({ "post": { ... } }) or at the top level.
    def post_params
      source = params[:post].is_a?(ActionController::Parameters) ? params[:post] : params
      attrs = source.permit(*PERMITTED)
      raise ActionController::ParameterMissing, :post if attrs.empty? && action_name == "create"
      attrs
    end

    def post_json(post, include_body: true)
      json = {
        id: post.id,
        slug: post.slug,
        title: post.title,
        author: post.author,
        category: post.category,
        cover_image: post.cover_image,
        excerpt: post.excerpt,
        published: post.published,
        published_at: post.published_at,
        created_at: post.created_at,
        updated_at: post.updated_at,
        url: "#{request.base_url}/blog/#{post.slug}"
      }
      json[:body] = post.body if include_body
      json
    end
  end
end
