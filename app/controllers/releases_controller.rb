class ReleasesController < ApplicationController
  before_action :validate_current_user
  before_action :find_release, only: [:show_release, :show_status]

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

  def show_release
    commit = current_user.repo.lookup( @release.commit_sha )
    @diff = current_user.pretty_diff( commit.parents.first.diff(commit) )
    @release_id = params[:id]
  end

  def show_status
    commit = current_user.repo.lookup( @release.commit_sha )
    @diff = current_user.pretty_diff( commit.parents.first.diff(commit) )
    @release_id = params[:id]
  end


  private

  def release_params
    {message: params[:message], files: @current_user.changed_locked_files, user: @current_user}
  end

  def find_release
    @release = Release.find( params[:id] )
  end
end
