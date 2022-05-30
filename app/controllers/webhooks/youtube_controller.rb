module Webhooks
  class YoutubeController < ApplicationController
    include CustomControllerHelpers

    before_action :check_linked_account_param

    def verify
      mode = params['hub.mode']
      topic = params['hub.topic']
      challenge = params['hub.challenge']

      if !linked_account && mode == 'unsubscribe' # deleted linked-account
        render plain: challenge
      elsif linked_account && mode == 'subscribe' # created linked-account
        return head :not_found unless topic == linked_account.topic_url
        render plain: challenge
      else
        head :not_found
      end
    end

    def notify
      signature = request.headers['X-Hub-Signature'].split('sha1=').last
      body = request.body.read
      match = YoutubeService::Subscription.hmac_matches?(body, signature)

      if match && linked_account.share_from?
        YoutubeService::Notification.new(body).post!(linked_account.user)
      end

      head :ok
    end

    private

    def linked_account
      @linked_account ||= LinkedAccount::YoutubeChannel.find_by(
        id: params[:linked_account]
      )
    end

    def check_linked_account_param
      unless params.include?(:linked_account)
        render status: :bad_request,
          plain: 'Missing linked_account'
      end
    end
  end
end
