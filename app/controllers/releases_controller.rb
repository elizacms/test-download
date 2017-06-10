class ReleasesController < ApplicationController
  before_action :validate_current_user

  def index
    @repo = Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])
    @releases = Release.all
  end

  def new
    @release = Release.new
    @diff = current_user.git_diff_workdir

    if @diff.empty?
      redirect_to releases_path, notice: "You haven't made any changes."
    end
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

  def release_params
    {message: params[:message], files: @current_user.list_locked_files, user: @current_user}
  end

  def find_release
    @release = Release.find( params[:id] )
  end
end
