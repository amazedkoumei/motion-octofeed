# -*- coding: utf-8 -*-
class Github

  attr_reader :url, :host, :path, :userName, :repositoryName
  
  def initialize(url)

    # split url
    @url = url.absoluteString
    @host = url.host
    @path = url.path

    blank, @userName, @repositoryName = @path.componentsSeparatedByString("/")

    @userName = "" if @userName.nil?
    @repositoryName = "" if @repositoryName.nil?

    # init status hash
    @statusHash = {
      :isStarredRepository => {:apiURL => "https://api.github.com/user/starred/#{userName}/#{repositoryName}", :ret => false, :fetched => false},
      :isWatchingRepository => {:apiURL => "https://api.github.com/user/subscriptions/#{userName}/#{repositoryName}", :ret => false, :fetched => false},
      :isFollowingUser => {:apiURL => "https://api.github.com/user/following/#{userName}", :ret => false, :fetched => false}
    }
  end

  def fetchGithubStatus(&block)
    token = App::Persistence[AMP::GithubAPI::USER_DEFAULT_AUTHTOKEN]
    if(!token.nil?)
      # init @statusHash:fetched
      @statusHash.each_value {|val| val[:fetched] = false}
      
      for key, val in @statusHash
        url = val[:apiURL]
        authHeader = "token " + token
        BW::HTTP.get(url, {headers: {Authorization: authHeader}}) do |response, query|
          @statusHash.each_value {|val|
            if val[:apiURL] == query.request.URL.absoluteString
              val[:ret] = (response.status_code == 204) 
              val[:fetched] = true
            end
          }
          if isFetchFinished?
            block.call()
          end
        end
      end
    end
  end

  def isFetchFinished?
    @statusHash.values.all?{|v| v[:fetched]}
  end

  def isGithubRepository?
    (@host == "github.com" && !@userName.empty? && !@repositoryName.empty?)
  end

  def isGithubUser?
    (@host == "github.com" && !@userName.empty? && @repositoryName.empty?)
  end

  def isGithubRepositoryOrUser?
    (@host == "github.com" && !@userName.empty?)
  end

  def isStarredRepository?
    @statusHash[:isStarredRepository][:ret]
  end

  def isWatchingRepository?
    @statusHash[:isWatchingRepository][:ret]
  end

  def isFollowingUser?
    @statusHash[:isFollowingUser][:ret]
  end

end