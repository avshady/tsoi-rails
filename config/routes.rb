Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # Static pages
  get "/parents",     to: "pages#parents"
  get "/about",       to: "pages#about"
  get "/services",        to: "pages#services"
  get "/services/:slug",  to: "pages#service_detail", as: :service_detail
  get "/partner",     to: "pages#partner"
  get "/contact",     to: "pages#contact"
  get "/terms",       to: "pages#terms"
  get "/privacy",     to: "pages#privacy"
  get "/recognition", to: "pages#recognition"
  get "/summit",      to: "pages#summit"

  post "/summit/notify",           to: "pages#summit_notify"
  post "/contact/send",            to: "pages#contact_send"
  post "/services/:slug/inquiry",  to: "pages#service_inquiry", as: :service_inquiry

  # Schools
  resources :schools, only: [:index, :show] do
    member { post :claim }
  end

  # School Portal
  get  "/portal",           to: "portal#login",        as: :portal_login
  post "/portal/auth",      to: "portal#authenticate",  as: :portal_auth
  get  "/portal/dashboard", to: "portal#dashboard",     as: :portal_dashboard
  patch "/portal/update",   to: "portal#update",        as: :portal_update
  delete "/portal/logout",  to: "portal#logout",        as: :portal_logout

  # JSON API
  namespace :api do
    get  "schools",          to: "schools#index"
    get  "schools/filters",  to: "schools#filters"   # must be before schools/:id
    get  "schools/:id",      to: "schools#show", as: :school
    get  "schools/cities",   to: "schools#cities"
    # legacy paths
    get  "cities",           to: "schools#cities"
    get  "filters",          to: "schools#filters"
  end

  # Admin (simple, no auth for local dev)
  namespace :admin do
    root "dashboard#index"
    resources :schools, only: [:index, :show, :edit, :update] do
      member { post :generate_token }
    end

    # CMS
    get  "content",                     to: "content#index",                as: :content
    post "content/service/:slug/image", to: "content#update_service_image", as: :content_service_image
    post "content/service/:slug/text",  to: "content#update_service_text",  as: :content_service_text

    # Inquiries
    resources :inquiries, only: [:index, :destroy]
  end
end
