class ReleasesController < ApplicationController
  before_action :validate_current_user
  before_action :find_release, only: [:review, :accept_or_reject]
  before_action :find_release_by_release_id, only: [:submit_to_training, :approval_or_rejection]

  def index
    @repo = Rugged::Repository.new(ENV['NLU_CMS_PERSISTENCE_PATH'])
    @releases = Release.all.order('created_at DESC')
  end

  def new
    @release = Release.new
    @diff = current_user.git_diff_workdir

    if @diff.empty?
      redirect_to releases_path, notice: "You haven't made any changes."
    end
  end

  def create
    if release_params[:message].blank?
      redirect_to new_release_path, alert: "Message can't be blank"
      return
    end

    if Release.create(release_params)
      redirect_to releases_path, notice: 'Release created.'
    else
      render :new
    end
  end

  def review
    commit = current_user.repo.lookup( @release.commit_sha )
    @diff = current_user.pretty_diff( commit.parents.first.diff(commit) )
    @release_id = params[:id]
  end

  def submit_to_training
    build_number = TrainingAPI.new.build( @release )
    @release.update( state:'in_training', build_number:build_number )

    redirect_to releases_path, notice: 'Training job started for release.'
  end

  def accept_or_reject
    @build_output = TrainingAPI.new.output_for( @release.build_number )

    commit = current_user.repo.lookup( @release.commit_sha )
    @diff = current_user.pretty_diff( commit.parents.first.diff( commit ))
    @release_id = params[ :id ]
  end

  def approval_or_rejection
    @release.intents.each { |intent| intent.unlock }

    if params[:commit] == 'Accept'
      @release.update(state: 'approved')
      current_user.git_rebase(@release.branch_name)

      redirect_to releases_path, notice: 'Release has been accepted and merged.'
    else
      @release.update(state: 'rejected')

      redirect_to releases_path, alert: 'Release has been rejected.'
    end
  end


  private

  def release_params
    {message: params[:message], files: @current_user.changed_files, user: @current_user}
  end

  def find_release
    @release = Release.find( params[:id] )
  end

  def find_release_by_release_id
    @release = Release.find( params[:release_id] )
  end
end
