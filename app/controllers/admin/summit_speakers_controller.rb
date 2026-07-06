module Admin
  class SummitSpeakersController < BaseController
    before_action :set_speaker, only: [:edit, :update, :destroy]

    def index
      @speakers = SummitSpeaker.all
    end

    def new
      @speaker = SummitSpeaker.new(accent_color: "#ff2a7f", position: (SummitSpeaker.maximum(:position) || 0) + 1)
    end

    def create
      @speaker = SummitSpeaker.new(speaker_params)
      if @speaker.save
        redirect_to admin_summit_speakers_path, notice: "Speaker added."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @speaker.update(speaker_params)
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

    def set_speaker
      @speaker = SummitSpeaker.find(params[:id])
    end

    def speaker_params
      params.require(:summit_speaker).permit(:name, :title, :organisation, :photo, :accent_color, :position)
    end
  end
end
