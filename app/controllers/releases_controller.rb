class ReleasesController < ApplicationController
  before_action :validate_current_user
  before_action :find_release, only: [:show, :edit, :update, :destroy]

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
    commit = current_user.repo.lookup( @release.commit_sha )
    @diff = commit.parents.first.diff(commit).patch
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
    {message: params[:message], files: @current_user.changed_locked_files, user: @current_user}
  end

  def find_release
    @release = Release.find( params[:id] )
  end
end
