class ReleasesController < ApplicationController
  def index
    @releases = Release.all
  end

  def new
    @release = Release.new
  end

  def create
    if Release.create(release_params)
      redirect_to releases_path, notice: 'Release created.'
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if Release.update(release_params)
      redirect_to releases_path, notice: 'Release updated.'
    else
      render :edit
    end
  end

  def destroy
    sha = @release.commit_sha
    @release.destroy

    redirect_to releases_path, notice: "Release: #{sha} has been destroyed."
  end

  private

  def find_release
    @release = Release.find( params[:id] )
  end

  def release_params
     params.permit(:commit_sha)
  end
end
