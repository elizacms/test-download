class ReleasesController < ApplicationController
  before_action :validate_current_user
  before_action :find_release, only: [:review, :accept_or_reject]

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
    release = Release.find(params[:release_id])
    release.update(state: 'in_training')

    auth = {username: ENV['JENKINS_USERNAME'], password: ENV['JENKINS_PASSWORD']}
    HTTParty.post( "#{ENV['NLU_TRAINER_URL']}/build", body: {}, basic_auth: auth )

    build_number = HTTParty.get("#{ENV['NLU_TRAINER_URL']}/lastBuild/buildNumber")
    release.update(build_number: build_number)

    redirect_to releases_path, notice: 'Training job started for release.'
  end

  def accept_or_reject
    last_build_no = HTTParty.get("#{ENV['NLU_TRAINER_URL']}/lastBuild/buildNumber")
    @last_build = HTTParty.get("#{ENV['NLU_TRAINER_URL']}/#{last_build_no}/api/json")

    commit = current_user.repo.lookup( @release.commit_sha )
    @diff = current_user.pretty_diff( commit.parents.first.diff(commit) )
    @release_id = params[:id]
  end

  def approval_or_rejection
    release = Release.find(params[:release_id])
    release.intents.each { |intent| intent.unlock }

    if params[:commit] == 'Accept'
      release.update(state: 'approved')
      current_user.git_rebase(release.branch_name)

      redirect_to releases_path, notice: 'Release has been accepted and merged.'
    else
      release.update(state: 'rejected')

      redirect_to releases_path, alert: 'Release has been rejected.'
    end
  end


  private

  def release_params
    {message: params[:message], files: @current_user.changed_locked_files, user: @current_user}
  end

  def find_release
    @release = Release.find( params[:id] )
  end
end
