module Admin
  class SummitSpeakersController < BaseController
    before_action :set_speaker, only: [ :edit, :update, :destroy ]

    def index
      @speakers = SummitSpeaker.all
    end

    def new
      @speaker = SummitSpeaker.new(accent_color: "#ff2a7f", position: (SummitSpeaker.maximum(:position) || 0) + 1)
    end

    def create
      @speaker = SummitSpeaker.new(speaker_params)
      attach_photo_upload!(@speaker)
      if @speaker.save
        redirect_to admin_summit_speakers_path, notice: "Speaker added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      @speaker.assign_attributes(speaker_params)
      attach_photo_upload!(@speaker)
      if @speaker.save
        redirect_to admin_summit_speakers_path, notice: "Speaker updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @speaker.destroy
      redirect_to admin_summit_speakers_path, notice: "Speaker removed."
    end

    private

    ALLOWED_PHOTO_EXTENSIONS = %w[.jpg .jpeg .png .webp .gif].freeze

    def set_speaker
      @speaker = SummitSpeaker.find(params[:id])
    end

    def speaker_params
      params.require(:summit_speaker).permit(:name, :title, :organisation, :photo, :accent_color, :position)
    end

    def attach_photo_upload!(speaker)
      upload = params.dig(:summit_speaker, :photo_upload)
      return unless upload.respond_to?(:original_filename)

      ext = File.extname(upload.original_filename).downcase
      ext = ".jpg" unless ALLOWED_PHOTO_EXTENSIONS.include?(ext)
      slug = speaker.name.to_s.parameterize.presence || "speaker"

      dest_dir = Rails.root.join("public", "summit", "assets")
      FileUtils.mkdir_p(dest_dir)
      filename = "advisor_#{slug}_#{Time.now.to_i}#{ext}"
      File.binwrite(dest_dir.join(filename), upload.read)

      speaker.photo = "/summit/assets/#{filename}"
    end
  end
end
